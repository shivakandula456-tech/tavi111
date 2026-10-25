-- TAVISH & CO. secure guest checkout RPC.
-- This function recalculates prices and shipping from database records.
-- It does not trust client-supplied amounts and always creates payment-pending orders.
alter table public.orders
  add column if not exists idempotency_key text;

create unique index if not exists orders_idempotency_key_unique
  on public.orders(idempotency_key)
  where idempotency_key is not null;

create or replace function public.create_public_order(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text;
  v_phone text;
  v_email text;
  v_address jsonb;
  v_notes text;
  v_idempotency text;
  v_item jsonb;
  v_line jsonb;
  v_product record;
  v_sku text;
  v_qty integer;
  v_unit_price bigint;
  v_subtotal bigint := 0;
  v_shipping bigint := 0;
  v_total bigint := 0;
  v_shipping_fee bigint := 9900;
  v_free_shipping bigint := 99900;
  v_commerce jsonb := '{}'::jsonb;
  v_order_items jsonb := '[]'::jsonb;
  v_order_id uuid;
  v_order_number text;
  v_existing public.orders%rowtype;
begin
  if p_payload is null or pg_catalog.jsonb_typeof(p_payload) is distinct from 'object' then
    raise exception using errcode = '22023', message = 'Invalid checkout payload.';
  end if;

  v_idempotency := nullif(pg_catalog.btrim(p_payload->>'idempotencyKey'), '');
  if v_idempotency is not null and pg_catalog.length(v_idempotency) > 100 then
    raise exception using errcode = '22023', message = 'Invalid checkout reference.';
  end if;

  if v_idempotency is not null then
    select * into v_existing
      from public.orders
      where idempotency_key = v_idempotency
      limit 1;
    if found then
      return pg_catalog.jsonb_build_object(
        'id', v_existing.id,
        'order_number', v_existing.order_number,
        'subtotal_paise', v_existing.subtotal_paise,
        'shipping_paise', v_existing.shipping_paise,
        'total_paise', v_existing.total_paise,
        'payment_status', v_existing.payment_status,
        'fulfillment_status', v_existing.fulfillment_status,
        'replayed', true
      );
    end if;
  end if;

  v_name := pg_catalog.btrim(coalesce(p_payload->'customer'->>'name', ''));
  v_phone := pg_catalog.regexp_replace(coalesce(p_payload->'customer'->>'mobile', ''), '[^0-9+]', '', 'g');
  v_email := nullif(pg_catalog.btrim(coalesce(p_payload->'customer'->>'email', '')), '');
  v_address := coalesce(p_payload->'address', '{}'::jsonb);
  v_notes := pg_catalog.left(pg_catalog.btrim(coalesce(p_payload->>'notes', '')), 1000);

  if pg_catalog.length(v_name) < 2 or pg_catalog.length(v_name) > 120 then
    raise exception using errcode = '22023', message = 'Enter a valid customer name.';
  end if;
  if pg_catalog.length(pg_catalog.regexp_replace(v_phone, '[^0-9]', '', 'g')) < 10
     or pg_catalog.length(pg_catalog.regexp_replace(v_phone, '[^0-9]', '', 'g')) > 15 then
    raise exception using errcode = '22023', message = 'Enter a valid mobile number.';
  end if;
  if v_email is not null and v_email !~* '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]{2,}$' then
    raise exception using errcode = '22023', message = 'Enter a valid email address.';
  end if;
  if pg_catalog.length(pg_catalog.btrim(coalesce(v_address->>'line1',''))) < 4
     or pg_catalog.length(pg_catalog.btrim(coalesce(v_address->>'city',''))) < 2
     or pg_catalog.length(pg_catalog.btrim(coalesce(v_address->>'state',''))) < 2
     or coalesce(v_address->>'pin','') !~ '^[0-9]{6}$' then
    raise exception using errcode = '22023', message = 'Enter a complete delivery address and six-digit PIN code.';
  end if;
  if pg_catalog.jsonb_typeof(p_payload->'items') is distinct from 'array' then
    raise exception using errcode = '22023', message = 'Your bag must contain a list of items.';
  end if;
  if pg_catalog.jsonb_array_length(p_payload->'items') < 1
     or pg_catalog.jsonb_array_length(p_payload->'items') > 30 then
    raise exception using errcode = '22023', message = 'Your bag must contain between 1 and 30 line items.';
  end if;

  select value into v_commerce
    from public.store_settings
    where key = 'commerce' and is_public = true
    limit 1;
  if v_commerce is not null then
    v_shipping_fee := greatest(0, coalesce(nullif(v_commerce->>'shippingFee','')::numeric, 99) * 100)::bigint;
    v_free_shipping := greatest(0, coalesce(nullif(v_commerce->>'freeShippingAbove','')::numeric, 999) * 100)::bigint;
  end if;

  for v_item in select value from pg_catalog.jsonb_array_elements(p_payload->'items')
  loop
    v_sku := pg_catalog.btrim(coalesce(v_item->>'sku', ''));
    if v_sku = '' or coalesce(v_item->>'quantity','') !~ '^[0-9]{1,2}$' then
      raise exception using errcode = '22023', message = 'A bag item has an invalid SKU or quantity.';
    end if;
    v_qty := (v_item->>'quantity')::integer;
    if v_qty < 1 or v_qty > 10 then
      raise exception using errcode = '22023', message = 'Each quantity must be between 1 and 10.';
    end if;

    select p.id, p.sku, p.name, p.price_paise, p.sale_price_paise, p.availability, p.status
      into v_product
      from public.products p
      where p.sku = v_sku and p.status = 'ACTIVE'
      limit 1;
    if not found then
      raise exception using errcode = '22023', message = 'A product in your bag is no longer available. Refresh your bag and try again.';
    end if;
    if v_product.availability = 'OUT_OF_STOCK' then
      raise exception using errcode = '22023', message = 'A product in your bag is out of stock. Remove it before placing the order.';
    end if;
    if not exists (select 1 from public.product_images pi where pi.product_id = v_product.id) then
      raise exception using errcode = '22023', message = 'A product in your bag has no product image and is not ready for checkout.';
    end if;

    v_unit_price := coalesce(v_product.sale_price_paise, v_product.price_paise);
    if v_unit_price < 0 then
      raise exception using errcode = '22023', message = 'The product has an invalid price.';
    end if;
    v_subtotal := v_subtotal + (v_unit_price * v_qty);
    v_order_items := v_order_items || pg_catalog.jsonb_build_array(
      pg_catalog.jsonb_build_object(
        'product_id', v_product.id,
        'sku_snapshot', v_product.sku,
        'name_snapshot', v_product.name,
        'unit_price_paise', v_unit_price,
        'quantity', v_qty,
        'line_total_paise', v_unit_price * v_qty
      )
    );
  end loop;

  if v_subtotal = 0 then
    raise exception using errcode = '22023', message = 'Your order total must be greater than zero.';
  end if;
  if v_free_shipping > 0 and v_subtotal >= v_free_shipping then
    v_shipping := 0;
  else
    v_shipping := v_shipping_fee;
  end if;
  v_total := v_subtotal + v_shipping;
  v_order_number := 'TAV-' || pg_catalog.to_char(pg_catalog.clock_timestamp(), 'YYMMDDHH24MISS') || '-' ||
                    pg_catalog.upper(pg_catalog.substr(pg_catalog.replace(pg_catalog.gen_random_uuid()::text, '-', ''), 1, 6));

  begin
    insert into public.orders (
      order_number, idempotency_key, user_id, customer_name, customer_email, customer_phone,
      shipping_address, subtotal_paise, shipping_paise, total_paise, currency,
      payment_method, payment_status, fulfillment_status, customer_note
    ) values (
      v_order_number, v_idempotency, auth.uid(), v_name, v_email, v_phone,
      v_address, v_subtotal, v_shipping, v_total, 'INR',
      'UPI_MANUAL', 'PENDING', 'PLACED', v_notes
    )
    returning id into v_order_id;
  exception when unique_violation then
    if v_idempotency is not null then
      select * into v_existing from public.orders where idempotency_key = v_idempotency limit 1;
      if found then
        return pg_catalog.jsonb_build_object(
          'id', v_existing.id,
          'order_number', v_existing.order_number,
          'subtotal_paise', v_existing.subtotal_paise,
          'shipping_paise', v_existing.shipping_paise,
          'total_paise', v_existing.total_paise,
          'payment_status', v_existing.payment_status,
          'fulfillment_status', v_existing.fulfillment_status,
          'replayed', true
        );
      end if;
    end if;
    raise;
  end;

  for v_line in select value from pg_catalog.jsonb_array_elements(v_order_items)
  loop
    insert into public.order_items (
      order_id, product_id, sku_snapshot, name_snapshot,
      unit_price_paise, quantity, line_total_paise
    ) values (
      v_order_id,
      (v_line->>'product_id')::uuid,
      v_line->>'sku_snapshot',
      v_line->>'name_snapshot',
      (v_line->>'unit_price_paise')::bigint,
      (v_line->>'quantity')::integer,
      (v_line->>'line_total_paise')::bigint
    );
  end loop;

  return pg_catalog.jsonb_build_object(
    'id', v_order_id,
    'order_number', v_order_number,
    'subtotal_paise', v_subtotal,
    'shipping_paise', v_shipping,
    'total_paise', v_total,
    'payment_status', 'PENDING',
    'fulfillment_status', 'PLACED',
    'replayed', false
  );
end;
$$;

revoke all on function public.create_public_order(jsonb) from public;
grant execute on function public.create_public_order(jsonb) to anon, authenticated;
