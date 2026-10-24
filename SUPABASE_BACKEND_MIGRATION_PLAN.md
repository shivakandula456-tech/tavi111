# TAVISH & CO. — Supabase Backend Rebuild Plan

Status: planning document only. This document does not claim that Supabase is configured or that data has been migrated.

## Goal

Keep the existing HTML, CSS and vanilla JavaScript storefront and its visual design. Replace browser-only catalogue, Admin authentication, media, and order persistence with Supabase. Keep GitHub Pages for static hosting. Do not add React, Node.js, or a custom always-on server.

## Current repository findings

- `README.md` describes the site as V31 browser-only administration.
- `assets/js/storage.js` is a central localStorage layer and defines local keys for products, orders, cart, wishlist, settings, categories, audit, session and newsletter.
- `data/products.js`, `data/categories.js`, and `data/settings.js` are static seed files. The products seed currently contains 24 products with repository-relative image paths.
- `assets/js/admin.js` implements the Admin console, including product editing, local settings, local session and local order/audit flows.
- `admin/login.html` explicitly describes the login as client-side only. The current Admin credentials are not secure authentication.
- `admin/media.html` is part of the existing media library; browser-uploaded product images have been stored as data URLs in local records.
- `scripts/publish_catalogue.py` and `.github/workflows/publish-catalogue.yml` implement a manual JSON-export publishing workflow.
- The website has guest checkout and UPI instructions; payment completion is not independently verified by the website.
- A browser-only GitHub-token publishing experiment has been added to the Admin settings/product-save path. It should be removed once Supabase is implemented; do not make a GitHub personal access token a permanent browser credential.

## Target architecture

- Frontend: current static HTML/CSS/vanilla JavaScript, deployed by GitHub Pages.
- Supabase Auth: real Admin sign-in and session handling.
- Supabase PostgreSQL: products, categories, product images metadata, inventory, orders, order items, public settings, newsletter signups and admin audit events.
- Supabase Storage: product image files, using a public read bucket for public product imagery and authenticated write policies for Admin uploads.
- Supabase Edge Functions: only where privileged server-side operations are needed, such as payment verification or trusted order status transitions. Do not place service-role keys in browser code.
- Browser config: Supabase project URL and publishable/anon key may be in the frontend only after Row Level Security and Storage policies are correctly configured. These values are not secrets; policies must enforce authorization.

## Proposed database schema

1. `profiles`: auth user ID, display name, role. Admin roles are assigned deliberately; public sign-up must not be able to grant itself Admin.
2. `categories`: ID, name, slug, description, image path, visible, sort order, subcategory metadata.
3. `products`: ID, SKU, slug, name, description, category ID, subcategory, price, sale price, currency, material, finish, dimensions, weight, availability, featured/new/bestseller flags, status, sort order, timestamps.
4. `product_images`: ID, product ID, storage path, alt text, sort order, primary-image flag.
5. `inventory`: product ID, stock quantity, reserved quantity, updated timestamp (or equivalent fields in products if the initial stock model is simple).
6. `store_settings`: key/value JSON for public storefront settings. Never store Admin passwords here.
7. `orders`: ID, order number, customer contact/shipping snapshot, subtotal, shipping, total, currency, payment method/status, fulfillment status, timestamps.
8. `order_items`: order ID, product ID nullable for deleted products, SKU/name/price/quantity snapshot.
9. `newsletter_subscribers`: email, consent timestamp, status.
10. `admin_audit_log`: actor user ID, action, target type/ID, safe metadata, timestamp.

Use UUIDs for database identifiers. Preserve existing SKUs and slugs as unique constraints. Store prices as integer paise or a documented numeric representation consistently; do not mix representations.

## Security rules (must be in place before connecting the live site)

- Enable RLS on every exposed table.
- Anonymous visitors may read only active/visible product and category data and approved public settings.
- Only authenticated users whose profile has the Admin role may create/update/delete catalogue records, upload/delete images, edit settings, or view Admin-only audit data.
- Do not allow a user to update their own role field.
- Orders: do not expose all orders to anonymous users. A customer must only be able to retrieve their own order using a deliberate ownership/verification design; Admin can read and update all orders.
- Newsletter insertion must validate inputs and limit abuse; public clients cannot read the subscriber list.
- Storage: public read only for public product images; upload/update/delete restricted to Admin.
- Never ship the Supabase service-role key or payment secret in JavaScript, HTML, repository files or screenshots.
- Restrict CORS and validate all Edge Function inputs. Add rate limits/abuse controls for public operations where available.

## Implementation and migration phases

### Phase 0 — Safety and inventory
- Keep the current working site and a tagged/backup commit.
- Revoke any GitHub personal access token exposed in chat or browser screenshots; do not reuse it.
- Remove the browser-token publishing code after the Supabase replacement is ready.
- Audit all HTML script includes and map each page to the store methods it uses.
- Export a local full backup from each Admin browser that contains unpublished changes. LocalStorage is origin-specific, so one browser's backup does not include another browser's data.

### Phase 1 — Supabase project and schema
- Create a Supabase project and record the project URL and publishable key in a local deployment checklist, not a service-role key.
- Add SQL migrations for tables, indexes, unique constraints, triggers and RLS policies.
- Create the Admin user through Supabase Auth and assign the Admin role using a trusted setup procedure.
- Create the product image bucket and policies.
- Test all RLS rules with anonymous, regular-user and Admin sessions before connecting production pages.

### Phase 2 — Data migration
- Export the 24 seed products and category/settings data into a migration JSON using the existing `data/*.js` files as source.
- Normalize IDs and preserve SKUs, slugs, price values, status, product flags, categories and sort order.
- Upload repository-hosted images or existing product files into Supabase Storage and create `product_images` rows.
- Browser data URLs must be decoded into actual image files before upload; do not save large data URLs in PostgreSQL rows.
- Import products/categories/settings in a repeatable, idempotent script or SQL workflow. Verify row counts, SKU/slug uniqueness and image URLs.
- Local orders, cart, wishlist, newsletter and audit data are not central today. Migrate only explicitly exported records; don't assume the repository contains customer orders.

### Phase 3 — Frontend data adapter
- Introduce `assets/js/supabase-client.js` to load the Supabase JS client from a pinned CDN version and initialize it with the project URL and publishable key.
- Introduce a small `assets/js/data-service.js` API with methods for list/get products, list categories, settings, create/update/delete product, image upload/delete and order operations.
- Keep page markup and CSS unchanged. Update `assets/js/site.js`, `assets/js/shop.js`, `assets/js/product.js` and relevant page scripts to consume the adapter.
- Add loading, empty, error and offline states. Avoid a silent fallback to localStorage for Admin writes because it can make unpublished data look saved.
- Decide whether cart/wishlist remain browser-local for the first release; they can remain local while product data and orders move to Supabase.

### Phase 4 — Admin conversion
- Replace local credential comparison with Supabase Auth sign-in/sign-out and session restoration.
- Protect every Admin page by checking the authenticated session; enforce permissions in RLS regardless of UI checks.
- Change product save to await database success before showing “Saved”.
- Upload selected product images to Storage first, then save their paths/metadata in the database. Clean up newly uploaded orphan files if a later product write fails.
- Convert category/settings/media operations to database/storage methods.
- Make order and audit pages query protected backend data. Ensure the Admin never displays a false success toast.

### Phase 5 — Orders and payments
- Persist each checkout as an order plus immutable order-item snapshots.
- For UPI/manual payments, keep status as pending until an Admin verifies the bank/UPI receipt independently.
- If Razorpay is added, create orders and verify signatures/webhooks through a Supabase Edge Function or another trusted server-side component. Never trust a browser-only “payment done” click.
- Add inventory reservation/stock validation to avoid overselling.

### Phase 6 — Verification and rollout
- Test anonymous product browsing, search/filter/reset, product detail pages, image galleries, mobile/tablet/desktop layouts and all existing brand styling.
- Test Admin sign-in, expired sessions, create/edit/delete product, multi-image upload, category edits, settings, audit events and permission denials.
- Test checkout validation, duplicate submissions, order visibility, payment pending/verified/failed states and inventory.
- Run migration count comparisons and broken-image checks.
- Deploy to a staging branch/site first; retain a rollback commit. Switch production only after acceptance.
- Remove the manual catalogue-export workflow and GitHub token publisher after the Supabase-backed flow is confirmed. Keep GitHub Pages deployment workflow.

## Acceptance criteria

- Saving a product writes to Supabase and remains visible in a separate browser/device after refresh.
- Product images are real Storage objects with stable paths, not browser data URLs.
- A visitor cannot change catalogue/settings, read private orders, or access Admin audit data through direct API calls.
- No privileged secret is present in public source.
- Admin receives success only after the database/storage operation succeeds, with actionable errors on failure.
- The visual design, responsive layouts, vanilla JS frontend and GitHub Pages deployment remain intact.
- Order and payment state is durable and has a clearly defined verification process.

## Important constraints

- Supabase has its own free/paid limits; review current project limits and backups before launch.
- Static GitHub Pages remains suitable for the frontend, but privileged payment and trusted business logic must run in an Edge Function or another server-side environment.
- This is a plan, not an implemented Supabase backend. The project must be created and its schema/policies tested before production data is connected.
