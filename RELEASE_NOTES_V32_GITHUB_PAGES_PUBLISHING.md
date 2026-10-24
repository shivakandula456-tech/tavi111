# V32 — GitHub Pages catalogue publishing

- Added an Admin action to export products, categories, and store settings for shared catalogue publishing.
- Added a GitHub Actions workflow that validates an uploaded `data/catalogue-publish.json`, generates the published seed files, increments the catalogue seed version, commits generated files, and deploys the static website to GitHub Pages.
- Added a reusable Python validation/generation script and setup guide.
- Existing browsers refresh their product/category/settings seed after a new publication; local order records are preserved.
- No Supabase, backend server, external database, Node.js frontend, or frontend framework was added.
- Limitation: customer orders remain local to the browser. This GitHub-only workflow does not create a central order database.
- Admin login remains client-side and is not secure authentication.
