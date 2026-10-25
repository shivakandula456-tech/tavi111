#!/usr/bin/env python3
"""Static integrity and JavaScript syntax checks for the TAVISH & CO. GitHub Pages site."""
from __future__ import annotations

import re
import subprocess
import tempfile
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
WEB_EXTENSIONS = {".js", ".css", ".html", ".png", ".jpg", ".jpeg", ".webp", ".avif", ".svg", ".ico", ".woff", ".woff2", ".mp4", ".webm"}


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.assets: list[tuple[str, str]] = []
        self.modules: list[str] = []
        self.inline_scripts: list[str] = []
        self._script_type = ""
        self._script_external = False
        self._script_data: list[str] = []

    def handle_starttag(self, tag: str, attrs) -> None:
        a = dict(attrs)
        if tag == "script":
            self._script_type = (a.get("type") or "").lower()
            self._script_external = bool(a.get("src"))
            self._script_data = []
            if a.get("src"):
                self.assets.append(("script", a["src"]))
            if a.get("data-page-modules"):
                self.modules.extend(x.strip() for x in a["data-page-modules"].split(",") if x.strip())
        if tag == "link" and a.get("href") and "stylesheet" in (a.get("rel") or "").lower():
            self.assets.append(("stylesheet", a["href"]))

    def handle_data(self, data: str) -> None:
        if self._script_type is not None and not self._script_external:
            self._script_data.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag == "script":
            if not self._script_external and self._script_type in ("", "text/javascript", "application/javascript"):
                text = "".join(self._script_data).strip()
                if text:
                    self.inline_scripts.append(text)
            self._script_type = ""
            self._script_external = False
            self._script_data = []


def local_path(page: Path, value: str) -> Path | None:
    value = (value or "").strip()
    if not value or value.startswith(("#", "//")):
        return None
    parsed = urlsplit(value)
    if parsed.scheme or parsed.netloc:
        return None
    path = parsed.path
    if not path:
        return None
    if path.startswith("/"):
        return ROOT / path.lstrip("/")
    return (page.parent / path).resolve()


def main() -> int:
    errors: list[str] = []
    html_files = sorted(ROOT.rglob("*.html"))
    js_files = sorted((ROOT / "assets" / "js").rglob("*.js"))
    checked_inline = 0
    checked_refs = 0

    for page in html_files:
        try:
            parser = PageParser()
            parser.feed(page.read_text(encoding="utf-8"))
        except Exception as exc:
            errors.append(f"{page.relative_to(ROOT)}: could not parse HTML: {exc}")
            continue

        refs = list(parser.assets)
        for module in parser.modules:
            if module.startswith(("http://", "https://", "//")):
                continue
            refs.append(("page module", module if module.startswith("/") else "assets/js/" + module.lstrip("/")))
        for kind, ref in refs:
            target = local_path(page, ref)
            if target is None:
                continue
            checked_refs += 1
            if not target.exists():
                errors.append(f"{page.relative_to(ROOT)}: missing {kind} reference: {ref}")
        for index, script in enumerate(parser.inline_scripts, 1):
            if not re.search(r"\b(function|const|let|var|=>|await|window\.|document\.)", script):
                continue
            checked_inline += 1
            with tempfile.NamedTemporaryFile("w", suffix=".js", encoding="utf-8", delete=False) as temp:
                temp.write(script)
                temp_path = Path(temp.name)
            try:
                checked = subprocess.run(
                    ["node", "--check", str(temp_path)],
                    text=True, capture_output=True, timeout=15, check=False
                )
                if checked.returncode:
                    errors.append(f"{page.relative_to(ROOT)} inline script #{index}: {checked.stderr.strip() or checked.stdout.strip()}")
            except FileNotFoundError:
                errors.append("node executable not found on CI runner; cannot run JavaScript syntax checks")
                break
            except subprocess.TimeoutExpired:
                errors.append(f"{page.relative_to(ROOT)} inline script #{index}: syntax check timed out")
            finally:
                temp_path.unlink(missing_ok=True)

    if not (ROOT / "index.html").exists():
        errors.append("Missing index.html")
    for js in js_files:
        try:
            checked = subprocess.run(["node", "--check", str(js)], text=True, capture_output=True, timeout=15, check=False)
            if checked.returncode:
                errors.append(f"{js.relative_to(ROOT)}: {checked.stderr.strip() or checked.stdout.strip()}")
        except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
            errors.append(f"{js.relative_to(ROOT)}: JavaScript syntax checker failed: {exc}")

    products = (ROOT / "data" / "products.js")
    if products.exists():
        seed = products.read_text(encoding="utf-8")
        count = len(re.findall(r"\bsku\s*:\s*['\"]TAV-", seed))
        if count < 24:
            errors.append(f"Expected at least 24 bundled seed products; found {count}")

    if errors:
        print("TAVISH & CO. validation FAILED")
        for error in errors:
            print(" - " + error)
        return 1

    print(f"TAVISH & CO. validation passed: {len(html_files)} HTML pages, {len(js_files)} JavaScript files, {checked_refs} local assets/modules, {checked_inline} inline scripts; seed catalogue >=24 products.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
