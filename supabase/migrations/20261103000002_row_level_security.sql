-- =============================================================================
-- Migration: 20261103000002_row_level_security.sql
-- Description: Enable Row Level Security (RLS) & Policies on all 19 tables
-- =============================================================================

-- =============================================================================
-- 1. Authorization Helper Functions
-- =============================================================================

CREATE OR REPLACE FUNCTION public.has_admin_role()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND role IN ('admin', 'super_admin')
          AND is_active = true
    );
$$;

CREATE OR REPLACE FUNCTION public.has_super_admin_role()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND role = 'super_admin'
          AND is_active = true
    );
$$;

-- Grant execution to authenticated users
GRANT EXECUTE ON FUNCTION public.has_admin_role() TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_super_admin_role() TO authenticated;

-- =============================================================================
-- 2. Enable RLS on All Tables
-- =============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.template_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitation_contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revision_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitation_publications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_activity_logs ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- 3. Policies for Profiles
-- =============================================================================

CREATE POLICY "Users can view own profile or admins can view all"
ON public.profiles FOR SELECT
TO authenticated
USING (id = (SELECT auth.uid()) OR public.has_admin_role());

CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (id = (SELECT auth.uid()) OR public.has_super_admin_role())
WITH CHECK (id = (SELECT auth.uid()) OR public.has_super_admin_role());

-- =============================================================================
-- 4. Policies for Categories & Templates (Public Read, Admin Write)
-- =============================================================================

CREATE POLICY "Public read active categories"
ON public.categories FOR SELECT
TO anon, authenticated
USING (is_active = true OR public.has_admin_role());

CREATE POLICY "Admins manage categories"
ON public.categories FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "Public read active templates"
ON public.templates FOR SELECT
TO anon, authenticated
USING (is_active = true OR public.has_admin_role());

CREATE POLICY "Admins manage templates"
ON public.templates FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "Public read active template versions"
ON public.template_versions FOR SELECT
TO anon, authenticated
USING (is_active = true OR public.has_admin_role());

CREATE POLICY "Admins manage template versions"
ON public.template_versions FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

-- =============================================================================
-- 5. Policies for Packages & Features (Public Read, Admin Write)
-- =============================================================================

CREATE POLICY "Public read active packages"
ON public.packages FOR SELECT
TO anon, authenticated
USING (is_active = true OR public.has_admin_role());

CREATE POLICY "Admins manage packages"
ON public.packages FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "Public read package features"
ON public.package_features FOR SELECT
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.packages p
        WHERE p.id = package_features.package_id
          AND (p.is_active = true OR public.has_admin_role())
    )
);

CREATE POLICY "Admins manage package features"
ON public.package_features FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

-- =============================================================================
-- 6. Policies for Orders & Items
-- =============================================================================

CREATE POLICY "Customers view own orders, admins view all"
ON public.orders FOR SELECT
TO authenticated
USING (customer_id = (SELECT auth.uid()) OR public.has_admin_role());

CREATE POLICY "Customers can create orders"
ON public.orders FOR INSERT
TO authenticated
WITH CHECK (customer_id = (SELECT auth.uid()));

CREATE POLICY "Customers can update own pending orders or admins update"
ON public.orders FOR UPDATE
TO authenticated
USING (customer_id = (SELECT auth.uid()) OR public.has_admin_role())
WITH CHECK (customer_id = (SELECT auth.uid()) OR public.has_admin_role());

CREATE POLICY "Customers view own order items, admins view all"
ON public.order_items FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = order_items.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers can insert items for own order"
ON public.order_items FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = order_items.order_id
          AND o.customer_id = (SELECT auth.uid())
    )
);

CREATE POLICY "Admins manage order items"
ON public.order_items FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

-- =============================================================================
-- 7. Policies for Payments & Events
-- =============================================================================

CREATE POLICY "Customers view own payments, admins view all"
ON public.payments FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = payments.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers can create payments for own orders"
ON public.payments FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = payments.order_id
          AND o.customer_id = (SELECT auth.uid())
    )
    OR public.has_admin_role()
);

CREATE POLICY "Customers update own payment proof or admins verify"
ON public.payments FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = payments.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = payments.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Admins view and manage payment events"
ON public.payment_events FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

-- =============================================================================
-- 8. Policies for Invitation Contents & Media
-- =============================================================================

CREATE POLICY "Customers view and edit own invitation content, admins manage"
ON public.invitation_contents FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = invitation_contents.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers insert/update own invitation content, admins manage"
ON public.invitation_contents FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = invitation_contents.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers update own invitation content, admins manage"
ON public.invitation_contents FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = invitation_contents.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = invitation_contents.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "View media assets"
ON public.media_assets FOR SELECT
TO anon, authenticated
USING (
    visibility = 'public'
    OR uploaded_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = media_assets.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers and admins can upload media assets"
ON public.media_assets FOR INSERT
TO authenticated
WITH CHECK (
    uploaded_by = (SELECT auth.uid())
    OR public.has_admin_role()
);

CREATE POLICY "Customers and admins can delete own media assets"
ON public.media_assets FOR DELETE
TO authenticated
USING (
    uploaded_by = (SELECT auth.uid())
    OR public.has_admin_role()
);

-- =============================================================================
-- 9. Policies for Revisions & Revision Messages
-- =============================================================================

CREATE POLICY "Customers view own revisions, admins view all"
ON public.revisions FOR SELECT
TO authenticated
USING (
    requested_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = revisions.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers create revisions for own orders"
ON public.revisions FOR INSERT
TO authenticated
WITH CHECK (
    requested_by = (SELECT auth.uid())
    AND EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = revisions.order_id
          AND o.customer_id = (SELECT auth.uid())
    )
);

CREATE POLICY "Admins update revisions"
ON public.revisions FOR UPDATE
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "View revision messages"
ON public.revision_messages FOR SELECT
TO authenticated
USING (
    sender_id = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.revisions r
        JOIN public.orders o ON o.id = r.order_id
        WHERE r.id = revision_messages.revision_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Send revision messages"
ON public.revision_messages FOR INSERT
TO authenticated
WITH CHECK (
    sender_id = (SELECT auth.uid())
    AND EXISTS (
        SELECT 1 FROM public.revisions r
        JOIN public.orders o ON o.id = r.order_id
        WHERE r.id = revision_messages.revision_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

-- =============================================================================
-- 10. Policies for Publications, Guests & RSVPs
-- =============================================================================

CREATE POLICY "Public read published invitations or customer/admin read"
ON public.invitation_publications FOR SELECT
TO anon, authenticated
USING (
    (status = 'published' AND (expires_at IS NULL OR expires_at > NOW()))
    OR EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = invitation_publications.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Admins manage invitation publications"
ON public.invitation_publications FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "Customers view and manage guests for own publications"
ON public.guests FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.invitation_publications p
        JOIN public.orders o ON o.id = p.order_id
        WHERE p.id = guests.publication_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.invitation_publications p
        JOIN public.orders o ON o.id = p.order_id
        WHERE p.id = guests.publication_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Customers view RSVPs for own publications"
ON public.rsvps FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.guests g
        JOIN public.invitation_publications p ON p.id = g.publication_id
        JOIN public.orders o ON o.id = p.order_id
        WHERE g.id = rsvps.guest_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Public can submit and update RSVP"
ON public.rsvps FOR INSERT
TO anon, authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.guests g
        JOIN public.invitation_publications p ON p.id = g.publication_id
        WHERE g.id = rsvps.guest_id
          AND p.status = 'published'
          AND (p.expires_at IS NULL OR p.expires_at > NOW())
    )
);

CREATE POLICY "Public can update own RSVP"
ON public.rsvps FOR UPDATE
TO anon, authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.guests g
        JOIN public.invitation_publications p ON p.id = g.publication_id
        WHERE g.id = rsvps.guest_id
          AND p.status = 'published'
          AND (p.expires_at IS NULL OR p.expires_at > NOW())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.guests g
        JOIN public.invitation_publications p ON p.id = g.publication_id
        WHERE g.id = rsvps.guest_id
          AND p.status = 'published'
          AND (p.expires_at IS NULL OR p.expires_at > NOW())
    )
);

-- =============================================================================
-- 11. Policies for Order History & Admin Audit Logs
-- =============================================================================

CREATE POLICY "Customers view status history of own orders, admins view all"
ON public.order_status_history FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.orders o
        WHERE o.id = order_status_history.order_id
          AND (o.customer_id = (SELECT auth.uid()) OR public.has_admin_role())
    )
);

CREATE POLICY "Admins insert order status history"
ON public.order_status_history FOR INSERT
TO authenticated
WITH CHECK (public.has_admin_role());

CREATE POLICY "Admins view and insert activity logs"
ON public.admin_activity_logs FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());
