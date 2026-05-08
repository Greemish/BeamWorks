

-- ============================================================
-- BeamWorks — Full Database Schema
-- Run this in Supabase SQL Editor after running reset.sql
-- ============================================================

-- 1. SITE SETTINGS (hero image, hero text, etc.)
CREATE TABLE site_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed default hero/site settings
INSERT INTO site_settings (setting_key, setting_value) VALUES
    ('hero_image_url', ''),
    ('hero_heading', ''),
    ('hero_button_text', 'View Promotion'),
    ('hero_visible', 'false'),
    ('hero_text_color', '#FFFFFF'),
    ('hero_text_size', '48');

-- 2. CATEGORIES (manage shop categories from Admin)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed default categories
INSERT INTO categories (name, display_order) VALUES
    ('Table', 1),
    ('Floor', 2),
    ('Pendants', 3),
    ('Wall', 4),
    ('Outdoor', 5);

-- 3. PRODUCTS
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    category VARCHAR(100) NOT NULL,  -- matches categories.name
    description TEXT,
    featured BOOLEAN DEFAULT FALSE,
    status VARCHAR(50) NOT NULL DEFAULT 'active',  -- 'active', 'sold_out'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PRODUCT IMAGES (one product → many images)
CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. ORDERS
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) NOT NULL DEFAULT 'paid',
        -- 'paid', 'awaiting_shipment', 'fulfilled'
    subtotal NUMERIC(10,2) NOT NULL,
    shipping_cost NUMERIC(10,2) NOT NULL DEFAULT 50.00,
    total NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. CUSTOMER INFO (linked to an order)
CREATE TABLE customer_info (
    id SERIAL PRIMARY KEY,
    order_id INTEGER UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    suburb VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    province VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    -- billing (nullable – if same as shipping these stay NULL)
    billing_first_name VARCHAR(100),
    billing_last_name VARCHAR(100),
    billing_address TEXT,
    billing_suburb VARCHAR(100),
    billing_city VARCHAR(100),
    billing_province VARCHAR(50),
    billing_postal_code VARCHAR(20)
);

-- 7. ORDER ITEMS (line items in an order)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) NOT NULL
);

-- 8. PROMOTIONS (one active promo at a time)
CREATE TABLE promotions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    discount_percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. PROMOTION PRODUCTS (which products belong to a promotion)
CREATE TABLE promotion_products (
    id SERIAL PRIMARY KEY,
    promotion_id INTEGER REFERENCES promotions(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE(promotion_id, product_id)
);

-- ============================================================
-- AUTO-UPDATE updated_at TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_updated
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER trg_orders_updated
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER trg_site_settings_updated
    BEFORE UPDATE ON site_settings
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER trg_promotions_updated
    BEFORE UPDATE ON promotions
    FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Public can read products/settings; only authenticated can write
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE promotion_products ENABLE ROW LEVEL SECURITY;

-- PUBLIC READ for products, product_images, site_settings, categories, promotions
CREATE POLICY "Public can read site_settings"
    ON site_settings FOR SELECT
    USING (true);

CREATE POLICY "Public can read categories"
    ON categories FOR SELECT
    USING (true);

CREATE POLICY "Public can read products"
    ON products FOR SELECT
    USING (true);

CREATE POLICY "Public can read product_images"
    ON product_images FOR SELECT
    USING (true);

CREATE POLICY "Public can read promotions"
    ON promotions FOR SELECT
    USING (true);

CREATE POLICY "Public can read promotion_products"
    ON promotion_products FOR SELECT
    USING (true);

-- PUBLIC INSERT on orders, customer_info, order_items (customers placing orders)
CREATE POLICY "Public can create orders"
    ON orders FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Public can create customer_info"
    ON customer_info FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Public can create order_items"
    ON order_items FOR INSERT
    WITH CHECK (true);

-- AUTHENTICATED full access (admin)
CREATE POLICY "Admin full access site_settings"
    ON site_settings FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access categories"
    ON categories FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access products"
    ON products FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access product_images"
    ON product_images FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access orders"
    ON orders FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access customer_info"
    ON customer_info FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access order_items"
    ON order_items FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access promotions"
    ON promotions FOR ALL
    USING (auth.role() = 'authenticated');

CREATE POLICY "Admin full access promotion_products"
    ON promotion_products FOR ALL
    USING (auth.role() = 'authenticated');

-- ============================================================
-- SEED PRODUCTS (remove or replace before launch)
-- ============================================================
INSERT INTO products (name, price, category, description, featured, status) VALUES
    ('Standing Table Light', 295.00, 'Table', 'A masterclass in geometric balance. Hand-blown glass sphere on a solid brass mount.', true, 'active'),
    ('Floor Light', 540.00, 'Floor', 'An architectural statement piece providing vertical diffused illumination.', true, 'active'),
    ('Pendant Light', 820.00, 'Pendants', 'A halo of warmth for dining and social environments.', true, 'active'),
    ('Vellum Desk Light', 185.00, 'Table', 'Focus meets softness with a textured vellum shade.', false, 'active');

-- Product images (adjust to match your current images)
INSERT INTO product_images (product_id, image_url, display_order) VALUES
    (1, './pictures/lampExample1.jpeg', 0),
    (1, './pictures/lampExample2.jpeg', 1),
    (1, './pictures/lampExample3.jpeg', 2),
    (1, './pictures/lampExample4.jpeg', 3),
    (1, './pictures/lampExample6.jpeg', 4),
    (2, './pictures/lampExample3.jpeg', 0),
    (2, './pictures/lampExample1.jpeg', 1),
    (3, './pictures/lampExample2.jpeg', 0),
    (4, './pictures/lampExample1.jpeg', 0);
