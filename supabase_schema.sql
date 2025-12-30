-- =====================================================
-- Noor Shams Mobile - Complete Supabase Schema
-- =====================================================

-- =====================================================
-- 1. USERS TABLE (جدول المستخدمين)
-- =====================================================
create table public.users (
  id uuid references auth.users not null primary key,
  name text not null,
  email text,
  phone text,
  role text default 'client' check (role in ('client', 'provider')),
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.users enable row level security;

create policy "Enable insert for authenticated users only" on public.users
  for insert with check (auth.uid() = id);

create policy "Enable read access for own user" on public.users
  for select using (auth.uid() = id);

create policy "Enable update for own user" on public.users
  for update using (auth.uid() = id);

-- Allow providers to be viewed by clients (for channel display)
create policy "Allow viewing providers" on public.users
  for select using (role = 'provider');

-- =====================================================
-- 2. CHANNELS TABLE (جدول القنوات)
-- =====================================================
create table public.channels (
  id uuid default gen_random_uuid() primary key,
  provider_id uuid references public.users(id) on delete cascade not null,
  name text not null,
  description text,
  cover_image_url text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_channels_provider on public.channels(provider_id);
create index idx_channels_active on public.channels(is_active) where is_active = true;

alter table public.channels enable row level security;

-- Providers can do everything with their own channels
create policy "Providers can manage their own channels" on public.channels
  for all using (auth.uid() = provider_id);

-- Everyone can view active channels
create policy "Everyone can view active channels" on public.channels
  for select using (is_active = true);

-- =====================================================
-- 3. OFFERS TABLE (جدول العروض)
-- =====================================================
create table public.offers (
  id uuid default gen_random_uuid() primary key,
  channel_id uuid references public.channels(id) on delete cascade not null,
  provider_id uuid references public.users(id) on delete cascade not null,
  title text not null,
  description text,
  price decimal(10,2) not null check (price >= 0),
  duration_days int check (duration_days > 0),
  image_url text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_offers_channel on public.offers(channel_id);
create index idx_offers_provider on public.offers(provider_id);
create index idx_offers_active on public.offers(is_active) where is_active = true;

alter table public.offers enable row level security;

-- Providers can manage their own offers
create policy "Providers can manage their own offers" on public.offers
  for all using (auth.uid() = provider_id);

-- Everyone can view active offers from active channels
create policy "Everyone can view active offers" on public.offers
  for select using (
    is_active = true 
    and exists (
      select 1 from public.channels 
      where id = channel_id and is_active = true
    )
  );

-- =====================================================
-- 4. ORDERS TABLE (جدول الطلبات)
-- =====================================================
create table public.orders (
  id uuid default gen_random_uuid() primary key,
  offer_id uuid references public.offers(id) on delete set null,
  channel_id uuid references public.channels(id) on delete cascade not null,
  client_id uuid references public.users(id) on delete cascade not null,
  provider_id uuid references public.users(id) on delete cascade not null,
  status text default 'pending' check (status in ('pending', 'accepted', 'rejected', 'completed', 'cancelled')),
  proposed_price decimal(10,2) check (proposed_price >= 0),
  client_notes text,
  provider_notes text,
  is_custom boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_orders_client on public.orders(client_id);
create index idx_orders_provider on public.orders(provider_id);
create index idx_orders_status on public.orders(status);
create index idx_orders_channel on public.orders(channel_id);

alter table public.orders enable row level security;

-- Clients can create orders
create policy "Clients can create orders" on public.orders
  for insert with check (auth.uid() = client_id);

-- Participants can view their orders
create policy "Participants can view their orders" on public.orders
  for select using (auth.uid() = client_id or auth.uid() = provider_id);

-- Providers can update order status
create policy "Providers can update orders" on public.orders
  for update using (auth.uid() = provider_id);

-- Clients can cancel their pending orders
create policy "Clients can cancel pending orders" on public.orders
  for update using (auth.uid() = client_id and status = 'pending');

-- =====================================================
-- 5. CHAT MESSAGES TABLE (جدول رسائل الدردشة)
-- =====================================================
create table public.chat_messages (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references public.orders(id) on delete cascade not null,
  sender_id uuid references public.users(id) on delete cascade not null,
  message text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create index idx_chat_messages_order on public.chat_messages(order_id);
create index idx_chat_messages_sender on public.chat_messages(sender_id);
create index idx_chat_messages_created on public.chat_messages(created_at desc);

alter table public.chat_messages enable row level security;

-- Order participants can view messages
create policy "Order participants can view messages" on public.chat_messages
  for select using (
    exists (
      select 1 from public.orders 
      where id = order_id 
      and (auth.uid() = client_id or auth.uid() = provider_id)
    )
  );

-- Order participants can send messages
create policy "Order participants can send messages" on public.chat_messages
  for insert with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.orders 
      where id = order_id 
      and (auth.uid() = client_id or auth.uid() = provider_id)
    )
  );

-- Recipients can mark messages as read
create policy "Recipients can mark messages as read" on public.chat_messages
  for update using (
    exists (
      select 1 from public.orders 
      where id = order_id 
      and (auth.uid() = client_id or auth.uid() = provider_id)
    )
    and auth.uid() != sender_id
  );

-- =====================================================
-- 6. HELPER FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

-- Triggers for updated_at
create trigger users_updated_at before update on public.users
  for each row execute function public.handle_updated_at();

create trigger channels_updated_at before update on public.channels
  for each row execute function public.handle_updated_at();

create trigger offers_updated_at before update on public.offers
  for each row execute function public.handle_updated_at();

create trigger orders_updated_at before update on public.orders
  for each row execute function public.handle_updated_at();

-- =====================================================
-- 7. REALTIME SUBSCRIPTIONS (للدردشة المباشرة)
-- =====================================================
-- Enable realtime for chat messages
alter publication supabase_realtime add table public.chat_messages;
alter publication supabase_realtime add table public.orders;


-- إنشاء bucket للصور
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- سياسة السماح بالرفع للمستخدمين المسجلين
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'images');

-- سياسة السماح بالقراءة للجميع (public)
CREATE POLICY "Allow public read" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'images');

-- سياسة السماح بالتحديث للمالك
CREATE POLICY "Allow owner update" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- سياسة السماح بالحذف للمالك
CREATE POLICY "Allow owner delete" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);