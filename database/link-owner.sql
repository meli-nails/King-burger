-- Run after creating the owner in Supabase Auth.
-- Change the email to the intended owner address.
insert into public.admins (user_id, role, is_active)
select id, 'owner', true
from auth.users
where lower(email) = lower('soy.ibarra37@gmail.com')
on conflict (user_id) do update
set role = 'owner', is_active = true;
