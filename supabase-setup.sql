-- ============================================
-- 🚛 اپلیکیشن مدیریت ارسال کالا — تحویل/تحول
-- اسکریپت ساخت جداول Supabase (نسخه ۳ — بدون خطا)
-- ============================================
-- این فایل را در SQL Editor سوپابیس کپی و اجرا کنید
-- ============================================

-- ۱. جدول محصولات
CREATE TABLE IF NOT EXISTS products (
  id BIGINT PRIMARY KEY,
  name TEXT NOT NULL,
  cartons INTEGER NOT NULL DEFAULT 1
);

-- ۲. جدول خودروها
CREATE TABLE IF NOT EXISTS vehicles (
  id BIGINT PRIMARY KEY,
  type TEXT NOT NULL,
  driver TEXT NOT NULL,
  plate TEXT NOT NULL
);

-- ۳. جدول تحویل‌ها (deliveries)
CREATE TABLE IF NOT EXISTS deliveries (
  id BIGINT PRIMARY KEY,
  batch_id BIGINT,
  prod_id BIGINT,
  prod_name TEXT,
  cpp INTEGER DEFAULT 0,
  pallets INTEGER DEFAULT 0,
  loose INTEGER DEFAULT 0,
  total INTEGER DEFAULT 0,
  date TEXT,
  time INTEGER DEFAULT 0,
  status TEXT DEFAULT 'بررسی',
  item_status TEXT DEFAULT 'بررسی',
  dispatch_id BIGINT,
  remaining_pallets INTEGER DEFAULT 0,
  remaining_loose INTEGER DEFAULT 0,
  dispatch_log JSONB DEFAULT '[]'::jsonb
);

-- ۴. جدول ارسال‌ها (dispatches)
CREATE TABLE IF NOT EXISTS dispatches (
  id BIGINT PRIMARY KEY,
  vehicle_id BIGINT,
  products JSONB DEFAULT '[]'::jsonb,
  date TEXT,
  dispatch_date TEXT,
  dispatch_time TEXT,
  status TEXT DEFAULT 'در حال ارسال',
  user_role TEXT,
  total_pallets INTEGER DEFAULT 0,
  total_loose INTEGER DEFAULT 0,
  total_cartons INTEGER DEFAULT 0,
  veh_info TEXT,
  driver_name TEXT,
  veh_id BIGINT
);

-- ۵. جدول محصولات ارسال (dispatch_products)
CREATE TABLE IF NOT EXISTS dispatch_products (
  id BIGINT PRIMARY KEY,
  dispatch_id BIGINT NOT NULL,
  delivery_id BIGINT,
  prod_id BIGINT,
  name TEXT,
  prod_name TEXT,
  cpp INTEGER DEFAULT 0,
  pallets INTEGER DEFAULT 0,
  loose INTEGER DEFAULT 0,
  total INTEGER DEFAULT 0
);

-- ۶. جدول رمزهای عبور
CREATE TABLE IF NOT EXISTS passwords (
  role TEXT PRIMARY KEY,
  password TEXT NOT NULL
);

-- ۷. جدول اعلان‌ها
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT PRIMARY KEY,
  target_role TEXT NOT NULL,
  message TEXT NOT NULL,
  shown BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- رمز پیش‌فرض حساب‌ها
-- ============================================
INSERT INTO passwords (role, password) VALUES ('تحویل', '1234')
  ON CONFLICT (role) DO NOTHING;
INSERT INTO passwords (role, password) VALUES ('تحول', '1234')
  ON CONFLICT (role) DO NOTHING;

-- ============================================
-- فعال‌سازی RLS (Row Level Security)
-- ============================================

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatches ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE passwords ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- حذف پالیسی‌های قدیمی
DROP POLICY IF EXISTS "Allow all on products" ON products;
DROP POLICY IF EXISTS "Allow all on vehicles" ON vehicles;
DROP POLICY IF EXISTS "Allow all on deliveries" ON deliveries;
DROP POLICY IF EXISTS "Allow all on dispatches" ON dispatches;
DROP POLICY IF EXISTS "Allow all on dispatch_products" ON dispatch_products;
DROP POLICY IF EXISTS "Allow all on passwords" ON passwords;
DROP POLICY IF EXISTS "Allow all on notifications" ON notifications;

-- ایجاد پالیسی‌های جدید
CREATE POLICY "Allow all on products" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on vehicles" ON vehicles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on deliveries" ON deliveries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on dispatches" ON dispatches FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on dispatch_products" ON dispatch_products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on passwords" ON passwords FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on notifications" ON notifications FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- فعال‌سازی Realtime — روش امن بدون خطا
-- ابتدا حذف (با گرفتن خطا) سپس اضافه
-- ============================================
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime DROP TABLE products;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime DROP TABLE vehicles;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime DROP TABLE deliveries;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime DROP TABLE dispatches;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime DROP TABLE dispatch_products;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime DROP TABLE notifications;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE vehicles;
ALTER PUBLICATION supabase_realtime ADD TABLE deliveries;
ALTER PUBLICATION supabase_realtime ADD TABLE dispatches;
ALTER PUBLICATION supabase_realtime ADD TABLE dispatch_products;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;