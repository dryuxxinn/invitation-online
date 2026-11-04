-- =============================================================================
-- Seed Data: supabase/seed.sql
-- Description: Initial categories, packages, features & sample templates
-- =============================================================================

-- 1. Insert Categories
INSERT INTO public.categories (id, name, slug, description, sort_order)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'Wedding', 'wedding', 'Undangan pernikahan modern, elegan, dan islami', 1),
    ('c2222222-2222-2222-2222-222222222222', 'Birthday', 'birthday', 'Undangan ulang tahun anak, remaja, dan dewasa', 2),
    ('c3333333-3333-3333-3333-333333333333', 'Engagement', 'engagement', 'Undangan lamaran dan pertunangan spesial', 3),
    ('c4444444-4444-4444-4444-444444444444', 'Corporate', 'corporate', 'Undangan seminar, gathering, dan acara korporat', 4),
    ('c5555555-5555-5555-5555-555555555555', 'Graduation', 'graduation', 'Undangan syukuran kelulusan dan wisuda', 5)
ON CONFLICT (slug) DO NOTHING;

-- 2. Insert Packages
INSERT INTO public.packages (id, name, slug, description, price, currency, revision_limit, duration_days)
VALUES
    ('ba51c000-0000-0000-0000-000000000001', 'Basic', 'basic', 'Paket hemat untuk acara sederhana', 99000, 'IDR', 1, 180),
    ('ba51c000-0000-0000-0000-000000000002', 'Premium', 'premium', 'Paket paling diminati dengan fitur lengkap dan musik', 175000, 'IDR', 3, 365),
    ('ba51c000-0000-0000-0000-000000000003', 'Exclusive', 'exclusive', 'Paket VIP dengan kustomisasi desain dan revisi tanpa batas', 299000, 'IDR', 10, 730)
ON CONFLICT (slug) DO NOTHING;

-- 3. Insert Package Features
INSERT INTO public.package_features (package_id, feature_name, feature_value, is_included, sort_order)
VALUES
    -- Basic features
    ('ba51c000-0000-0000-0000-000000000001', 'Masa Aktif', '6 Bulan', true, 1),
    ('ba51c000-0000-0000-0000-000000000001', 'Batas Revisi', '1 Kali', true, 2),
    ('ba51c000-0000-0000-0000-000000000001', 'Galeri Foto', 'Maksimal 5 Foto', true, 3),
    ('ba51c000-0000-0000-0000-000000000001', 'Integrasi Google Maps', 'Tersedia', true, 4),
    ('ba51c000-0000-0000-0000-000000000001', 'RSVP & Ucapan Tamu', 'Tersedia', true, 5),
    ('ba51c000-0000-0000-0000-000000000001', 'Background Music', 'Tidak Tersedia', false, 6),

    -- Premium features
    ('ba51c000-0000-0000-0000-000000000002', 'Masa Aktif', '1 Tahun (365 Hari)', true, 1),
    ('ba51c000-0000-0000-0000-000000000002', 'Batas Revisi', '3 Kali', true, 2),
    ('ba51c000-0000-0000-0000-000000000002', 'Galeri Foto', 'Hingga 15 Foto & Video', true, 3),
    ('ba51c000-0000-0000-0000-000000000002', 'Integrasi Google Maps', 'Tersedia', true, 4),
    ('ba51c000-0000-0000-0000-000000000002', 'RSVP & Ucapan Tamu', 'Tersedia', true, 5),
    ('ba51c000-0000-0000-0000-000000000002', 'Background Music', 'Bebas Pilih Lagu', true, 6),
    ('ba51c000-0000-0000-0000-000000000002', 'Love Story & Countdown', 'Tersedia', true, 7),
    ('ba51c000-0000-0000-0000-000000000002', 'Buku Tamu Digital (QR Code)', 'Tersedia', true, 8),

    -- Exclusive features
    ('ba51c000-0000-0000-0000-000000000003', 'Masa Aktif', '2 Tahun', true, 1),
    ('ba51c000-0000-0000-0000-000000000003', 'Batas Revisi', 'Bebas Revisi (Maks 10x)', true, 2),
    ('ba51c000-0000-0000-0000-000000000003', 'Galeri Foto', 'Tanpa Batas', true, 3),
    ('ba51c000-0000-0000-0000-000000000003', 'Integrasi Google Maps', 'Tersedia', true, 4),
    ('ba51c000-0000-0000-0000-000000000003', 'RSVP & Ucapan Tamu', 'Tersedia', true, 5),
    ('ba51c000-0000-0000-0000-000000000003', 'Background Music', 'Custom Audio & Autoplay', true, 6),
    ('ba51c000-0000-0000-0000-000000000003', 'Prioritas Pengerjaan', 'Express 24 Jam', true, 7),
    ('ba51c000-0000-0000-0000-000000000003', 'Kustomisasi Warna & Font', 'Bebas Kustom', true, 8)
ON CONFLICT DO NOTHING;

-- 4. Insert Sample Template & Template Version
INSERT INTO public.templates (id, category_id, name, slug, description, thumbnail_url, demo_url, is_active)
VALUES
    ('a1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111', 'Royal Gold Elegance', 'royal-gold-elegance', 'Desain pernikahan mewah dengan aksen warna gold dan tipografi klasik.', 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800', '/demo/royal-gold-elegance', true),
    ('a2222222-2222-2222-2222-222222222222', 'c1111111-1111-1111-1111-111111111111', 'Rustic Botanical', 'rustic-botanical', 'Sentuhan alam hangat dengan dedaunan hijau sage dan latar kayu estetik.', 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800', '/demo/rustic-botanical', true),
    ('a3333333-3333-3333-3333-333333333333', 'c2222222-2222-2222-2222-222222222222', 'Pastel Fiesta', 'pastel-fiesta', 'Tema ceria penuh warna pastel lembut untuk perayaan ulang tahun meriah.', 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800', '/demo/pastel-fiesta', true)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.template_versions (id, template_id, version_number, version_key, config, changelog)
VALUES
    ('b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 1, 'wedding/royal-gold-elegance/v1', '{"primaryColor": "#D4AF37", "secondaryColor": "#1A1A1A", "fontFamily": "Cinzel"}', 'Initial release'),
    ('b2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222', 1, 'wedding/rustic-botanical/v1', '{"primaryColor": "#8A9A5B", "secondaryColor": "#FDFBF7", "fontFamily": "Playfair Display"}', 'Initial release'),
    ('b3333333-3333-3333-3333-333333333333', 'a3333333-3333-3333-3333-333333333333', 1, 'birthday/pastel-fiesta/v1', '{"primaryColor": "#FFB7B2", "secondaryColor": "#E2F0CB", "fontFamily": "Poppins"}', 'Initial release')
ON CONFLICT (template_id, version_number) DO NOTHING;

-- Link current version back to templates
UPDATE public.templates SET current_version_id = 'b1111111-1111-1111-1111-111111111111' WHERE id = 'a1111111-1111-1111-1111-111111111111';
UPDATE public.templates SET current_version_id = 'b2222222-2222-2222-2222-222222222222' WHERE id = 'a2222222-2222-2222-2222-222222222222';
UPDATE public.templates SET current_version_id = 'b3333333-3333-3333-3333-333333333333' WHERE id = 'a3333333-3333-3333-3333-333333333333';
