-- Create the users table
create table public.users (
  id uuid references auth.users not null primary key,
  name text not null,
  email text,
  role text default 'client', -- 'client' or 'provider'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.users enable row level security;

-- Policies
-- 1. Allow users to insert their own data (needed for the manual insert in register)
create policy "Enable insert for authenticated users only" on public.users
  for insert with check (auth.uid() = id);

-- 2. Allow users to view their own data
create policy "Enable read access for own user" on public.users
  for select using (auth.uid() = id);

-- 3. Allow users to update their own data
create policy "Enable update for own user" on public.users
  for update using (auth.uid() = id);
