-- ============================================================
-- fix_permissions.sql — BeamWorks RLS & Role Permissions
-- Run this in Supabase SQL Editor to fix permission issues
-- ============================================================

-- Grant basic permissions to the anon and authenticated roles
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;

-- Ensure service_role has full permissions (for backend operations)
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- ============================================================
-- DROP all existing RLS policies (clean slate)
-- ============================================================
DROP POLICY IF EXISTS "Public can read site_settings" ON site_settings;
DROP POLICY IF EXISTS "Public can read categories" ON categories;
DROP POLICY IF EXISTS "Public can read products" ON products;
DROP POLICY IF EXISTS "Public can read product_images" ON product_images;
DROP POLICY IF EXISTS "Public can read promotions" ON promotions;
DROP POLICY IF EXISTS "Public can read promotion_products" ON promotion_products;
DROP POLICY IF EXISTS "Public can create orders" ON orders;
DROP POLICY IF EXISTS "Public can create customer_info" ON customer_info;
DROP POLICY IF EXISTS "Public can create order_items" ON order_items;
DROP POLICY IF EXISTS "Admin full access site_settings" ON site_settings;
DROP POLICY IF EXISTS "Admin full access categories" ON categories;
DROP POLICY IF EXISTS "Admin full access products" ON products;
DROP POLICY IF EXISTS "Admin full access product_images" ON product_images;
DROP POLICY IF EXISTS "Admin full access orders" ON orders;
DROP POLICY IF EXISTS "Admin full access customer_info" ON customer_info;
DROP POLICY IF EXISTS "Admin full access order_items" ON order_items;
DROP POLICY IF EXISTS "Admin full access promotions" ON promotions;
DROP POLICY IF EXISTS "Admin full access promotion_products" ON promotion_products;

-- ============================================================
-- CREATE RLS POLICIES (allow public read, authenticated write)
-- ============================================================

-- PUBLIC READ: site_settings
CREATE POLICY "Public can read site_settings"
    ON site_settings FOR SELECT
    USING (true);

-- PUBLIC READ: categories
CREATE POLICY "Public can read categories"
    ON categories FOR SELECT
    USING (true);

-- PUBLIC READ: products
CREATE POLICY "Public can read products"
    ON products FOR SELECT
    USING (true);

-- PUBLIC READ: product_images
CREATE POLICY "Public can read product_images"
    ON product_images FOR SELECT
    USING (true);

-- PUBLIC READ: promotions
CREATE POLICY "Public can read promotions"
    ON promotions FOR SELECT
    USING (true);

-- PUBLIC READ: promotion_products
CREATE POLICY "Public can read promotion_products"
    ON promotion_products FOR SELECT
    USING (true);

-- PUBLIC WRITE: orders (customers can create orders)
CREATE POLICY "Public can create orders"
    ON orders FOR INSERT
    WITH CHECK (true);

-- PUBLIC WRITE: customer_info (customers can create customer info)
CREATE POLICY "Public can create customer_info"
    ON customer_info FOR INSERT
    WITH CHECK (true);

-- PUBLIC WRITE: order_items (customers can create order items)
CREATE POLICY "Public can create order_items"
    ON order_items FOR INSERT
    WITH CHECK (true);

-- AUTHENTICATED WRITE: site_settings (admin only)
CREATE POLICY "Admin full access site_settings"
    ON site_settings FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED WRITE: categories (admin only)
CREATE POLICY "Admin full access categories"
    ON categories FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED WRITE: products (admin only)
CREATE POLICY "Admin full access products"
    ON products FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED WRITE: product_images (admin only)
CREATE POLICY "Admin full access product_images"
    ON product_images FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED READ/WRITE: orders (admins can manage)
CREATE POLICY "Admin full access orders"
    ON orders FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED READ/WRITE: customer_info (admins can view)
CREATE POLICY "Admin full access customer_info"
    ON customer_info FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED READ/WRITE: order_items (admins can view)
CREATE POLICY "Admin full access order_items"
    ON order_items FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED WRITE: promotions (admin only)
CREATE POLICY "Admin full access promotions"
    ON promotions FOR ALL
    USING (auth.role() = 'authenticated');

-- AUTHENTICATED WRITE: promotion_products (admin only)
CREATE POLICY "Admin full access promotion_products"
    ON promotion_products FOR ALL
    USING (auth.role() = 'authenticated');
