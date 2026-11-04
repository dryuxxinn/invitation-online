-- =============================================================================
-- Migration: 20261103000003_storage_setup.sql
-- Description: Create storage buckets and access policies
-- =============================================================================

-- 1. Create Storage Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('customer-uploads', 'customer-uploads', false, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'audio/mpeg', 'audio/mp3', 'application/pdf']),
    ('payment-proofs', 'payment-proofs', false, 3145728, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
    ('invitation-assets', 'invitation-assets', true, 10485760, NULL),
    ('template-assets', 'template-assets', true, 10485760, NULL)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- =============================================================================
-- 2. Storage Objects Policies
-- =============================================================================

-- Template Assets: Public read, Admin write
CREATE POLICY "Public read template-assets"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'template-assets');

CREATE POLICY "Admins manage template-assets"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'template-assets' AND public.has_admin_role())
WITH CHECK (bucket_id = 'template-assets' AND public.has_admin_role());

-- Invitation Assets: Public read, Admin write
CREATE POLICY "Public read invitation-assets"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'invitation-assets');

CREATE POLICY "Admins manage invitation-assets"
ON storage.objects FOR ALL
TO authenticated
USING (bucket_id = 'invitation-assets' AND public.has_admin_role())
WITH CHECK (bucket_id = 'invitation-assets' AND public.has_admin_role());

-- Customer Uploads: Owner & Admin read/write
CREATE POLICY "Owner and admin view customer-uploads"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'customer-uploads'
    AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.has_admin_role()
    )
);

CREATE POLICY "Owner and admin upload customer-uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'customer-uploads'
    AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.has_admin_role()
    )
);

CREATE POLICY "Owner and admin delete customer-uploads"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'customer-uploads'
    AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.has_admin_role()
    )
);

-- Payment Proofs: Owner & Admin read/write
CREATE POLICY "Owner and admin view payment-proofs"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'payment-proofs'
    AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.has_admin_role()
    )
);

CREATE POLICY "Owner and admin upload payment-proofs"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'payment-proofs'
    AND (
        (storage.foldername(name))[1] = (SELECT auth.uid())::text
        OR public.has_admin_role()
    )
);
