-- ============================================================
-- fix_storage_policies.sql — BeamWorks Storage Bucket Policies
-- Run this in Supabase SQL Editor to fix image upload RLS
-- ============================================================

-- Drop existing storage policies for BeamWorksImages
DROP POLICY IF EXISTS "Public read access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated delete" ON storage.objects;

-- Allow PUBLIC to read/download images
CREATE POLICY "Public read images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'BeamWorksImages');

-- Allow AUTHENTICATED to upload images
CREATE POLICY "Authenticated upload images"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'BeamWorksImages' AND auth.role() = 'authenticated');

-- Allow AUTHENTICATED to update images
CREATE POLICY "Authenticated update images"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'BeamWorksImages' AND auth.role() = 'authenticated')
    WITH CHECK (bucket_id = 'BeamWorksImages' AND auth.role() = 'authenticated');

-- Allow AUTHENTICATED to delete images
CREATE POLICY "Authenticated delete images"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'BeamWorksImages' AND auth.role() = 'authenticated');

-- ============================================================
-- Done. Test uploading an image in Admin now.
-- ============================================================
