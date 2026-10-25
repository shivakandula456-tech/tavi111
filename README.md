# TAVISH & CO.

Responsive static storefront built with HTML, CSS and vanilla JavaScript. Hosted on GitHub Pages. The shared catalogue and Admin data use Supabase.

## Main links

- Storefront: `/`
- Secure Admin login: `/admin/cloud-login.html`
- Unified Admin control panel: `/admin/cloud-admin.html`
- Connection check: `/supabase-connection-check.html`
- Rebuild audit: [REBUILD_AUDIT_2026-10-25.md](REBUILD_AUDIT_2026-10-25.md)

## Current architecture

- Frontend: HTML, CSS and vanilla JavaScript; no frontend framework.
- Data: Supabase PostgreSQL with Row Level Security (RLS).
- Authentication: Supabase Auth; Admin requires a profile row with role `admin`.
- Product images: Supabase Storage bucket `product-images`; the Admin's Media section can migrate existing repository product images.
- Public catalogue: public pages bootstrap product/category data from Supabase and use bundled seed data as a fallback if the remote catalogue is unavailable.
- Cart and wishlist preferences remain browser-local. Cloud checkout/order creation requires a trusted operation and must not trust browser-supplied totals or payment status.

## Admin access

Create users in Supabase Authentication. The first owner/admin profile must be provisioned by the project owner in the Supabase SQL Editor. Never put database passwords, secret keys, service-role keys or GitHub tokens into frontend files or this repository.

Legacy Admin URLs redirect to the unified Supabase-backed Admin. Products saved through an old browser-local editor are not shared catalogue records; review any local-only archive before retiring that browser data.

## Database migrations

SQL migrations live in `supabase/migrations/`. The initial schema and 24-product seed import have been applied to the project. The category/settings metadata backfill is also implemented in the unified Admin and can be run as a separate migration if needed.

## GitHub Pages deploy

The workflow in `.github/workflows/deploy-pages.yml` deploys the static repository from `main`. Supabase publishable configuration is public by design; access is restricted by RLS. Privileged operations belong in trusted server-side functions, never in browser JavaScript.
