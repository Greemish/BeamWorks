-- ============================================================
-- fix_all_admin_policies.sql — BeamWorks Complete Admin RLS Fix
-- Fixes permission denied errors for UPSERT and all admin operations
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- SITE_SETTINGS — Full admin access with UPSERT support
-- ============================================================
DROP POLICY IF EXISTS "Public can read site_settings" ON site_settings;
DROP POLICY IF EXISTS "Authenticated can read site_settings" ON site_settings;
DROP POLICY IF EXISTS "Authenticated can insert site_settings" ON site_settings;
DROP POLICY IF EXISTS "Authenticated can update site_settings" ON site_settings;
DROP POLICY IF EXISTS "Authenticated can delete site_settings" ON site_settings;
DROP POLICY IF EXISTS "Admin full access site_settings" ON site_settings;

-- Public reads
CREATE POLICY "Public read site_settings"
    ON site_settings FOR SELECT
    USING (true);

-- Authenticated does everything
CREATE POLICY "Admin all access site_settings"
    ON site_settings FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- CATEGORIES — Full admin access
-- ============================================================
DROP POLICY IF EXISTS "Public can read categories" ON categories;
DROP POLICY IF EXISTS "Admin full access categories" ON categories;

CREATE POLICY "Public read categories"
    ON categories FOR SELECT
    USING (true);

CREATE POLICY "Admin all access categories"
    ON categories FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- PRODUCTS — Full admin access
-- ============================================================
DROP POLICY IF EXISTS "Public can read products" ON products;
DROP POLICY IF EXISTS "Admin full access products" ON products;

CREATE POLICY "Public read products"
    ON products FOR SELECT
    USING (true);

CREATE POLICY "Admin all access products"
    ON products FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- PRODUCT_IMAGES — Full admin access
-- ============================================================
DROP POLICY IF EXISTS "Public can read product_images" ON product_images;
DROP POLICY IF EXISTS "Admin full access product_images" ON product_images;

CREATE POLICY "Public read product_images"
    ON product_images FOR SELECT
    USING (true);

CREATE POLICY "Admin all access product_images"
    ON product_images FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- PROMOTIONS — Full admin access
-- ============================================================
DROP POLICY IF EXISTS "Public can read promotions" ON promotions;
DROP POLICY IF EXISTS "Admin full access promotions" ON promotions;

CREATE POLICY "Public read promotions"
    ON promotions FOR SELECT
    USING (true);

CREATE POLICY "Admin all access promotions"
    ON promotions FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- PROMOTION_PRODUCTS — Admin access
-- ============================================================
DROP POLICY IF EXISTS "Public can read promotion_products" ON promotion_products;
DROP POLICY IF EXISTS "Admin full access promotion_products" ON promotion_products;

CREATE POLICY "Public read promotion_products"
    ON promotion_products FOR SELECT
    USING (true);

CREATE POLICY "Admin all access promotion_products"
    ON promotion_products FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- ORDERS — Admin reads, public can insert
-- ============================================================
DROP POLICY IF EXISTS "Public can create orders" ON orders;
DROP POLICY IF EXISTS "Admin full access orders" ON orders;

CREATE POLICY "Public insert orders"
    ON orders FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admin all access orders"
    ON orders FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin update orders"
    ON orders FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- CUSTOMER_INFO — Admin reads, public can insert
-- ============================================================
DROP POLICY IF EXISTS "Public can create customer_info" ON customer_info;
DROP POLICY IF EXISTS "Admin full access customer_info" ON customer_info;

CREATE POLICY "Public insert customer_info"
    ON customer_info FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admin all access customer_info"
    ON customer_info FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin update customer_info"
    ON customer_info FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- ORDER_ITEMS — Admin reads, public can insert
-- ============================================================
DROP POLICY IF EXISTS "Public can create order_items" ON order_items;
DROP POLICY IF EXISTS "Admin full access order_items" ON order_items;

CREATE POLICY "Public insert order_items"
    ON order_items FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admin read order_items"
    ON order_items FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin update order_items"
    ON order_items FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================================
-- STORAGE PERMISSIONS
-- ============================================================
DROP POLICY IF EXISTS "Public read images" ON storage.objects;
DROP POLICY IF EXISTS "Public read access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated upload images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated update images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated delete images" ON storage.objects;
DROP POLICY IF EXISTS "Public upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete" ON storage.objects;

-- Allow public to read/download images
CREATE POLICY "Public read all images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'BeamWorksImages');

-- Allow authenticated to do everything with images
CREATE POLICY "Admin all access images"
    ON storage.objects FOR ALL
    USING (bucket_id = 'BeamWorksImages' AND auth.role() = 'authenticated')
    WITH CHECK (bucket_id = 'BeamWorksImages' AND auth.role() = 'authenticated');

-- ============================================================
-- Done! Log out completely, then log back in and try again.
-- ============================================================
