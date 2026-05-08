-- ============================================================
-- fix_sequence_permissions.sql — BeamWorks Sequence Access
-- Fixes: permission denied for sequence site_settings_id_seq
-- Run this in Supabase SQL Editor
-- ============================================================

-- Grant sequence permissions to all roles
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- Specifically grant permissions on each sequence
GRANT USAGE, SELECT ON site_settings_id_seq TO authenticated;
GRANT USAGE, SELECT ON categories_id_seq TO authenticated;
GRANT USAGE, SELECT ON products_id_seq TO authenticated;
GRANT USAGE, SELECT ON product_images_id_seq TO authenticated;
GRANT USAGE, SELECT ON orders_id_seq TO authenticated;
GRANT USAGE, SELECT ON customer_info_id_seq TO authenticated;
GRANT USAGE, SELECT ON order_items_id_seq TO authenticated;
GRANT USAGE, SELECT ON promotions_id_seq TO authenticated;
GRANT USAGE, SELECT ON promotion_products_id_seq TO authenticated;

-- ============================================================
-- Done. Log out completely, then log back in and try again.
-- ============================================================
