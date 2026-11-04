-- =============================================================================
-- Migration: 20261103000001_initial_schema.sql
-- Description: Initial schema for Digital Invitation Platform
-- Entities: 19 core tables, relationships, indexes, constraints, triggers
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. Helper Functions & Triggers
-- =============================================================================

-- Auto update updated_at timestamp
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- =============================================================================
-- 2. User Profiles
-- =============================================================================

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(150),
    email VARCHAR(255),
    phone VARCHAR(30),
    avatar_url TEXT,
    role VARCHAR(30) NOT NULL DEFAULT 'customer'
        CHECK (role IN ('customer', 'admin', 'super_admin')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger to create profile when auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
        NEW.email,
        'customer'
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- 3. Categories & Templates
-- =============================================================================

CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    thumbnail_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_categories_updated_at
BEFORE UPDATE ON public.categories
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    thumbnail_url TEXT,
    demo_url TEXT,
    current_version_id UUID,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_templates_updated_at
BEFORE UPDATE ON public.templates
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.template_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID NOT NULL REFERENCES public.templates(id) ON DELETE RESTRICT,
    version_number INTEGER NOT NULL,
    version_key VARCHAR(100) NOT NULL,
    config JSONB NOT NULL DEFAULT '{}'::jsonb,
    changelog TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (template_id, version_number),
    UNIQUE (template_id, version_key)
);

-- Foreign key linking current_version_id to template_versions
ALTER TABLE public.templates
ADD CONSTRAINT fk_templates_current_version
FOREIGN KEY (current_version_id)
REFERENCES public.template_versions(id)
ON DELETE RESTRICT;

-- =============================================================================
-- 4. Packages & Features
-- =============================================================================

CREATE TABLE public.packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC(14,2) NOT NULL CHECK (price >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'IDR',
    revision_limit INTEGER NOT NULL DEFAULT 0 CHECK (revision_limit >= 0),
    duration_days INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_packages_updated_at
BEFORE UPDATE ON public.packages
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.package_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID NOT NULL REFERENCES public.packages(id) ON DELETE CASCADE,
    feature_name VARCHAR(150) NOT NULL,
    feature_value TEXT,
    is_included BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- =============================================================================
-- 5. Orders & Order Items
-- =============================================================================

CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(40) NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    status VARCHAR(30) NOT NULL DEFAULT 'pending_payment'
        CHECK (status IN (
            'pending_payment',
            'paid',
            'processing',
            'completed',
            'cancelled',
            'expired'
        )),
    subtotal NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    discount_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    total_amount NUMERIC(14,2) NOT NULL CHECK (total_amount >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'IDR',
    customer_notes TEXT,
    expires_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    template_id UUID NOT NULL REFERENCES public.templates(id) ON DELETE RESTRICT,
    package_id UUID NOT NULL REFERENCES public.packages(id) ON DELETE RESTRICT,
    template_version_id UUID REFERENCES public.template_versions(id) ON DELETE RESTRICT,
    template_name_snapshot VARCHAR(150) NOT NULL,
    package_name_snapshot VARCHAR(100) NOT NULL,
    unit_price NUMERIC(14,2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    subtotal NUMERIC(14,2) NOT NULL CHECK (subtotal >= 0),
    package_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 6. Payments & Webhook Events
-- =============================================================================

CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('bank_transfer', 'gateway')),
    provider VARCHAR(50),
    provider_transaction_id VARCHAR(255),
    amount NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'IDR',
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',
            'waiting_verification',
            'paid',
            'failed',
            'expired',
            'refunded'
        )),
    payment_url TEXT,
    proof_storage_path TEXT,
    verified_by UUID REFERENCES public.profiles(id),
    verified_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_payments_updated_at
BEFORE UPDATE ON public.payments
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.payment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES public.payments(id) ON DELETE SET NULL,
    provider VARCHAR(50) NOT NULL,
    provider_event_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    signature_valid BOOLEAN NOT NULL DEFAULT FALSE,
    processed_at TIMESTAMPTZ,
    processing_status VARCHAR(30) NOT NULL DEFAULT 'pending'
        CHECK (processing_status IN ('pending', 'processed', 'failed', 'ignored')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (provider, provider_event_id)
);

-- =============================================================================
-- 7. Invitation Contents & Media Assets
-- =============================================================================

CREATE TABLE public.invitation_contents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES public.orders(id) ON DELETE RESTRICT,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    content_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    production_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    submission_status VARCHAR(30) NOT NULL DEFAULT 'draft'
        CHECK (submission_status IN ('draft', 'submitted', 'in_review', 'incomplete', 'approved')),
    production_status VARCHAR(30) NOT NULL DEFAULT 'waiting_data'
        CHECK (production_status IN (
            'waiting_data',
            'data_review',
            'queued',
            'in_progress',
            'preview_ready',
            'revision_requested',
            'approved',
            'completed'
        )),
    submitted_at TIMESTAMPTZ,
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_invitation_contents_updated_at
BEFORE UPDATE ON public.invitation_contents
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.media_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    file_name VARCHAR(255) NOT NULL,
    storage_bucket VARCHAR(100) NOT NULL,
    storage_path TEXT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL CHECK (file_size >= 0),
    asset_type VARCHAR(30) NOT NULL
        CHECK (asset_type IN ('image', 'audio', 'document', 'gallery', 'profile', 'payment_proof')),
    visibility VARCHAR(20) NOT NULL DEFAULT 'private'
        CHECK (visibility IN ('private', 'public')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 8. Revisions & Revision Messages
-- =============================================================================

CREATE TABLE public.revisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
    requested_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    revision_number INTEGER NOT NULL CHECK (revision_number > 0),
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'requested'
        CHECK (status IN ('requested', 'accepted', 'in_progress', 'completed', 'rejected')),
    assigned_to UUID REFERENCES public.profiles(id),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_revisions_updated_at
BEFORE UPDATE ON public.revisions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.revision_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    revision_id UUID NOT NULL REFERENCES public.revisions(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    message TEXT NOT NULL,
    attachments JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 9. Publications, Guests & RSVPs
-- =============================================================================

CREATE TABLE public.invitation_publications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
    template_version_id UUID NOT NULL REFERENCES public.template_versions(id) ON DELETE RESTRICT,
    slug VARCHAR(180) NOT NULL UNIQUE,
    content_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
    template_config_snapshot JSONB NOT NULL DEFAULT '{}'::jsonb,
    status VARCHAR(30) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'published', 'unpublished', 'expired')),
    published_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    unpublished_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.guests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    publication_id UUID NOT NULL REFERENCES public.invitation_publications(id) ON DELETE CASCADE,
    guest_name VARCHAR(150) NOT NULL,
    guest_token_hash TEXT,
    phone VARCHAR(30),
    invitation_group VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_guests_updated_at
BEFORE UPDATE ON public.guests
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE public.rsvps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_id UUID NOT NULL UNIQUE REFERENCES public.guests(id) ON DELETE CASCADE,
    attendance_status VARCHAR(30) NOT NULL
        CHECK (attendance_status IN ('attending', 'not_attending', 'maybe')),
    guest_count INTEGER NOT NULL DEFAULT 1 CHECK (guest_count > 0),
    message TEXT,
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_rsvps_updated_at
BEFORE UPDATE ON public.rsvps
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- 10. Audit & History
-- =============================================================================

CREATE TABLE public.order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_by UUID REFERENCES public.profiles(id),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.admin_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 11. Performance Indexes
-- =============================================================================

-- Profiles
CREATE INDEX idx_profiles_role ON public.profiles (role);
CREATE INDEX idx_profiles_email ON public.profiles (email);

-- Categories & Templates
CREATE INDEX idx_categories_active_order ON public.categories (is_active, sort_order);
CREATE INDEX idx_templates_category_active ON public.templates (category_id, is_active);
CREATE INDEX idx_template_versions_template ON public.template_versions (template_id, version_number);

-- Packages
CREATE INDEX idx_packages_active ON public.packages (is_active);
CREATE INDEX idx_package_features_package ON public.package_features (package_id, sort_order);

-- Orders & Items
CREATE INDEX idx_orders_customer_created ON public.orders (customer_id, created_at DESC);
CREATE INDEX idx_orders_status_created ON public.orders (status, created_at DESC);
CREATE INDEX idx_order_items_order ON public.order_items (order_id);

-- Payments & Events
CREATE INDEX idx_payments_order_created ON public.payments (order_id, created_at DESC);
CREATE INDEX idx_payments_status ON public.payments (status);
CREATE INDEX idx_payments_provider_tx ON public.payments (provider_transaction_id);
CREATE INDEX idx_payment_events_payment ON public.payment_events (payment_id);

-- Invitation Contents & Media
CREATE INDEX idx_invitation_contents_order ON public.invitation_contents (order_id);
CREATE INDEX idx_media_assets_order_created ON public.media_assets (order_id, created_at DESC);

-- Revisions
CREATE INDEX idx_revisions_order_created ON public.revisions (order_id, created_at DESC);
CREATE INDEX idx_revision_messages_revision ON public.revision_messages (revision_id, created_at ASC);

-- Publications, Guests & RSVPs
CREATE INDEX idx_publications_status_expiry ON public.invitation_publications (status, expires_at);
CREATE INDEX idx_publications_order ON public.invitation_publications (order_id);
CREATE INDEX idx_guests_publication ON public.guests (publication_id);
CREATE INDEX idx_rsvps_guest ON public.rsvps (guest_id);

-- History & Logs
CREATE INDEX idx_order_status_history_order ON public.order_status_history (order_id, created_at DESC);
CREATE INDEX idx_admin_activity_logs_actor ON public.admin_activity_logs (actor_id, created_at DESC);
CREATE INDEX idx_admin_activity_logs_entity ON public.admin_activity_logs (entity_type, entity_id);
