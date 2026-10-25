-- TAVISH & CO. catalogue import: 24 repository seed products
-- Safe to run more than once: SKU/slug conflicts are updated, not duplicated.
-- Prices are stored in paise. Product images initially reference existing GitHub Pages assets.

insert into public.categories (name, slug, visible, sort_order)
values ('Earrings', 'earrings', true, 1)
on conflict (slug) do update set name = excluded.name, visible = true, sort_order = excluded.sort_order;

insert into public.categories (name, slug, visible, sort_order)
values ('Necklaces', 'necklaces', true, 2)
on conflict (slug) do update set name = excluded.name, visible = true, sort_order = excluded.sort_order;

insert into public.categories (name, slug, visible, sort_order)
values ('Bracelets', 'bracelets', true, 3)
on conflict (slug) do update set name = excluded.name, visible = true, sort_order = excluded.sort_order;

insert into public.categories (name, slug, visible, sort_order)
values ('Rings', 'rings', true, 4)
on conflict (slug) do update set name = excluded.name, visible = true, sort_order = excluded.sort_order;

insert into public.categories (name, slug, visible, sort_order)
values ('Accessories', 'accessories', true, 5)
on conflict (slug) do update set name = excluded.name, visible = true, sort_order = excluded.sort_order;

with cat as (select id from public.categories where slug = 'earrings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-EAR-001', 'mogra-pearl-drop-earrings', 'Mogra Pearl Drop Earrings', 'Hand-finished pearl drops suspended from an anti-tarnish gold-tone hook. Lightweight enough for all-day wear, considered enough for an evening of celebration.', (select id from cat), 'Earrings', 'Anti-Tarnish', 289000, 239000, 'INR', 'Brass with 18k gold-tone plating, freshwater pearl', 'High polish, anti-tarnish coating', '5.8 cm drop x 2.4 cm width', '8 g per pair', 'IN_STOCK', true, true, false, ARRAY['pearl', 'anti-tarnish', 'drops', 'everyday']::text[], 'ACTIVE', 1)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Mogra Pearl Drop Earrings', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p01-1.jpg', 1), ('assets/images/products/p01-2.jpg', 2), ('assets/images/products/p01-3.jpg', 3), ('assets/images/products/p01-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'earrings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-EAR-002', 'noor-polki-stud-earrings', 'Noor Polki Stud Earrings', 'Uncut polki-style stones set in a quiet stud silhouette. A modern heirloom that stays bright wear after wear thanks to our anti-tarnish finish.', (select id from cat), 'Earrings', 'Anti-Tarnish', 345000, NULL, 'INR', 'Brass with gold-tone plating, glass polki stones', 'Anti-tarnish, mirror polish', '1.9 cm x 1.7 cm', '5 g per pair', 'IN_STOCK', false, true, true, ARRAY['polki', 'studs', 'anti-tarnish', 'office']::text[], 'ACTIVE', 2)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Noor Polki Stud Earrings', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p02-1.jpg', 1), ('assets/images/products/p02-2.jpg', 2), ('assets/images/products/p02-3.jpg', 3), ('assets/images/products/p02-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'earrings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-EAR-003', 'ira-minimal-hoop-earrings', 'Ira Minimal Hoop Earrings', 'Slim, softly squared hoops inspired by Seoul studio jewellery. The kind of pair you forget you are wearing until someone asks about it.', (select id from cat), 'Earrings', 'Korean', 169000, 149000, 'INR', 'Stainless steel with gold ion plating', 'Brushed and polished dual texture', '2.2 cm outer diameter', '4 g per pair', 'IN_STOCK', true, false, true, ARRAY['korean', 'hoops', 'minimal', 'lightweight']::text[], 'ACTIVE', 3)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Ira Minimal Hoop Earrings', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p03-1.jpg', 1), ('assets/images/products/p03-2.jpg', 2), ('assets/images/products/p03-3.jpg', 3), ('assets/images/products/p03-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'earrings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-EAR-004', 'sona-sculpted-drop-earrings', 'Sona Sculpted Drop Earrings', 'Sculpted drops with a warm satin glow — an abstract silhouette borrowed from contemporary Korean ateliers, scaled for Indian festive dressing.', (select id from cat), 'Earrings', 'Korean', 229000, NULL, 'INR', 'Brass with 18k gold-tone plating', 'Satin matte with polished edges', '4.4 cm drop x 2.1 cm width', '7 g per pair', 'IN_STOCK', false, true, false, ARRAY['korean', 'sculpted', 'statement', 'drops']::text[], 'ACTIVE', 4)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Sona Sculpted Drop Earrings', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p04-1.jpg', 1), ('assets/images/products/p04-2.jpg', 2), ('assets/images/products/p04-3.jpg', 3), ('assets/images/products/p04-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'earrings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-EAR-005', 'rajwadi-jhumka-earrings', 'Rajwadi Jhumka Earrings', 'A temple-inspired jhumka with tiered filigree and a soft pearl fringe. Made to anchor a bridal trousseau or a festive lehenga.', (select id from cat), 'Earrings', 'Festive', 549000, 479000, 'INR', 'Gold-tone brass, kundan glass, faux pearl', 'Antique gold with hand-set stones', '6.2 cm drop x 3.4 cm width', '16 g per pair', 'IN_STOCK', true, false, true, ARRAY['jhumka', 'festive', 'kundan', 'bridal']::text[], 'ACTIVE', 5)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Rajwadi Jhumka Earrings', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p05-1.jpg', 1), ('assets/images/products/p05-2.jpg', 2), ('assets/images/products/p05-3.jpg', 3), ('assets/images/products/p05-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'earrings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-EAR-006', 'kiran-chandbali-earrings', 'Kiran Chandbali Earrings', 'Crescent chandbalis drawn from Rajasthani court jewellery, lightened for long evenings of music, dance and conversation.', (select id from cat), 'Earrings', 'Festive', 489000, NULL, 'INR', 'Gold-tone brass with meenakari enamel', 'Hand-painted enamel, polished gold edge', '5.1 cm drop x 3.9 cm width', '14 g per pair', 'IN_STOCK', false, true, false, ARRAY['chandbali', 'festive', 'enamel', 'bridal']::text[], 'ACTIVE', 6)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Kiran Chandbali Earrings', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p06-1.jpg', 1), ('assets/images/products/p06-2.jpg', 2), ('assets/images/products/p06-3.jpg', 3), ('assets/images/products/p06-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'necklaces' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-NEC-001', 'aurelia-fine-chain-necklace', 'Aurelia Fine Chain Necklace', 'A barely-there chain with a liquid drape. Layer it, or let it sit alone at the collarbone — it will not tarnish, and it will not leave your neck green.', (select id from cat), 'Necklaces', 'Anti-Tarnish', 219000, 189000, 'INR', 'Stainless steel, 18k gold PVD plating', 'High polish, anti-tarnish', '42 cm chain with 5 cm extender', '4 g', 'IN_STOCK', true, false, true, ARRAY['chain', 'anti-tarnish', 'layering', 'everyday']::text[], 'ACTIVE', 7)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Aurelia Fine Chain Necklace', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p07-1.jpg', 1), ('assets/images/products/p07-2.jpg', 2), ('assets/images/products/p07-3.jpg', 3), ('assets/images/products/p07-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'necklaces' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-NEC-002', 'veda-coin-pendant-necklace', 'Veda Coin Pendant Necklace', 'Hand-stamped coin charms on an anti-tarnish cable chain — a talisman silhouette reworked for everyday Indian dressing.', (select id from cat), 'Necklaces', 'Anti-Tarnish', 319000, NULL, 'INR', 'Brass with gold-tone anti-tarnish plating', 'Textured coin relief, polished chain', '45 cm chain, 3.1 cm pendant drop', '9 g', 'IN_STOCK', false, true, false, ARRAY['coin', 'pendant', 'anti-tarnish', 'layering']::text[], 'ACTIVE', 8)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Veda Coin Pendant Necklace', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p08-1.jpg', 1), ('assets/images/products/p08-2.jpg', 2), ('assets/images/products/p08-3.jpg', 3), ('assets/images/products/p08-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'necklaces' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-NEC-003', 'lumen-layered-necklace', 'Lumen Layered Necklace', 'Two graduated chains joined at a single clasp, so the layered look takes seconds rather than minutes.', (select id from cat), 'Necklaces', 'Korean', 279000, NULL, 'INR', 'Stainless steel with gold ion plating', 'High polish', '38 cm and 43 cm layers', '6 g', 'IN_STOCK', false, false, true, ARRAY['korean', 'layered', 'minimal', 'stacking']::text[], 'ACTIVE', 9)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Lumen Layered Necklace', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p09-1.jpg', 1), ('assets/images/products/p09-2.jpg', 2), ('assets/images/products/p09-3.jpg', 3), ('assets/images/products/p09-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'necklaces' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-NEC-004', 'mira-crystal-line-necklace', 'Mira Crystal Line Necklace', 'A single line of hand-set crystals that catches candlelight beautifully — the quietest form of glamour in the collection.', (select id from cat), 'Necklaces', 'Korean', 439000, 389000, 'INR', 'Cubic zirconia, rhodium-tone alloy', 'Pavé setting, polished backplate', '40 cm with 4 cm extender', '11 g', 'IN_STOCK', false, true, false, ARRAY['crystal', 'korean', 'evening', 'delicate']::text[], 'ACTIVE', 10)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Mira Crystal Line Necklace', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p10-1.jpg', 1), ('assets/images/products/p10-2.jpg', 2), ('assets/images/products/p10-3.jpg', 3), ('assets/images/products/p10-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'necklaces' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-NEC-005', 'maharani-kundan-necklace', 'Maharani Kundan Necklace', 'A ceremonial kundan collar with pearl drops and a hand-set centre medallion. Designed for weddings, sangeets and the photographs that outlive them.', (select id from cat), 'Necklaces', 'Festive', 1299000, 1149000, 'INR', 'Gold-tone brass, kundan glass, faux pearl', 'Hand-set, antique gold wash', '36 cm collar with adjustable dori', '78 g', 'IN_STOCK', true, false, true, ARRAY['kundan', 'bridal', 'festive', 'statement']::text[], 'ACTIVE', 11)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Maharani Kundan Necklace', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p11-1.jpg', 1), ('assets/images/products/p11-2.jpg', 2), ('assets/images/products/p11-3.jpg', 3), ('assets/images/products/p11-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'necklaces' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-NEC-006', 'sitara-celebration-necklace', 'Sitara Celebration Necklace', 'Beaded strands and a star-set centre piece that reads as jewellery from across a room, and as craft up close.', (select id from cat), 'Necklaces', 'Festive', 849000, NULL, 'INR', 'Glass beads, gold-tone brass, semi-precious stones', 'Hand-strung with knotted cord', '40 cm with 6 cm tie closure', '54 g', 'IN_STOCK', false, false, false, ARRAY['festive', 'beaded', 'handmade', 'statement']::text[], 'ACTIVE', 12)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Sitara Celebration Necklace', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p12-1.jpg', 1), ('assets/images/products/p12-2.jpg', 2), ('assets/images/products/p12-3.jpg', 3), ('assets/images/products/p12-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'bracelets' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-BRA-001', 'aroha-gold-kada', 'Aroha Gold Kada', 'A weighty, softly rounded kada with a discreet hinge — the single bangle that finishes a sleeve.', (select id from cat), 'Bracelets', 'Kadas', 429000, NULL, 'INR', 'Brass with 18k gold-tone plating', 'Mirror polish with satin interior', 'Inner diameter 6.2 cm, 8 mm width', '32 g', 'IN_STOCK', true, false, false, ARRAY['kada', 'gold', 'daily wear', 'hinged']::text[], 'ACTIVE', 13)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Aroha Gold Kada', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p13-1.jpg', 1), ('assets/images/products/p13-2.jpg', 2), ('assets/images/products/p13-3.jpg', 3), ('assets/images/products/p13-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'bracelets' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-BRA-002', 'tara-enamel-kada', 'Tara Enamel Kada', 'Colour-blocked enamel bands strung between gold discs — a playful kada that still feels considered.', (select id from cat), 'Bracelets', 'Kadas', 369000, 329000, 'INR', 'Brass, vitreous enamel, glass beads', 'Hand-painted enamel, polished gold discs', '7.5 cm inner circumference, adjustable', '22 g', 'IN_STOCK', false, true, false, ARRAY['enamel', 'colour', 'kada', 'korean']::text[], 'ACTIVE', 14)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Tara Enamel Kada', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p14-1.jpg', 1), ('assets/images/products/p14-2.jpg', 2), ('assets/images/products/p14-3.jpg', 3), ('assets/images/products/p14-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'bracelets' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-BRA-003', 'rani-slim-bangle-set', 'Rani Slim Bangle Set', 'Four whisper-slim bangles meant to be stacked, mixed and never taken off. Sold as a set of four.', (select id from cat), 'Bracelets', 'Bangles', 259000, NULL, 'INR', 'Silver-tone brass with anti-tarnish coating', 'High polish with beaded edge', '2.6 mm width, size 2-4 Indian', '12 g per set', 'IN_STOCK', false, false, true, ARRAY['bangles', 'stack', 'silver tone', 'set']::text[], 'ACTIVE', 15)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Rani Slim Bangle Set', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p15-1.jpg', 1), ('assets/images/products/p15-2.jpg', 2), ('assets/images/products/p15-3.jpg', 3), ('assets/images/products/p15-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'bracelets' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-BRA-004', 'ivory-textured-bangle-set', 'Ivory Textured Bangle Set', 'Textured bangles with an ivory-toned centre band — a neutral stack that pairs with everything from cotton to silk.', (select id from cat), 'Bracelets', 'Bangles', 329000, NULL, 'INR', 'Brass with gold-tone plating, resin inlay', 'Hammered texture, matte inlay', '6.8 cm inner diameter, 9 mm width', '26 g', 'IN_STOCK', false, true, false, ARRAY['bangles', 'textured', 'ivory', 'stack']::text[], 'ACTIVE', 16)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Ivory Textured Bangle Set', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p16-1.jpg', 1), ('assets/images/products/p16-2.jpg', 2), ('assets/images/products/p16-3.jpg', 3), ('assets/images/products/p16-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'rings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-RNG-001', 'amara-cocktail-ring', 'Amara Cocktail Ring', 'An oversized cocktail ring with a warm champagne centre stone, set high enough to catch every light in the room.', (select id from cat), 'Rings', 'Statement', 499000, 429000, 'INR', 'Brass with gold-tone plating, cubic zirconia', 'Pavé halo, high polish shank', 'Face 1.8 cm, adjustable band', '7 g', 'IN_STOCK', false, false, false, ARRAY['cocktail', 'statement', 'adjustable', 'evening']::text[], 'ACTIVE', 17)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Amara Cocktail Ring', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p17-1.jpg', 1), ('assets/images/products/p17-2.jpg', 2), ('assets/images/products/p17-3.jpg', 3), ('assets/images/products/p17-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'rings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-RNG-002', 'rumi-gemstone-ring', 'Rumi Gemstone Ring', 'A single deep-green stone held in a hand-carved bezel — the ring that starts conversations.', (select id from cat), 'Rings', 'Statement', 579000, NULL, 'INR', 'Gold-tone brass, lab-created emerald', 'Carved bezel, satin shoulders', 'Face 1.4 cm, sizes 8-14 Indian', '6 g', 'IN_STOCK', false, true, false, ARRAY['gemstone', 'green', 'statement', 'hand carved']::text[], 'ACTIVE', 18)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Rumi Gemstone Ring', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p18-1.jpg', 1), ('assets/images/products/p18-2.jpg', 2), ('assets/images/products/p18-3.jpg', 3), ('assets/images/products/p18-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'rings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-RNG-003', 'eternal-gold-band', 'Eternal Gold Band', 'A plain, perfectly weighted band with a softly domed profile. Designed to be worn alone or stacked with promise bands.', (select id from cat), 'Rings', 'Bands', 389000, NULL, 'INR', 'Stainless steel with 18k gold PVD plating', 'Mirror polish', '4 mm width, sizes 6-16 Indian', '5 g', 'IN_STOCK', true, false, true, ARRAY['band', 'classic', 'unisex', 'stacking']::text[], 'ACTIVE', 19)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Eternal Gold Band', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p19-1.jpg', 1), ('assets/images/products/p19-2.jpg', 2), ('assets/images/products/p19-3.jpg', 3), ('assets/images/products/p19-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'rings' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-RNG-004', 'nocturne-stackable-band', 'Nocturne Stackable Band', 'A slim noir band with a single inset stone — the counterpoint your gold stack has been missing.', (select id from cat), 'Rings', 'Bands', 269000, 229000, 'INR', 'Stainless steel, black ion plating, cubic zirconia', 'Matte black with polished inset', '2.5 mm width, sizes 6-14 Indian', '3 g', 'IN_STOCK', false, false, false, ARRAY['band', 'stackable', 'black', 'minimal']::text[], 'ACTIVE', 20)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Nocturne Stackable Band', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p20-1.jpg', 1), ('assets/images/products/p20-2.jpg', 2), ('assets/images/products/p20-3.jpg', 3), ('assets/images/products/p20-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'accessories' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-ACC-001', 'seraphine-pendant-chain', 'Seraphine Pendant Chain', 'A fine chain carrying a single sculpted pendant, finished on both sides so it always falls the right way.', (select id from cat), 'Accessories', 'Chains & Pendants', 349000, NULL, 'INR', 'Rose gold-tone brass, glass stone', 'Polished chain, brushed pendant', '44 cm chain, 2.6 cm pendant', '6 g', 'IN_STOCK', false, true, false, ARRAY['pendant', 'chain', 'rose gold', 'gifting']::text[], 'ACTIVE', 21)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Seraphine Pendant Chain', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p21-1.jpg', 1), ('assets/images/products/p21-2.jpg', 2), ('assets/images/products/p21-3.jpg', 3), ('assets/images/products/p21-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'accessories' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-ACC-002', 'florera-pearl-brooch', 'Florera Pearl Brooch', 'A floral brooch clustered with pearls and crystals — pin it to a blouse, a dupatta or a gift wrap.', (select id from cat), 'Accessories', 'Brooches', 399000, 349000, 'INR', 'Gold-tone brass, glass crystals, faux pearl', 'Hand-set stones, antique wash', '4.6 cm x 3.8 cm', '14 g', 'IN_STOCK', false, false, false, ARRAY['brooch', 'floral', 'pearl', 'gifting']::text[], 'ACTIVE', 22)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Florera Pearl Brooch', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p22-1.jpg', 1), ('assets/images/products/p22-2.jpg', 2), ('assets/images/products/p22-3.jpg', 3), ('assets/images/products/p22-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'accessories' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-ACC-003', 'saanjh-jewellery-coffer', 'Saanjh Jewellery Coffer', 'A lined keepsake coffer with three pull-out trays — sized for the pieces you reach for every day.', (select id from cat), 'Accessories', 'Keepsakes', 649000, NULL, 'INR', 'Hand-finished wood, velvet lining, brass fittings', 'Lacquered exterior, soft-touch interior', '24 cm x 16 cm x 11 cm', '640 g', 'IN_STOCK', false, false, false, ARRAY['keepsake', 'storage', 'gifting', 'home']::text[], 'DRAFT', 23)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Saanjh Jewellery Coffer', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p23-1.jpg', 1), ('assets/images/products/p23-2.jpg', 2), ('assets/images/products/p23-3.jpg', 3), ('assets/images/products/p23-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

with cat as (select id from public.categories where slug = 'accessories' limit 1), upserted as (
 insert into public.products (sku, slug, name, description, category_id, category_name, subcategory, price_paise, sale_price_paise, currency, material, finish, dimensions, weight, availability, featured, new_arrival, best_seller, tags, status, sort_order)
 values ('TAV-ACC-004', 'anaya-charm-anklet', 'Anaya Charm Anklet', 'A fine anklet scattered with tiny charms and bells that move quietly as you walk.', (select id from cat), 'Accessories', 'Charms', 239000, NULL, 'INR', 'Silver-tone brass, glass charms', 'Anti-tarnish polish', '25 cm with 3 cm extender', '8 g', 'OUT_OF_STOCK', false, false, false, ARRAY['anklet', 'charms', 'silver tone', 'summer']::text[], 'ACTIVE', 24)
 on conflict (sku) do update set slug=excluded.slug, name=excluded.name, description=excluded.description, category_id=excluded.category_id, category_name=excluded.category_name, subcategory=excluded.subcategory, price_paise=excluded.price_paise, sale_price_paise=excluded.sale_price_paise, material=excluded.material, finish=excluded.finish, dimensions=excluded.dimensions, weight=excluded.weight, availability=excluded.availability, featured=excluded.featured, new_arrival=excluded.new_arrival, best_seller=excluded.best_seller, tags=excluded.tags, status=excluded.status, sort_order=excluded.sort_order, updated_at=now()
 returning id, sku
)
insert into public.product_images (product_id, storage_path, alt_text, sort_order, is_primary)
select upserted.id, img.path, 'Anaya Charm Anklet', img.ord, img.ord=1
from upserted cross join lateral (values ('assets/images/products/p24-1.jpg', 1), ('assets/images/products/p24-2.jpg', 2), ('assets/images/products/p24-3.jpg', 3), ('assets/images/products/p24-4.jpg', 4)) as img(path, ord)
on conflict (product_id, storage_path) do update set alt_text=excluded.alt_text, sort_order=excluded.sort_order, is_primary=excluded.is_primary;

-- Verify the import:
select count(*) as imported_products from public.products;
select count(*) as image_records from public.product_images;
