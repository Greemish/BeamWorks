-- ============================================================
-- reset.sql — BeamWorks
-- WARNING: This permanently deletes ALL data and tables.
-- Run this FIRST in Supabase SQL Editor, then run migration.sql.
-- ============================================================

-- Drop triggers
DROP TRIGGER IF EXISTS trg_products_updated ON products;
DROP TRIGGER IF EXISTS trg_orders_updated ON orders;
DROP TRIGGER IF EXISTS trg_site_settings_updated ON site_settings;
DROP TRIGGER IF EXISTS trg_promotions_updated ON promotions;

-- Drop function
DROP FUNCTION IF EXISTS update_modified_column() CASCADE;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS customer_info CASCADE;
DROP TABLE IF EXISTS promotion_products CASCADE;
DROP TABLE IF EXISTS product_images CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS site_settings CASCADE;

-- ============================================================
-- Done. Now run migration.sql to re-create the schema.
-- ============================================================
