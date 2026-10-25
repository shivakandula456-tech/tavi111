# TAVISH & CO. — Full Rebuild Audit
Audit date: 2026-10-25
Repository: shivakandula456-tech/tavi111
Audited branch: main

## Backup
Created branch `backup/pre-rebuild-2026-10-25` from main before coordinated work. It points to commit `72f69c26680ad55f0d575a62b8dfb6f0b6827a1c` (`Route legacy product editor to Supabase Cloud Admin`). This is a source-code backup; export Supabase data before destructive schema/data work.

## Locked requirements
- Save/publish immediately on valid save.
- One image is sufficient to publish; support four or more images with no four-image cap.
- Preserve all records and identify possible test products; do not delete them without owner approval.
- Keep current heritage design and responsive desktop/mobile direction.
- Use HTML/CSS/vanilla JS and GitHub Pages; Supabase is the shared database, Auth and Storage.

## Inventory
The main branch has 306 tracked files, 15 root/public HTML pages, 15 Admin HTML pages, 96 product image assets and 94 stock/reference assets. It contains the 24-item catalogue seed, local-storage store/admin scripts, two GitHub Actions workflows, and Supabase schema/import migrations.

## Findings

### Critical: two independent sources of truth
Public pages (`index.html`, `shop.html`, `product.html`, cart, wishlist, search and account pages) load static data files and `assets/js/storage.js`. The storefront reads product data from browser localStorage/seeds. The new Cloud Admin separately reads and writes Supabase. Thus local Admin changes are not shared and Cloud Admin edits cannot yet reliably reach the public storefront.

### Critical: legacy Admin remains active
`admin/login.html` and `assets/js/admin.js` provide browser-only authentication and localStorage writes. Product save then attempts an optional GitHub publisher, and shows an error when that publisher is not configured. `admin/products.html` still loads the legacy scripts. The Cloud Admin needs to become the active supported route across navigation, not just a separate experimental page. Browser-side GitHub token publishing should not be the primary data path.

### Critical: Cloud Admin is not full product management yet
`admin/cloud-catalogue.html` queries Supabase and provides basic product add/edit/status actions. It uses a plain text field for image paths. There is no file picker, multiple-image upload, preview, gallery reorder, primary-image choice, upload progress or image removal. The form stores one image reference rather than a full gallery and does not yet reproduce the complete existing Admin feature set.

### Critical: product image records are not actual Storage objects
The catalogue import writes existing paths such as `assets/images/products/p01-1.jpg` into `product_images.storage_path`. Those are repository asset paths, not object names in the Supabase `product-images` bucket. The schema creates the bucket and RLS policies, but the importer does not upload the files. The repository has 96 product photos ready for migration. A browser-admin upload/sync tool or equivalent is needed to upload assets and update image records.

### High: data mapping mismatch
- Supabase stores prices in integer paise; storefront model uses rupees.
- Supabase product IDs are UUIDs; legacy store/carts expect numeric IDs.
- Images are in `product_images`, not a `primary_image` column on products.
- Category import adds names/slugs but does not fully import subcategories, descriptions and category images.
- Product status (`ACTIVE/DRAFT/HIDDEN/TRASH`) is distinct from availability (`IN_STOCK/OUT_OF_STOCK/PREORDER`); mapping must preserve both.
- Cloud Admin lists all Supabase products, while public RLS policy lists active products only.

### High: orders and settings remain local
Public cart/order actions and the existing Admin order workflows remain browser-local. The schema intentionally does not expose anonymous order insert. Orders should go through a trusted Supabase Edge Function that recalculates prices/availability. Newsletter and settings also need deliberate migration. Do not loosen RLS to permit arbitrary browser writes.

### High: verification and documentation gaps
The Pages workflow checks only a small set of file paths; it does not lint/test product mappings or perform integration checks. README/page footers still describe the site as browser-only. The Cloud Admin showed 26 rows after the seed import, while the seed contains 24. The two additional products (previously shown as `s` and `zzz`) must be inspected and retained until explicitly approved for deletion.

## Coordinated implementation sequence
1. Preserve backup; export current Supabase data before any destructive change.
2. Create a shared adapter mapping UUIDs, rupee/paise, categories, status and ordered image records.
3. Upload the 96 repository product images to Supabase Storage and switch metadata to real storage object paths, retaining fallbacks until verified.
4. Consolidate Admin entry points/navigation and wire product/category/media/settings workflows to Supabase Auth and RLS.
5. Bootstrap storefront data from Supabase asynchronously without changing the existing visual layout; retain only suitable local preferences/cart state.
6. Implement secure order creation and payment status handling in a trusted function.
7. Add checks for syntax, data mapping, CRUD, multi-image upload, public listing, RLS boundaries and responsive layouts.
8. Test before release and do not delete possible test products without explicit confirmation.

## Acceptance criteria
- One shared product catalogue; admin edits appear after refresh and on another device.
- Save feedback only appears after required database/Storage writes succeed.
- One-image publishing works, and four-or-more image galleries are supported.
- Draft/hidden/trash products are excluded from public listings; availability remains separate.
- Existing records survive migration; possible test rows are reviewed, not auto-deleted.
- Public users cannot write Admin catalogue data or access private orders/subscriber lists.
- Existing desktop/mobile storefront visual style stays intact.
