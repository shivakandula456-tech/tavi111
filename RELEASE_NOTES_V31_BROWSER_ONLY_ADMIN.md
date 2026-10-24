# V31 — Browser-Only Admin

- Removed Supabase configuration, client adapter, schema and related script imports.
- Enabled direct client-side Admin ID/password login using the existing local session store.
- Added migration defaults for existing browsers that do not yet have local Admin credentials.
- Admin dashboard, product/category/media management, orders, settings, backup/restore and audit history continue to use browser-local storage.
- Removed the obsolete shared-catalogue import action and remote publishing branch.
- Updated the account page to explain that online customer accounts are unavailable; guest checkout remains available.
- Updated documentation to state local-only storage and security/synchronisation limitations.

Default local credentials: Admin ID `admin`, password `Tavish@2026`.

Security note: credentials and checks are shipped in public JavaScript. This is not secure authentication and must not protect secret credentials or sensitive customer data.
