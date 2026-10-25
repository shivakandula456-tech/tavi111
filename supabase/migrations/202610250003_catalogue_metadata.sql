-- TAVISH & CO. metadata backfill for the shared catalogue.
-- Safe to rerun: category copy is only filled when the stored fields are blank;
-- existing non-empty descriptions, image paths, subcategories and settings are preserved.
insert into public.categories
  (name, slug, description, image_path, visible, sort_order, subcategories)
values
  ('Earrings','earrings','Anti-tarnish everyday studs, contemporary Korean silhouettes and festive statement earrings.','assets/images/products/p05-1.jpg',true,1,
   '[{"id":"sub-earrings-anti-tarnish","name":"Anti-Tarnish","slug":"anti-tarnish","sortOrder":1,"visible":true},{"id":"sub-earrings-korean","name":"Korean","slug":"korean","sortOrder":2,"visible":true},{"id":"sub-earrings-festive","name":"Festive","slug":"festive","sortOrder":3,"visible":true}]'::jsonb),
  ('Necklaces','necklaces','Fine chains, layered Korean edits and heirloom-inspired festive necklaces.','assets/images/products/p11-1.jpg',true,2,
   '[{"id":"sub-necklaces-anti-tarnish","name":"Anti-Tarnish","slug":"anti-tarnish","sortOrder":1,"visible":true},{"id":"sub-necklaces-korean","name":"Korean","slug":"korean","sortOrder":2,"visible":true},{"id":"sub-necklaces-festive","name":"Festive","slug":"festive","sortOrder":3,"visible":true}]'::jsonb),
  ('Bracelets','bracelets','Sculpted kadas and slim bangle stacks made for daily wear and celebration.','assets/images/products/p13-1.jpg',true,3,
   '[{"id":"sub-bracelets-kadas","name":"Kadas","slug":"kadas","sortOrder":1,"visible":true},{"id":"sub-bracelets-bangles","name":"Bangles","slug":"bangles","sortOrder":2,"visible":true}]'::jsonb),
  ('Rings','rings','Cocktail rings, gemstone settings and minimal bands sized for Indian ring sizes.','assets/images/products/p17-1.jpg',true,4,
   '[{"id":"sub-rings-statement","name":"Statement","slug":"statement","sortOrder":1,"visible":true},{"id":"sub-rings-bands","name":"Bands","slug":"bands","sortOrder":2,"visible":true}]'::jsonb),
  ('Accessories','accessories','Pendant chains, brooches, keepsakes and charms that complete the TAVISH look.','assets/images/products/p22-1.jpg',true,5,
   '[{"id":"sub-accessories-chains","name":"Chains & Pendants","slug":"chains-pendants","sortOrder":1,"visible":true},{"id":"sub-accessories-brooches","name":"Brooches","slug":"brooches","sortOrder":2,"visible":true},{"id":"sub-accessories-keepsakes","name":"Keepsakes","slug":"keepsakes","sortOrder":3,"visible":true},{"id":"sub-accessories-charms","name":"Charms","slug":"charms","sortOrder":4,"visible":true}]'::jsonb)
on conflict (slug) do update set
  name = excluded.name,
  description = case when coalesce(public.categories.description,'') = '' then excluded.description else public.categories.description end,
  image_path = case when public.categories.image_path is null then excluded.image_path else public.categories.image_path end,
  subcategories = case when public.categories.subcategories = '[]'::jsonb then excluded.subcategories else public.categories.subcategories end,
  sort_order = case when public.categories.sort_order = 0 then excluded.sort_order else public.categories.sort_order end;

insert into public.store_settings (key, value, is_public) values
('brand', '{"name":"TAVISH & CO.","tagline":"Jewellery shaped by Indian heritage, made for now.","shortDescription":"TAVISH & CO. is a contemporary Indian jewellery house working in gold tones, pearls and hand-set stones — anti-tarnish essentials, Korean-inspired edits and festive heirlooms.","logo":"assets/images/brand/tavish-co-logo.png","logoAlt":"TAVISH & CO. logo"}'::jsonb, true),
('contact', '{"email":"tavishandco@gmail.com","whatsappNumber":"919137961623","whatsappDisplay":"+91 91379 61623","location":"New Kalyani Nagar, Pune, Maharashtra - 411014","locationNote":"New Kalyani Nagar, Pune, Maharashtra - 411014.","hours":"Monday – Saturday, 10:00 – 19:00 IST"}'::jsonb, true),
('commerce', '{"currency":"INR","currencySymbol":"₹","freeShippingAbove":999,"shippingFee":99,"dispatchDays":"2 – 4 working days","deliveryEstimate":"5 – 9 working days across India","returnsWindowDays":7,"cancellationWindowHours":24}'::jsonb, true),
('social', '{"instagram":"https://www.instagram.com/tavishandco_/?vrfl=MXJ6anJ6cTBjcXpjOQ%3D%3D&utm_source=qr"}'::jsonb, true),
('seo', '{"base":"https://tavishandco.example","defaultTitle":"TAVISH & CO. | Contemporary Indian Jewellery","defaultDescription":"Discover TAVISH & CO. — anti-tarnish essentials, Korean-inspired edits and festive Indian jewellery crafted in gold tones, pearls and hand-set stones. UPI payments accepted across India.","ogImage":"assets/images/hero/hero-poster.jpg"}'::jsonb, true)
on conflict (key) do nothing;
