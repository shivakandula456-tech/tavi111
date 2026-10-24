# GitHub Pages catalogue publishing — TAVISH & CO.

This workflow keeps the customer-facing website static: HTML, CSS and vanilla JavaScript. It does not use Supabase, a database service, Node.js or a separate backend server.

## One-time GitHub setup

1. Push this project to the repository's `main` branch (or change `main` in `.github/workflows/publish-catalogue.yml` to the actual default branch).
2. Open **Repository → Settings → Pages**.
3. Under **Build and deployment → Source**, select **GitHub Actions**.
4. Open **Settings → Actions → General** and ensure the workflow has permission to read and write repository contents. The workflow declares `contents: write`, `pages: write`, and `id-token: write`.
5. Confirm that GitHub Pages deploys successfully. The workflow deploys the full static site.

## Publish catalogue changes

1. Open the deployed website and sign in to Admin.
2. Go to **Settings → Backup & data management**.
3. Select **Export catalogue for GitHub publishing**. This downloads a JSON file containing products, categories, product images (including browser-uploaded data URLs), and public/store settings.
4. In the GitHub repository, upload that file into the `data` folder and name it exactly `catalogue-publish.json`.
5. Commit the change to `main`.
6. Open **Actions** and watch **Publish TAVISH & CO. catalogue to GitHub Pages**. The workflow validates SKUs/slugs, regenerates the shared seed files, increments the seed version, commits the generated files and deploys GitHub Pages.
7. After the run succeeds, open the site and hard-refresh (`Ctrl+Shift+R`). The workflow bumps the seed version so browsers with an older local catalogue replace their local products/categories/settings with the newly published seed on their next visit. Existing local orders/cart/wishlist are preserved.

The workflow removes `data/catalogue-publish.json` after processing so the submitted payload does not remain as a duplicate staging file in the repository. It still exists in the Admin user's downloaded copy.

## Important limitations

- This is a manual GitHub publishing process, not an automatic browser-to-GitHub write. Public JavaScript must never contain a GitHub token.
- Admin login remains client-side only and is not secure authentication.
- **Customer orders are still local to the browser that placed them.** GitHub Pages and GitHub Actions do not provide a central order database. Orders on customers' devices will not appear automatically in the Admin dashboard. Export/import backups are still required for local orders.
- The catalogue export may be large when product images are embedded as data URLs. GitHub rejects individual files over 100 MB, and large repositories/deployments can become slow. Optimise images and keep the export reasonably sized.
- Run this only from a trusted Admin session and review the catalogue export before committing it. Do not include real customer orders or other private data in the catalogue publishing file.
- If an existing browser has locally edited products that were never published, a new publication replaces its local catalogue with the published catalogue. Export a full backup first if those changes must be retained.

## Troubleshooting

- If the workflow does not run, verify the branch name and exact path `data/catalogue-publish.json`.
- If Pages deployment fails, confirm **Settings → Pages → Source** is set to **GitHub Actions**.
- If Git push fails, check repository Actions permissions and branch protection rules.
- If the workflow reports invalid JSON, export a fresh file from Admin instead of editing the JSON manually.
