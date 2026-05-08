-- ============================================================
-- fix_site_settings_policies.sql — BeamWorks Site Settings RLS
-- Run this in Supabase SQL Editor to fix admin update issues
-- ============================================================

-- Drop existing site_settings policies
DROP POLICY IF EXISTS "Public can read site_settings" ON site_settings;
DROP POLICY IF EXISTS "Admin full access site_settings" ON site_settings;

-- Allow PUBLIC to read site_settings (for frontend)
CREATE POLICY "Public can read site_settings"
    ON site_settings FOR SELECT
    USING (true);

-- Allow AUTHENTICATED (admins) to read site_settings
CREATE POLICY "Authenticated can read site_settings"
    ON site_settings FOR SELECT
    USING (auth.role() = 'authenticated');

-- Allow AUTHENTICATED to INSERT site_settings
CREATE POLICY "Authenticated can insert site_settings"
    ON site_settings FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Allow AUTHENTICATED to UPDATE site_settings
CREATE POLICY "Authenticated can update site_settings"
    ON site_settings FOR UPDATE
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Allow AUTHENTICATED to DELETE site_settings
CREATE POLICY "Authenticated can delete site_settings"
    ON site_settings FOR DELETE
    USING (auth.role() = 'authenticated');

-- ============================================================
-- Done. Log out and back in, then try saving hero settings.
-- ============================================================
