-- TAVISH & CO. Supabase initial schema
-- Apply in Supabase SQL Editor after reviewing. This file is not auto-executed by GitHub Pages.
-- Do not put service-role keys or database passwords in this repository.

create extension if not exists pgcrypto;

-- Admin profiles are provisioned by a trusted project owner. Never allow a user to grant themselves admin.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null default '',
  image_path text,
  visible boolean not null default true,
  sort_order integer not null default 0,
  subcategories jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  sku text not null unique,
  slug text not null unique,
  name text not null,
  description text not null default '',
  category_id uuid references public.categories(id) on delete set null,
  category_name text,
  subcategory text,
  price_paise bigint not null default 0 check (price_paise >= 0),
  sale_price_paise bigint check (sale_price_paise is null or sale_price_paise >= 0),
  currency text not null default 'INR' check (currency = 'INR'),
  material text,
  finish text,
  dimensions text,
  weight text,
  availability text not null default 'IN_STOCK' check (availability in ('IN_STOCK','OUT_OF_STOCK','PREORDER')),
  featured boolean not null default false,
  new_arrival boolean not null default false,
  best_seller boolean not null default false,
  tags text[] not null default '{}',
  status text not null default 'DRAFT' check (status in ('ACTIVE','DRAFT','HIDDEN','TRASH')),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  storage_path text not null,
  alt_text text not null default '',
  sort_order integer not null default 0,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  unique(product_id, storage_path)
);

create table if not exists public.inventory (
  product_id uuid primary key references public.products(id) on delete cascade,
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  reserved_quantity integer not null default 0 check (reserved_quantity >= 0 and reserved_quantity <= stock_quantity),
  updated_at timestamptz not null default now()
);

create table if not exists public.store_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  is_public boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  user_id uuid references auth.users(id) on delete set null,
  customer_name text not null,
  customer_email text,
  customer_phone text not null,
  shipping_address jsonb not null default '{}'::jsonb,
  subtotal_paise bigint not null check (subtotal_paise >= 0),
  shipping_paise bigint not null default 0 check (shipping_paise >= 0),
  total_paise bigint not null check (total_paise >= 0),
  currency text not null default 'INR' check (currency = 'INR'),
  payment_method text not null default 'UPI_MANUAL',
  payment_status text not null default 'PENDING' check (payment_status in ('PENDING','PAID','FAILED','REFUNDED')),
  fulfillment_status text not null default 'PLACED' check (fulfillment_status in ('PLACED','CONFIRMED','PACKING','SHIPPED','DELIVERED','CANCELLED')),
  customer_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  sku_snapshot text not null,
  name_snapshot text not null,
  unit_price_paise bigint not null check (unit_price_paise >= 0),
  quantity integer not null check (quantity > 0),
  line_total_paise bigint not null check (line_total_paise >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  consented_at timestamptz not null default now(),
  status text not null default 'SUBSCRIBED' check (status in ('SUBSCRIBED','UNSUBSCRIBED')),
  created_at timestamptz not null default now()
);

create table if not exists public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  target_type text,
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists products_public_listing_idx on public.products(status, sort_order);
create index if not exists products_category_id_idx on public.products(category_id);
create index if not exists product_images_product_order_idx on public.product_images(product_id, sort_order);
create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists orders_user_id_idx on public.orders(user_id);
create index if not exists order_items_order_id_idx on public.order_items(order_id);
create index if not exists newsletter_status_idx on public.newsletter_subscribers(status);

-- Use a security-definer helper to avoid recursive RLS checks against profiles.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.inventory enable row level security;
alter table public.store_settings enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.newsletter_subscribers enable row level security;
alter table public.admin_audit_log enable row level security;

-- Public storefront reads only approved records.
create policy "profiles read own or admin" on public.profiles
for select to authenticated
using (id = (select auth.uid()) or (select public.is_admin()));

create policy "admin manages profiles" on public.profiles
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "public reads visible categories" on public.categories
for select to anon, authenticated
using (visible = true or (select public.is_admin()));
create policy "admin manages categories" on public.categories
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "public reads active products" on public.products
for select to anon, authenticated
using (status = 'ACTIVE' or (select public.is_admin()));
create policy "admin manages products" on public.products
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "public reads images for active products" on public.product_images
for select to anon, authenticated
using (
  exists (select 1 from public.products p where p.id = product_id and p.status = 'ACTIVE')
  or (select public.is_admin())
);
create policy "admin manages product images" on public.product_images
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "public reads stock for active products" on public.inventory
for select to anon, authenticated
using (
  exists (select 1 from public.products p where p.id = product_id and p.status = 'ACTIVE')
  or (select public.is_admin())
);
create policy "admin manages inventory" on public.inventory
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "public reads public settings" on public.store_settings
for select to anon, authenticated
using (is_public = true or (select public.is_admin()));
create policy "admin manages settings" on public.store_settings
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

-- Orders intentionally have no anonymous insert/read policy yet.
-- Add order creation through a validated Edge Function before enabling checkout.
create policy "admin manages orders" on public.orders
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));
create policy "admin manages order items" on public.order_items
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

-- Public may subscribe, but cannot read the subscriber list.
create policy "public can subscribe" on public.newsletter_subscribers
for insert to anon, authenticated
with check (
  length(trim(email)) between 5 and 320
  and position('@' in email) > 1
  and status = 'SUBSCRIBED'
);
create policy "admin manages subscribers" on public.newsletter_subscribers
for all to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy "admin reads audit log" on public.admin_audit_log
for select to authenticated
using ((select public.is_admin()));
create policy "admin inserts audit log" on public.admin_audit_log
for insert to authenticated
with check ((select public.is_admin()) and actor_id = (select auth.uid()));

-- Create a public-read bucket for catalogue images. Writes are Admin-only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-images', 'product-images', true, 5242880, array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "public reads product images" on storage.objects
for select to anon, authenticated
using (bucket_id = 'product-images');

create policy "admin uploads product images" on storage.objects
for insert to authenticated
with check (bucket_id = 'product-images' and (select public.is_admin()));

create policy "admin updates product images" on storage.objects
for update to authenticated
using (bucket_id = 'product-images' and (select public.is_admin()))
with check (bucket_id = 'product-images' and (select public.is_admin()));

create policy "admin deletes product images" on storage.objects
for delete to authenticated
using (bucket_id = 'product-images' and (select public.is_admin()));

-- Do not grant admin role through public signup. Provision the first admin profile
-- manually from the SQL Editor after creating the user in Supabase Auth.
