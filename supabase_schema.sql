-- ==============================================
-- مدیریت ارسال کالا - Supabase Schema
-- Version: 6.22
-- ==============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ۱. جدول محصولات
CREATE TABLE IF NOT EXISTS products (
  id        BIGINT PRIMARY KEY,
  name      TEXT NOT NULL,
  code      TEXT DEFAULT '',
  cartons   INTEGER DEFAULT 0
);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on products" ON products;
CREATE POLICY "Allow all on products" ON products FOR ALL USING (true) WITH CHECK (true);

-- ۲. جدول خودروها
CREATE TABLE IF NOT EXISTS vehicles (
  id        BIGINT PRIMARY KEY,
  name      TEXT NOT NULL,
  type      TEXT DEFAULT ''
);
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on vehicles" ON vehicles;
CREATE POLICY "Allow all on vehicles" ON vehicles FOR ALL USING (true) WITH CHECK (true);

-- ۳. جدول تحویل‌ها (deliveries)
CREATE TABLE IF NOT EXISTS deliveries (
  id              BIGINT PRIMARY KEY,
  batch_id        TEXT DEFAULT '',
  prod_id         BIGINT DEFAULT 0,
  prod_name       TEXT DEFAULT '',
  prod_code       TEXT DEFAULT '',
  date            TEXT DEFAULT '',
  time            INTEGER DEFAULT 0,
  pallets         INTEGER DEFAULT 0,
  loose           INTEGER DEFAULT 0,
  total           INTEGER DEFAULT 0,
  cpp             INTEGER DEFAULT 0,
  item_status     TEXT DEFAULT 'فعلی',
  dispatch_id     BIGINT DEFAULT 0,
  remaining_pallets INTEGER DEFAULT 0,
  remaining_loose   INTEGER DEFAULT 0,
  dispatch_log    TEXT DEFAULT '',
  user_role       TEXT DEFAULT ''
);
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on deliveries" ON deliveries;
CREATE POLICY "Allow all on deliveries" ON deliveries FOR ALL USING (true) WITH CHECK (true);

-- ۴. جدول اعزام‌ها (dispatches)
CREATE TABLE IF NOT EXISTS dispatches (
  id              BIGINT PRIMARY KEY,
  vehicle_id      BIGINT DEFAULT 0,
  dispatch_date   TEXT DEFAULT '',
  dispatch_time   TEXT DEFAULT '',
  total_pallets   INTEGER DEFAULT 0,
  total_loose     INTEGER DEFAULT 0,
  total_cartons   INTEGER DEFAULT 0,
  veh_info        TEXT DEFAULT '',
  driver_name     TEXT DEFAULT '',
  veh_id          TEXT DEFAULT '',
  user_role       TEXT DEFAULT ''
);
ALTER TABLE dispatches ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on dispatches" ON dispatches;
CREATE POLICY "Allow all on dispatches" ON dispatches FOR ALL USING (true) WITH CHECK (true);

-- ۵. جدول محصولات اعزامی (dispatch_products)
CREATE TABLE IF NOT EXISTS dispatch_products (
  id              BIGINT PRIMARY KEY,
  dispatch_id     BIGINT DEFAULT 0,
  delivery_id     BIGINT DEFAULT 0,
  prod_id         BIGINT DEFAULT 0,
  name            TEXT DEFAULT '',
  prod_code       TEXT DEFAULT '',
  pallets         INTEGER DEFAULT 0,
  loose           INTEGER DEFAULT 0,
  cpp             INTEGER DEFAULT 0,
  total           INTEGER DEFAULT 0,
  prod_name       TEXT DEFAULT ''
);
ALTER TABLE dispatch_products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on dispatch_products" ON dispatch_products;
CREATE POLICY "Allow all on dispatch_products" ON dispatch_products FOR ALL USING (true) WITH CHECK (true);

-- ۶. جدول رمزهای عبور
CREATE TABLE IF NOT EXISTS passwords (
  role       TEXT PRIMARY KEY,
  password   TEXT NOT NULL
);
ALTER TABLE passwords ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on passwords" ON passwords;
CREATE POLICY "Allow all on passwords" ON passwords FOR ALL USING (true) WITH CHECK (true);

-- ۷. جدول اعلان‌ها
CREATE TABLE IF NOT EXISTS notifications (
  id            BIGINT PRIMARY KEY,
  target_role   TEXT DEFAULT '',
  message       TEXT DEFAULT '',
  shown         BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all on notifications" ON notifications;
CREATE POLICY "Allow all on notifications" ON notifications FOR ALL USING (true) WITH CHECK (true);

-- ==============================================
-- داده‌های اولیه رمز عبور
-- ==============================================
INSERT INTO passwords (role, password) VALUES ('تحویل', '1234')
  ON CONFLICT (role) DO NOTHING;
INSERT INTO passwords (role, password) VALUES ('تحول', '1234')
  ON CONFLICT (role) DO NOTHING;