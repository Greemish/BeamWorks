-- ============================================================
-- FIX: Update RLS Policies for Public Access
-- Run this in your Supabase SQL Editor to fix the checkout error
-- ============================================================

-- Drop existing policies that might be blocking
DROP POLICY IF EXISTS "Public can create orders" ON orders;
DROP POLICY IF EXISTS "Public can create customer_info" ON customer_info;
DROP POLICY IF EXISTS "Public can create order_items" ON order_items;

-- CREATE NEW POLICIES - explicitly allowing ANON role to insert

-- For ORDERS table
CREATE POLICY "Allow anon to create orders"
    ON orders FOR INSERT
    WITH CHECK (auth.role() = 'anon' OR auth.role() = 'authenticated' OR true);

-- For CUSTOMER_INFO table
CREATE POLICY "Allow anon to create customer_info"
    ON customer_info FOR INSERT
    WITH CHECK (auth.role() = 'anon' OR auth.role() = 'authenticated' OR true);

-- For ORDER_ITEMS table
CREATE POLICY "Allow anon to create order_items"
    ON order_items FOR INSERT
    WITH CHECK (auth.role() = 'anon' OR auth.role() = 'authenticated' OR true);

-- Verify policies are in place
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('orders', 'customer_info', 'order_items')
ORDER BY tablename, policyname;
