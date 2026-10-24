# TAVISH & CO. — V31 Browser-Only Admin

A static storefront built with HTML, CSS and vanilla JavaScript. No Supabase, backend server, database service, API, Node.js runtime or frontend framework is required.

## Administration

- Admin URL: `/admin/login.html`
- Initial Admin ID: `admin`
- Initial password: `Tavish@2026`
- Admin sections: dashboard, products, product editor, categories, media library, orders, order detail, newsletter, settings/backup and audit log.
- Admin login is implemented entirely in public browser JavaScript. It is a convenience barrier only and is **not secure authentication**.

## Browser-local behaviour

Products, categories, website settings, order records, cart, wishlist, Admin session and audit log are stored in the current browser's local storage. Product uploads are compressed in the browser and saved as image data URLs with product records. Browser storage is limited; export backups regularly.

**Changes do not synchronise across different browsers or customer devices.** Orders placed on another device are not visible in this Admin dashboard. Export/import can be used for manual transfer, but it is not automatic publishing.

The customer account page uses guest checkout. Online customer registration, password sign-in and Google sign-in are not available in this browser-only build.

## Checkout and payment

- UPI-only checkout with an order-specific payment URI/QR.
- Payments must be verified manually in the receiving UPI/bank app. The website does not independently verify payment.
- Shipping is free above ₹999; otherwise the shipping fee is ₹99, according to the current settings.
- Orders are saved locally in the browser where checkout is completed.

## Local testing

Serve the extracted project directory with any static file server, then open the local address. For example:

```bash
python -m http.server 8080
```

Open `http://localhost:8080` and visit `/admin/login.html` for the Admin page.

## Deployment notes

The project can be deployed as static files. Deploy the full folder structure; do not open individual HTML files using `file://` because browser storage and relative resource behaviour may differ. A static deployment does not make browser-local catalogue edits visible to all customers. A shared live catalogue, secure Admin authentication and central order storage would require a shared service, which is intentionally excluded from this version.

## Image notes

The bundled catalogue contains reference product imagery for development. Replace temporary/reference imagery with final product photography before commercial launch.


## GitHub Pages catalogue publishing (V32)

See [`GITHUB_PAGES_CATALOGUE_PUBLISHING.md`](GITHUB_PAGES_CATALOGUE_PUBLISHING.md) for one-time setup and the exact Admin export → GitHub commit → Actions deployment workflow. This publishes products/categories/settings for all customers. Customer orders remain browser-local; a GitHub-only setup cannot centrally synchronise orders.
