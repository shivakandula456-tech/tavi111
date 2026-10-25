-- TAVISH & CO. customer account/profile support.
alter table public.profiles add column if not exists phone text;

create or replace function public.handle_new_customer_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    'customer'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_tavish_profile on auth.users;
create trigger on_auth_user_created_tavish_profile
after insert on auth.users
for each row execute function public.handle_new_customer_profile();

drop policy if exists "customer updates own profile" on public.profiles;
create policy "customer updates own profile" on public.profiles
for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()) and role = 'customer');

drop policy if exists "customer reads own orders" on public.orders;
create policy "customer reads own orders" on public.orders
for select to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "customer reads own order items" on public.order_items;
create policy "customer reads own order items" on public.order_items
for select to authenticated
using (
  exists (
    select 1 from public.orders o
    where o.id = order_id and o.user_id = (select auth.uid())
  )
);
