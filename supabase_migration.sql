-- =====================================================
-- Noor Shams Mobile - Service Provider Feature Migration
-- =====================================================
-- هذا الملف للتحديث على قاعدة البيانات الموجودة
-- يجب تنفيذه بعد إنشاء جدول المستخدمين الأصلي
-- =====================================================

-- =====================================================
-- 1. تحديث جدول المستخدمين (إضافة أعمدة جديدة)
-- =====================================================

-- إضافة عمود رقم الهاتف
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS phone text;

-- إضافة عمود صورة المستخدم
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS avatar_url text;

-- إضافة عمود تاريخ التحديث
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone default timezone('utc'::text, now());

-- السماح للعملاء بمشاهدة مزودي الخدمة (للقنوات)
DROP POLICY IF EXISTS "Allow viewing providers" ON public.users;
CREATE POLICY "Allow viewing providers" ON public.users
  FOR SELECT USING (role = 'provider');

-- =====================================================
-- 2. جدول القنوات (Channels)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.channels (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  provider_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  description text,
  cover_image_url text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_channels_provider ON public.channels(provider_id);
CREATE INDEX IF NOT EXISTS idx_channels_active ON public.channels(is_active) WHERE is_active = true;

-- تفعيل RLS
ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;

-- سياسات القنوات
DROP POLICY IF EXISTS "Providers can manage their own channels" ON public.channels;
CREATE POLICY "Providers can manage their own channels" ON public.channels
  FOR ALL USING (auth.uid() = provider_id);

DROP POLICY IF EXISTS "Everyone can view active channels" ON public.channels;
CREATE POLICY "Everyone can view active channels" ON public.channels
  FOR SELECT USING (is_active = true);

-- =====================================================
-- 3. جدول العروض (Offers)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.offers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  channel_id uuid REFERENCES public.channels(id) ON DELETE CASCADE NOT NULL,
  provider_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text,
  price decimal(10,2) NOT NULL CHECK (price >= 0),
  duration_days int CHECK (duration_days > 0),
  image_url text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_offers_channel ON public.offers(channel_id);
CREATE INDEX IF NOT EXISTS idx_offers_provider ON public.offers(provider_id);
CREATE INDEX IF NOT EXISTS idx_offers_active ON public.offers(is_active) WHERE is_active = true;

-- تفعيل RLS
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

-- سياسات العروض
DROP POLICY IF EXISTS "Providers can manage their own offers" ON public.offers;
CREATE POLICY "Providers can manage their own offers" ON public.offers
  FOR ALL USING (auth.uid() = provider_id);

DROP POLICY IF EXISTS "Everyone can view active offers" ON public.offers;
CREATE POLICY "Everyone can view active offers" ON public.offers
  FOR SELECT USING (
    is_active = true 
    AND EXISTS (
      SELECT 1 FROM public.channels 
      WHERE id = channel_id AND is_active = true
    )
  );

-- =====================================================
-- 4. جدول الطلبات (Orders)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  offer_id uuid REFERENCES public.offers(id) ON DELETE SET NULL,
  channel_id uuid REFERENCES public.channels(id) ON DELETE CASCADE NOT NULL,
  client_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  provider_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed', 'cancelled')),
  proposed_price decimal(10,2) CHECK (proposed_price >= 0),
  client_notes text,
  provider_notes text,
  is_custom boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_orders_client ON public.orders(client_id);
CREATE INDEX IF NOT EXISTS idx_orders_provider ON public.orders(provider_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_channel ON public.orders(channel_id);

-- تفعيل RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- سياسات الطلبات
DROP POLICY IF EXISTS "Clients can create orders" ON public.orders;
CREATE POLICY "Clients can create orders" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = client_id);

DROP POLICY IF EXISTS "Participants can view their orders" ON public.orders;
CREATE POLICY "Participants can view their orders" ON public.orders
  FOR SELECT USING (auth.uid() = client_id OR auth.uid() = provider_id);

DROP POLICY IF EXISTS "Providers can update orders" ON public.orders;
CREATE POLICY "Providers can update orders" ON public.orders
  FOR UPDATE USING (auth.uid() = provider_id);

DROP POLICY IF EXISTS "Clients can cancel pending orders" ON public.orders;
CREATE POLICY "Clients can cancel pending orders" ON public.orders
  FOR UPDATE USING (auth.uid() = client_id AND status = 'pending');

-- =====================================================
-- 5. جدول رسائل الدردشة (Chat Messages)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
  sender_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_chat_messages_order ON public.chat_messages(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON public.chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON public.chat_messages(created_at DESC);

-- تفعيل RLS
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- سياسات الرسائل
DROP POLICY IF EXISTS "Order participants can view messages" ON public.chat_messages;
CREATE POLICY "Order participants can view messages" ON public.chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders 
      WHERE id = order_id 
      AND (auth.uid() = client_id OR auth.uid() = provider_id)
    )
  );

DROP POLICY IF EXISTS "Order participants can send messages" ON public.chat_messages;
CREATE POLICY "Order participants can send messages" ON public.chat_messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.orders 
      WHERE id = order_id 
      AND (auth.uid() = client_id OR auth.uid() = provider_id)
    )
  );

DROP POLICY IF EXISTS "Recipients can mark messages as read" ON public.chat_messages;
CREATE POLICY "Recipients can mark messages as read" ON public.chat_messages
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.orders 
      WHERE id = order_id 
      AND (auth.uid() = client_id OR auth.uid() = provider_id)
    )
    AND auth.uid() != sender_id
  );

-- =====================================================
-- 6. دوال مساعدة (Helper Functions)
-- =====================================================

-- دالة تحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc'::text, now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers للتحديث التلقائي
DROP TRIGGER IF EXISTS users_updated_at ON public.users;
CREATE TRIGGER users_updated_at 
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS channels_updated_at ON public.channels;
CREATE TRIGGER channels_updated_at 
  BEFORE UPDATE ON public.channels
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS offers_updated_at ON public.offers;
CREATE TRIGGER offers_updated_at 
  BEFORE UPDATE ON public.offers
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS orders_updated_at ON public.orders;
CREATE TRIGGER orders_updated_at 
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- انتهى التحديث بنجاح!
-- =====================================================
