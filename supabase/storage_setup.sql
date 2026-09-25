-- ==============================================================================
-- Storage Setup: Supabase Storage Buckets & Policies
-- Bucket: society-assets
-- Purpose: Society logos, floor plans, avatars, and attachments
-- ==============================================================================

-- 1. Create Storage Bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'society-assets',
    'society-assets',
    true,
    5242880, -- 5 MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml', 'application/pdf'];

-- 2. Storage RLS Policies
-- Allow public read access to all objects in society-assets
CREATE POLICY "Public Read Access for society-assets"
ON storage.objects FOR SELECT
USING (bucket_id = 'society-assets');

-- Allow authenticated users to upload to society-assets
CREATE POLICY "Authenticated Users Upload to society-assets"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'society-assets');

-- Allow authenticated users to update their own uploads
CREATE POLICY "Authenticated Users Update society-assets"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'society-assets' AND auth.uid() = owner);

-- Allow admins to delete objects
CREATE POLICY "Admins Delete society-assets"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'society-assets' AND (
        auth.uid() = owner OR 
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role IN ('SOCIETY_ADMIN', 'SUPER_ADMIN')
        )
    )
);
