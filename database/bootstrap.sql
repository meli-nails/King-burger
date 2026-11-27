-- King Burger database bootstrap
-- Snapshot of the active Supabase schema as of 2026-11-27.
-- Run ONCE in SQL Editor on a NEW, EMPTY Supabase project.
-- Do not run this on the already-provisioned production project.
begin;

CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
begin
  new.updated_at = pg_catalog.now();
  return new;
end;
$function$


CREATE TABLE IF NOT EXISTS public.admins (user_id uuid NOT NULL, role text DEFAULT 'staff'::text NOT NULL, is_active boolean DEFAULT true NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.api_rate_limits (bucket text NOT NULL, window_started_at timestamp with time zone DEFAULT now() NOT NULL, hit_count integer DEFAULT 0 NOT NULL);
CREATE TABLE IF NOT EXISTS public.business_settings (id integer DEFAULT 1 NOT NULL, business_name text DEFAULT 'King Burger'::text NOT NULL, whatsapp_phone text, contact_email text, logo_url text, is_open boolean DEFAULT false NOT NULL, minimum_order numeric DEFAULT 0 NOT NULL, currency text DEFAULT 'ARS'::text NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL, transfer_alias text, transfer_holder text, transfer_cbu text, delivery_only boolean DEFAULT true NOT NULL);
CREATE TABLE IF NOT EXISTS public.categories (id uuid DEFAULT gen_random_uuid() NOT NULL, name text NOT NULL, slug text NOT NULL, description text, image_url text, is_active boolean DEFAULT true NOT NULL, sort_order integer DEFAULT 0 NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.delivery_zones (id uuid DEFAULT gen_random_uuid() NOT NULL, name text NOT NULL, delivery_fee numeric DEFAULT 0 NOT NULL, estimated_minutes integer DEFAULT 45 NOT NULL, is_active boolean DEFAULT true NOT NULL, sort_order integer DEFAULT 0 NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.order_item_addons (id uuid DEFAULT gen_random_uuid() NOT NULL, order_item_id uuid NOT NULL, addon_id uuid, addon_name text NOT NULL, unit_price numeric DEFAULT 0 NOT NULL, quantity integer DEFAULT 1 NOT NULL);
CREATE TABLE IF NOT EXISTS public.order_items (id uuid DEFAULT gen_random_uuid() NOT NULL, order_id uuid NOT NULL, product_id uuid, product_name text NOT NULL, unit_price numeric NOT NULL, quantity integer NOT NULL, subtotal numeric NOT NULL, notes text);
CREATE TABLE IF NOT EXISTS public.order_status_history (id uuid DEFAULT gen_random_uuid() NOT NULL, order_id uuid NOT NULL, previous_status text, new_status text NOT NULL, changed_by uuid, note text, created_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.orders (id uuid DEFAULT gen_random_uuid() NOT NULL, order_number bigint GENERATED ALWAYS AS IDENTITY NOT NULL, tracking_token_hash text NOT NULL, customer_name text NOT NULL, customer_phone text NOT NULL, delivery_address text NOT NULL, neighborhood text NOT NULL, address_reference text, delivery_zone_id uuid, subtotal numeric NOT NULL, delivery_fee numeric DEFAULT 0 NOT NULL, total numeric NOT NULL, payment_method text NOT NULL, payment_status text DEFAULT 'pending'::text NOT NULL, order_status text DEFAULT 'pending'::text NOT NULL, customer_notes text, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL, idempotency_key text, customer_email text);
CREATE TABLE IF NOT EXISTS public.product_addon_options (id uuid DEFAULT gen_random_uuid() NOT NULL, addon_id uuid NOT NULL, product_id uuid NOT NULL, option_name text NOT NULL, price numeric DEFAULT 0 NOT NULL, is_available boolean DEFAULT true NOT NULL, sort_order integer DEFAULT 0 NOT NULL);
CREATE TABLE IF NOT EXISTS public.product_addons (id uuid DEFAULT gen_random_uuid() NOT NULL, name text NOT NULL, description text, is_active boolean DEFAULT true NOT NULL, is_required boolean DEFAULT false NOT NULL, min_select integer DEFAULT 0 NOT NULL, max_select integer DEFAULT 1 NOT NULL, sort_order integer DEFAULT 0 NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.products (id uuid DEFAULT gen_random_uuid() NOT NULL, category_id uuid, name text NOT NULL, description text, image_url text, price numeric NOT NULL, is_available boolean DEFAULT true NOT NULL, is_featured boolean DEFAULT false NOT NULL, sort_order integer DEFAULT 0 NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL, updated_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.promotions (id uuid DEFAULT gen_random_uuid() NOT NULL, name text NOT NULL, description text, discount_type text NOT NULL, discount_value numeric NOT NULL, starts_at timestamp with time zone, ends_at timestamp with time zone, is_active boolean DEFAULT true NOT NULL, created_at timestamp with time zone DEFAULT now() NOT NULL);
CREATE TABLE IF NOT EXISTS public.working_hours (id uuid DEFAULT gen_random_uuid() NOT NULL, day_of_week integer NOT NULL, opens_at time without time zone, closes_at time without time zone, is_closed boolean DEFAULT false NOT NULL);

ALTER TABLE ONLY public.admins ADD CONSTRAINT admins_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public.admins ADD CONSTRAINT admins_role_check CHECK ((role = ANY (ARRAY['owner'::text, 'staff'::text])));
ALTER TABLE ONLY public.api_rate_limits ADD CONSTRAINT api_rate_limits_hit_count_check CHECK ((hit_count >= 0));
ALTER TABLE ONLY public.api_rate_limits ADD CONSTRAINT api_rate_limits_pkey PRIMARY KEY (bucket);
ALTER TABLE ONLY public.business_settings ADD CONSTRAINT business_settings_id_check CHECK ((id = 1));
ALTER TABLE ONLY public.business_settings ADD CONSTRAINT business_settings_minimum_order_check CHECK ((minimum_order >= (0)::numeric));
ALTER TABLE ONLY public.business_settings ADD CONSTRAINT business_settings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.categories ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.categories ADD CONSTRAINT categories_slug_key UNIQUE (slug);
ALTER TABLE ONLY public.delivery_zones ADD CONSTRAINT delivery_zones_delivery_fee_check CHECK ((delivery_fee >= (0)::numeric));
ALTER TABLE ONLY public.delivery_zones ADD CONSTRAINT delivery_zones_estimated_minutes_check CHECK ((estimated_minutes > 0));
ALTER TABLE ONLY public.delivery_zones ADD CONSTRAINT delivery_zones_name_key UNIQUE (name);
ALTER TABLE ONLY public.delivery_zones ADD CONSTRAINT delivery_zones_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.order_item_addons ADD CONSTRAINT order_item_addons_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.order_item_addons ADD CONSTRAINT order_item_addons_quantity_check CHECK ((quantity > 0));
ALTER TABLE ONLY public.order_item_addons ADD CONSTRAINT order_item_addons_unit_price_check CHECK ((unit_price >= (0)::numeric));
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_quantity_check CHECK ((quantity > 0));
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_subtotal_check CHECK ((subtotal >= (0)::numeric));
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_unit_price_check CHECK ((unit_price >= (0)::numeric));
ALTER TABLE ONLY public.order_status_history ADD CONSTRAINT order_status_history_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_delivery_fee_check CHECK ((delivery_fee >= (0)::numeric));
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_order_number_key UNIQUE (order_number);
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_order_status_check CHECK ((order_status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'preparing'::text, 'ready'::text, 'on_the_way'::text, 'delivered'::text, 'cancelled'::text])));
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_payment_method_check CHECK ((payment_method = ANY (ARRAY['cash'::text, 'transfer'::text])));
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_payment_status_check CHECK ((payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'rejected'::text, 'refunded'::text])));
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_subtotal_check CHECK ((subtotal >= (0)::numeric));
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_total_check CHECK ((total >= (0)::numeric));
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_tracking_token_hash_key UNIQUE (tracking_token_hash);
ALTER TABLE ONLY public.product_addon_options ADD CONSTRAINT product_addon_options_addon_id_product_id_option_name_key UNIQUE (addon_id, product_id, option_name);
ALTER TABLE ONLY public.product_addon_options ADD CONSTRAINT product_addon_options_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.product_addon_options ADD CONSTRAINT product_addon_options_price_check CHECK ((price >= (0)::numeric));
ALTER TABLE ONLY public.product_addons ADD CONSTRAINT product_addons_check CHECK ((max_select >= min_select));
ALTER TABLE ONLY public.product_addons ADD CONSTRAINT product_addons_min_select_check CHECK ((min_select >= 0));
ALTER TABLE ONLY public.product_addons ADD CONSTRAINT product_addons_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.products ADD CONSTRAINT products_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.products ADD CONSTRAINT products_price_check CHECK ((price >= (0)::numeric));
ALTER TABLE ONLY public.promotions ADD CONSTRAINT promotions_check CHECK (((ends_at IS NULL) OR (starts_at IS NULL) OR (ends_at > starts_at)));
ALTER TABLE ONLY public.promotions ADD CONSTRAINT promotions_discount_type_check CHECK ((discount_type = ANY (ARRAY['fixed'::text, 'percent'::text])));
ALTER TABLE ONLY public.promotions ADD CONSTRAINT promotions_discount_value_check CHECK ((discount_value > (0)::numeric));
ALTER TABLE ONLY public.promotions ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.working_hours ADD CONSTRAINT working_hours_check CHECK ((is_closed OR ((opens_at IS NOT NULL) AND (closes_at IS NOT NULL))));
ALTER TABLE ONLY public.working_hours ADD CONSTRAINT working_hours_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6)));
ALTER TABLE ONLY public.working_hours ADD CONSTRAINT working_hours_day_of_week_key UNIQUE (day_of_week);
ALTER TABLE ONLY public.working_hours ADD CONSTRAINT working_hours_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.admins ADD CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.order_item_addons ADD CONSTRAINT order_item_addons_addon_id_fkey FOREIGN KEY (addon_id) REFERENCES product_addons(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.order_item_addons ADD CONSTRAINT order_item_addons_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.order_items ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.order_status_history ADD CONSTRAINT order_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.order_status_history ADD CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.orders ADD CONSTRAINT orders_delivery_zone_id_fkey FOREIGN KEY (delivery_zone_id) REFERENCES delivery_zones(id) ON DELETE SET NULL;
ALTER TABLE ONLY public.product_addon_options ADD CONSTRAINT product_addon_options_addon_id_fkey FOREIGN KEY (addon_id) REFERENCES product_addons(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.product_addon_options ADD CONSTRAINT product_addon_options_product_id_fkey FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

CREATE INDEX order_item_addons_addon_id_idx ON public.order_item_addons USING btree (addon_id);
CREATE INDEX order_item_addons_order_item_id_idx ON public.order_item_addons USING btree (order_item_id);
CREATE INDEX order_items_order_idx ON public.order_items USING btree (order_id);
CREATE INDEX order_items_product_id_idx ON public.order_items USING btree (product_id);
CREATE INDEX order_history_order_idx ON public.order_status_history USING btree (order_id, created_at);
CREATE INDEX order_status_history_changed_by_idx ON public.order_status_history USING btree (changed_by);
CREATE INDEX orders_created_idx ON public.orders USING btree (created_at DESC);
CREATE INDEX orders_status_idx ON public.orders USING btree (order_status, created_at DESC);
CREATE UNIQUE INDEX orders_idempotency_key_uidx ON public.orders USING btree (idempotency_key);
CREATE INDEX orders_delivery_zone_id_idx ON public.orders USING btree (delivery_zone_id);
CREATE INDEX product_addon_options_product_id_idx ON public.product_addon_options USING btree (product_id);
CREATE INDEX products_category_idx ON public.products USING btree (category_id);
CREATE INDEX products_available_idx ON public.products USING btree (is_available, sort_order);

CREATE OR REPLACE FUNCTION public.create_order_secure(p_payload jsonb, p_tracking_token_hash text, p_idempotency_key text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
declare
  v_order_id uuid; v_order_number bigint; v_existing_hash text;
  v_customer_name text; v_customer_phone text; v_customer_email text;
  v_address text; v_neighborhood text; v_reference text; v_zone_id uuid;
  v_payment_method text; v_notes text;
  v_subtotal numeric(12,2) := 0; v_delivery_fee numeric(12,2) := 0;
  v_total numeric(12,2) := 0; v_minimum numeric(12,2) := 0;
  v_business_open boolean := false;
  v_line jsonb; v_addons jsonb; v_product_id uuid; v_product_name text;
  v_base_price numeric(12,2); v_quantity integer; v_addon_count integer;
  v_valid_addon_count integer; v_addon_unit_total numeric(12,2);
  v_line_total numeric(12,2); v_invalid_groups boolean;
  v_order_item_id uuid; v_option_id uuid; v_option_name text;
  v_option_price numeric(12,2); v_addon_id uuid; v_item_count integer;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception using errcode = '42501', message = 'not_authorized';
  end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception using errcode = '22023', message = 'invalid_payload';
  end if;
  if p_tracking_token_hash is null or p_tracking_token_hash !~ '^[a-f0-9]{64}$' then
    raise exception using errcode = '22023', message = 'invalid_tracking_token';
  end if;
  if p_idempotency_key is null or length(p_idempotency_key) < 16 or length(p_idempotency_key) > 100 then
    raise exception using errcode = '22023', message = 'invalid_idempotency_key';
  end if;

  select o.id,o.order_number,o.total,o.tracking_token_hash
    into v_order_id,v_order_number,v_total,v_existing_hash
  from public.orders o where o.idempotency_key=p_idempotency_key limit 1;
  if v_order_id is not null then
    if v_existing_hash <> p_tracking_token_hash then
      raise exception using errcode = '23505', message = 'idempotency_conflict';
    end if;
    return jsonb_build_object('order_id',v_order_id,'order_number',v_order_number,'total',v_total,'idempotent_replay',true);
  end if;

  v_customer_name := nullif(btrim(p_payload->>'customer_name'),'');
  v_customer_phone := nullif(btrim(p_payload->>'customer_phone'),'');
  v_customer_email := nullif(lower(btrim(p_payload->>'customer_email')),'');
  v_address := nullif(btrim(p_payload->>'delivery_address'),'');
  v_neighborhood := nullif(btrim(p_payload->>'neighborhood'),'');
  v_reference := nullif(btrim(p_payload->>'address_reference'),'');
  v_notes := nullif(btrim(p_payload->>'customer_notes'),'');
  v_payment_method := p_payload->>'payment_method';

  if v_customer_name is null or length(v_customer_name)>100
     or v_customer_phone is null or length(v_customer_phone)>30
     or v_address is null or length(v_address)>220
     or v_neighborhood is null or length(v_neighborhood)>100 then
    raise exception using errcode = '22023', message = 'missing_customer_details';
  end if;
  if v_customer_email is not null and (length(v_customer_email)>254 or position('@' in v_customer_email)<2) then
    raise exception using errcode = '22023', message = 'invalid_email';
  end if;
  if v_payment_method not in ('cash','transfer') then
    raise exception using errcode = '22023', message = 'invalid_payment_method';
  end if;
  if jsonb_typeof(p_payload->'items') <> 'array' then
    raise exception using errcode = '22023', message = 'invalid_items';
  end if;
  select count(*) into v_item_count from jsonb_array_elements(p_payload->'items') as i(value);
  if v_item_count < 1 or v_item_count > 30 then
    raise exception using errcode = '22023', message = 'invalid_items_count';
  end if;

  begin
    v_zone_id := (p_payload->>'delivery_zone_id')::uuid;
  exception when others then
    raise exception using errcode = '22023', message = 'invalid_delivery_zone';
  end;

  select s.is_open,s.minimum_order into v_business_open,v_minimum
  from public.business_settings s where s.id=1;
  if not coalesce(v_business_open,false) then
    raise exception using errcode = 'P0001', message = 'business_closed';
  end if;
  select z.delivery_fee into v_delivery_fee
  from public.delivery_zones z where z.id=v_zone_id and z.is_active=true;
  if not found then
    raise exception using errcode = '22023', message = 'invalid_delivery_zone';
  end if;

  for v_line in select i.value from jsonb_array_elements(p_payload->'items') as i(value)
  loop
    begin
      v_product_id := (v_line->>'product_id')::uuid;
      v_quantity := (v_line->>'quantity')::integer;
    exception when others then
      raise exception using errcode = '22023', message = 'invalid_product_line';
    end;
    if v_quantity < 1 or v_quantity > 20 then
      raise exception using errcode = '22023', message = 'invalid_quantity';
    end if;
    select p.name,p.price into v_product_name,v_base_price
    from public.products p where p.id=v_product_id and p.is_available=true;
    if not found then raise exception using errcode = '22023', message = 'product_unavailable'; end if;

    v_addons := coalesce(v_line->'addons','[]'::jsonb);
    if jsonb_typeof(v_addons)<>'array' then raise exception using errcode = '22023', message = 'invalid_addons'; end if;
    select count(*) into v_addon_count from jsonb_array_elements(v_addons) as a(value);
    if v_addon_count>15 then raise exception using errcode = '22023', message = 'too_many_addons'; end if;
    select count(distinct a.value->>'option_id') into v_valid_addon_count
    from jsonb_array_elements(v_addons) as a(value);
    if v_valid_addon_count<>v_addon_count then raise exception using errcode = '22023', message = 'duplicate_addons'; end if;

    select count(*) into v_valid_addon_count
    from jsonb_array_elements(v_addons) as a(value)
    join public.product_addon_options po on po.id=(a.value->>'option_id')::uuid
      and po.product_id=v_product_id and po.is_available=true
    join public.product_addons pa on pa.id=po.addon_id and pa.is_active=true;
    if v_valid_addon_count<>v_addon_count then raise exception using errcode = '22023', message = 'addon_unavailable'; end if;

    select exists (
      select 1 from public.product_addons pa
      where pa.is_active=true
        and exists(select 1 from public.product_addon_options po where po.product_id=v_product_id and po.addon_id=pa.id)
        and (
          (select count(*) from public.product_addon_options po where po.product_id=v_product_id and po.addon_id=pa.id
            and po.is_available=true and po.id::text in (select a.value->>'option_id' from jsonb_array_elements(v_addons) as a(value))) > pa.max_select
          or
          (select count(*) from public.product_addon_options po where po.product_id=v_product_id and po.addon_id=pa.id
            and po.is_available=true and po.id::text in (select a.value->>'option_id' from jsonb_array_elements(v_addons) as a(value))) < pa.min_select
          or
          (pa.is_required and (select count(*) from public.product_addon_options po where po.product_id=v_product_id and po.addon_id=pa.id
            and po.is_available=true and po.id::text in (select a.value->>'option_id' from jsonb_array_elements(v_addons) as a(value)))=0)
        )
    ) into v_invalid_groups;
    if coalesce(v_invalid_groups,false) then raise exception using errcode = '22023', message = 'addon_selection_out_of_range'; end if;

    select coalesce(sum(po.price),0) into v_addon_unit_total
    from public.product_addon_options po
    where po.product_id=v_product_id and po.is_available=true
      and po.id::text in (select a.value->>'option_id' from jsonb_array_elements(v_addons) as a(value));
    v_line_total := (v_base_price+v_addon_unit_total)*v_quantity;
    v_subtotal := v_subtotal+v_line_total;
  end loop;

  if v_subtotal<coalesce(v_minimum,0) then raise exception using errcode = '22023', message = 'minimum_order_not_met'; end if;
  v_total := v_subtotal+v_delivery_fee;

  insert into public.orders(idempotency_key,tracking_token_hash,customer_name,customer_phone,customer_email,
    delivery_address,neighborhood,address_reference,delivery_zone_id,subtotal,delivery_fee,total,
    payment_method,payment_status,order_status,customer_notes)
  values(p_idempotency_key,p_tracking_token_hash,v_customer_name,v_customer_phone,v_customer_email,
    v_address,v_neighborhood,v_reference,v_zone_id,v_subtotal,v_delivery_fee,v_total,
    v_payment_method,'pending','pending',v_notes)
  on conflict(idempotency_key) do nothing
  returning id,order_number into v_order_id,v_order_number;

  if v_order_id is null then
    select o.id,o.order_number,o.total,o.tracking_token_hash into v_order_id,v_order_number,v_total,v_existing_hash
    from public.orders o where o.idempotency_key=p_idempotency_key;
    if v_existing_hash<>p_tracking_token_hash then raise exception using errcode = '23505', message = 'idempotency_conflict'; end if;
    return jsonb_build_object('order_id',v_order_id,'order_number',v_order_number,'total',v_total,'idempotent_replay',true);
  end if;

  for v_line in select i.value from jsonb_array_elements(p_payload->'items') as i(value)
  loop
    v_product_id := (v_line->>'product_id')::uuid;
    v_quantity := (v_line->>'quantity')::integer;
    v_addons := coalesce(v_line->'addons','[]'::jsonb);
    select p.name,p.price into v_product_name,v_base_price from public.products p where p.id=v_product_id;
    select coalesce(sum(po.price),0) into v_addon_unit_total
    from public.product_addon_options po where po.product_id=v_product_id
      and po.id::text in (select a.value->>'option_id' from jsonb_array_elements(v_addons) as a(value));
    v_line_total := (v_base_price+v_addon_unit_total)*v_quantity;
    insert into public.order_items(order_id,product_id,product_name,unit_price,quantity,subtotal,notes)
    values(v_order_id,v_product_id,v_product_name,v_base_price,v_quantity,v_line_total,
      nullif(left(btrim(coalesce(v_line->>'notes','')),300),'')) returning id into v_order_item_id;

    for v_option_id,v_addon_id,v_option_name,v_option_price in
      select po.id,po.addon_id,po.option_name,po.price from public.product_addon_options po
      where po.product_id=v_product_id and po.id::text in
        (select a.value->>'option_id' from jsonb_array_elements(v_addons) as a(value))
    loop
      insert into public.order_item_addons(order_item_id,addon_id,addon_name,unit_price,quantity)
      values(v_order_item_id,v_addon_id,v_option_name,v_option_price,v_quantity);
    end loop;
  end loop;

  insert into public.order_status_history(order_id,previous_status,new_status,note)
  values(v_order_id,null,'pending','Pedido recibido desde la tienda online');

  return jsonb_build_object('order_id',v_order_id,'order_number',v_order_number,'subtotal',v_subtotal,
    'delivery_fee',v_delivery_fee,'total',v_total,'idempotent_replay',false);
end;
$function$


CREATE OR REPLACE FUNCTION public.take_api_limit(p_bucket text, p_max_hits integer DEFAULT 12, p_window_seconds integer DEFAULT 60)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
declare v_hits integer;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception using errcode = '42501', message = 'not_authorized';
  end if;
  if p_bucket is null or length(p_bucket) < 8 or length(p_bucket) > 180
     or p_max_hits < 1 or p_max_hits > 1000
     or p_window_seconds < 1 or p_window_seconds > 86400 then
    raise exception using errcode = '22023', message = 'invalid_rate_limit_parameters';
  end if;
  insert into public.api_rate_limits(bucket, window_started_at, hit_count)
  values (p_bucket, now(), 1)
  on conflict (bucket) do update
    set window_started_at = case
      when public.api_rate_limits.window_started_at + make_interval(secs => p_window_seconds) <= now()
      then now() else public.api_rate_limits.window_started_at end,
    hit_count = case
      when public.api_rate_limits.window_started_at + make_interval(secs => p_window_seconds) <= now()
      then 1 else public.api_rate_limits.hit_count + 1 end
  returning hit_count into v_hits;
  return v_hits <= p_max_hits;
end;
$function$


REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.create_order_secure(jsonb,text,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_order_secure(jsonb,text,text) TO service_role;
REVOKE ALL ON FUNCTION public.take_api_limit(text,integer,integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.take_api_limit(text,integer,integer) TO service_role;

GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.admins TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.api_rate_limits TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.business_settings TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.categories TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.delivery_zones TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.order_item_addons TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.order_items TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.order_status_history TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.orders TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.product_addon_options TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.product_addons TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.products TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.promotions TO service_role;
GRANT DELETE, INSERT, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE public.working_hours TO service_role;

ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_item_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_addon_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.working_hours ENABLE ROW LEVEL SECURITY;

CREATE POLICY admins_read_own ON public.admins AS PERMISSIVE FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));
CREATE POLICY api_rate_limits_deny_public ON public.api_rate_limits AS PERMISSIVE FOR ALL TO anon, authenticated USING (false) WITH CHECK (false);
CREATE POLICY admin_manage_settings ON public.business_settings AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_categories ON public.categories AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_zones ON public.delivery_zones AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_order_item_addons ON public.order_item_addons AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_order_items ON public.order_items AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_order_history ON public.order_status_history AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_orders ON public.orders AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_addon_options ON public.product_addon_options AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_addons ON public.product_addons AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_products ON public.products AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_promotions ON public.promotions AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));
CREATE POLICY admin_manage_hours ON public.working_hours AS PERMISSIVE FOR ALL TO authenticated USING ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM admins a
  WHERE ((a.user_id = ( SELECT auth.uid() AS uid)) AND a.is_active))));

CREATE TRIGGER business_settings_updated_at BEFORE UPDATE ON business_settings FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER delivery_zones_updated_at BEFORE UPDATE ON delivery_zones FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER product_addons_updated_at BEFORE UPDATE ON product_addons FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION set_updated_at();

INSERT INTO public.business_settings (id,business_name,is_open,minimum_order,currency,delivery_only)
VALUES (1,'King Burger',false,0,'ARS',true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.categories (name,slug,description,is_active,sort_order)
VALUES
 ('Hamburguesas','hamburguesas','Hamburguesas de la casa',true,10),
 ('Combos','combos','Combos y menús',true,20),
 ('Acompañamientos','acompanamientos','Papas y acompañamientos',true,30),
 ('Bebidas','bebidas','Bebidas',true,40)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.admins (user_id,role,is_active)
SELECT id,'owner',true FROM auth.users
WHERE lower(email)=lower('soy.ibarra37@gmail.com')
ON CONFLICT (user_id) DO UPDATE SET role='owner',is_active=true;

COMMIT;
