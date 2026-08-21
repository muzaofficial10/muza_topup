-- =====================================================================
-- MUZA TOP-UP — Supabase / PostgreSQL Schema
-- =====================================================================
-- Run this in the Supabase SQL editor (Project > SQL Editor > New query).
-- Safe to re-run: uses IF NOT EXISTS / CREATE OR REPLACE where possible.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Extensions
-- ---------------------------------------------------------------------
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- 1. PROFILES (extends Supabase auth.users)
-- ---------------------------------------------------------------------
-- Supabase manages auth.users itself (email, password hash, etc).
-- We keep app-specific fields (full_name, phone, is_admin) here,
-- 1:1 linked by id = auth.users.id.
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  full_name     text not null default '',
  phone         text not null default '',
  email         text,
  is_admin      boolean not null default false,
  created_at    timestamptz not null default now()
);

comment on table public.profiles is 'App-level user profile data (maps to users table in the spec).';

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'phone', ''),
    new.email
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 2. PACKAGES (admin-editable product catalog)
-- ---------------------------------------------------------------------
create table if not exists public.packages (
  id          uuid primary key default uuid_generate_v4(),
  game        text not null check (game in ('pubg','efootball')),
  name        text not null,
  amount      integer not null check (amount > 0),
  price       numeric(10,2) not null check (price >= 0),
  is_active   boolean not null default true,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. ORDERS
-- ---------------------------------------------------------------------
create table if not exists public.orders (
  id                    uuid primary key default uuid_generate_v4(),
  user_id               uuid not null references public.profiles(id) on delete cascade default auth.uid(),
  game                  text not null check (game in ('pubg','efootball')),

  -- PUBG-specific
  player_id             text,

  -- eFootball-specific (sensitive — locked down by RLS below;
  -- consider encrypting at rest via Supabase Vault / pgsodium for
  -- production use rather than storing plaintext)
  efootball_email       text,
  efootball_password    text,

  package_name          text not null,
  package_amount        integer not null default 0,
  amount                numeric(10,2) not null check (amount >= 0),

  payment_screenshot    text,          -- storage path, not public URL
  payment_method        text not null,

  status                text not null default 'pending'
                          check (status in ('pending','processing','completed','cancelled')),
  admin_note            text,

  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  constraint order_has_game_specific_data check (
    (game = 'pubg' and player_id is not null)
    or
    (game = 'efootball' and efootball_email is not null)
  )
);

create index if not exists idx_orders_user_id on public.orders(user_id);
create index if not exists idx_orders_status on public.orders(status);
create index if not exists idx_orders_created_at on public.orders(created_at desc);

-- keep updated_at fresh
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_orders_updated_at on public.orders;
create trigger trg_orders_updated_at
  before update on public.orders
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 4. PAYMENTS (optional secondary ledger — mirrors spec's `payments` table)
-- ---------------------------------------------------------------------
create table if not exists public.payments (
  id          uuid primary key default uuid_generate_v4(),
  order_id    uuid not null references public.orders(id) on delete cascade,
  screenshot  text,
  status      text not null default 'pending'
               check (status in ('pending','verified','rejected')),
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 5. ANNOUNCEMENTS (for in-app announcements feature)
-- ---------------------------------------------------------------------
create table if not exists public.announcements (
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  message     text not null,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

-- =====================================================================
-- ROW LEVEL SECURITY
-- =====================================================================
alter table public.profiles      enable row level security;
alter table public.packages      enable row level security;
alter table public.orders        enable row level security;
alter table public.payments      enable row level security;
alter table public.announcements enable row level security;

-- Helper: is the current user an admin?
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

-- ---- profiles ----
drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles
  for select using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- ---- packages ----
drop policy if exists "packages_select_active_public" on public.packages;
create policy "packages_select_active_public" on public.packages
  for select using (is_active = true or public.is_admin());

drop policy if exists "packages_admin_write" on public.packages;
create policy "packages_admin_write" on public.packages
  for all using (public.is_admin()) with check (public.is_admin());

-- ---- orders ----
-- Customers can create their own orders. user_id is forced to auth.uid()
-- via the check clause so a client cannot submit an order on someone
-- else's behalf even if it tries to spoof user_id in the payload.
drop policy if exists "orders_insert_own" on public.orders;
create policy "orders_insert_own" on public.orders
  for insert with check (user_id = auth.uid());

drop policy if exists "orders_select_own_or_admin" on public.orders;
create policy "orders_select_own_or_admin" on public.orders
  for select using (user_id = auth.uid() or public.is_admin());

-- Customers may only cancel their own PENDING orders; every other status
-- transition (processing/completed/cancel-after-pending) is admin-only.
drop policy if exists "orders_update_own_pending_cancel" on public.orders;
create policy "orders_update_own_pending_cancel" on public.orders
  for update using (user_id = auth.uid() and status = 'pending')
  with check (user_id = auth.uid() and status = 'cancelled');

drop policy if exists "orders_admin_update" on public.orders;
create policy "orders_admin_update" on public.orders
  for update using (public.is_admin()) with check (public.is_admin());

drop policy if exists "orders_admin_delete" on public.orders;
create policy "orders_admin_delete" on public.orders
  for delete using (public.is_admin());

-- ---- payments ----
drop policy if exists "payments_select_own_or_admin" on public.payments;
create policy "payments_select_own_or_admin" on public.payments
  for select using (
    public.is_admin()
    or exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
  );

drop policy if exists "payments_admin_write" on public.payments;
create policy "payments_admin_write" on public.payments
  for all using (public.is_admin()) with check (public.is_admin());

-- ---- announcements ----
drop policy if exists "announcements_select_active" on public.announcements;
create policy "announcements_select_active" on public.announcements
  for select using (is_active = true or public.is_admin());

drop policy if exists "announcements_admin_write" on public.announcements;
create policy "announcements_admin_write" on public.announcements
  for all using (public.is_admin()) with check (public.is_admin());

-- =====================================================================
-- STORAGE — payment screenshots (private bucket)
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('payment-screenshots', 'payment-screenshots', false)
on conflict (id) do nothing;

-- Users may upload only into a folder named after their own uid:
--   {user_id}/{filename}
drop policy if exists "screenshot_upload_own_folder" on storage.objects;
create policy "screenshot_upload_own_folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'payment-screenshots'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "screenshot_read_own_or_admin" on storage.objects;
create policy "screenshot_read_own_or_admin" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'payment-screenshots'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_admin()
    )
  );

-- =====================================================================
-- SEED DATA — default packages (matches spec)
-- =====================================================================
insert into public.packages (game, name, amount, price, sort_order) values
  ('pubg', '60 UC',    60,    0.99,  1),
  ('pubg', '325 UC',   325,   4.99,  2),
  ('pubg', '660 UC',   660,   9.99,  3),
  ('pubg', '1800 UC',  1800,  24.99, 4),
  ('pubg', '3850 UC',  3850,  49.99, 5),
  ('pubg', '8100 UC',  8100,  99.99, 6),
  ('efootball', '130 Coins',   130,   1.99,   1),
  ('efootball', '550 Coins',   550,   7.99,   2),
  ('efootball', '1040 Coins',  1040,  14.99,  3),
  ('efootball', '2130 Coins',  2130,  27.99,  4),
  ('efootball', '3250 Coins',  3250,  39.99,  5),
  ('efootball', '5700 Coins',  5700,  64.99,  6),
  ('efootball', '12800 Coins', 12800, 129.99, 7)
on conflict do nothing;

-- =====================================================================
-- MAKE A USER ADMIN
-- =====================================================================
-- After a user has signed up normally through the app, run:
--   update public.profiles set is_admin = true where email = 'admin@example.com';
-- =====================================================================
