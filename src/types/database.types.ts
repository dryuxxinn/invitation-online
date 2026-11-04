export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type UserRole = "customer" | "admin" | "super_admin";

export type OrderStatus =
  | "pending_payment"
  | "paid"
  | "processing"
  | "completed"
  | "cancelled"
  | "expired";

export type PaymentMethod = "bank_transfer" | "gateway";

export type PaymentStatus =
  | "pending"
  | "waiting_verification"
  | "paid"
  | "failed"
  | "expired"
  | "refunded";

export type SubmissionStatus =
  | "draft"
  | "submitted"
  | "in_review"
  | "incomplete"
  | "approved";

export type ProductionStatus =
  | "waiting_data"
  | "data_review"
  | "queued"
  | "in_progress"
  | "preview_ready"
  | "revision_requested"
  | "approved"
  | "completed";

export type PublicationStatus =
  | "draft"
  | "published"
  | "unpublished"
  | "expired";

export type RevisionStatus =
  | "requested"
  | "accepted"
  | "in_progress"
  | "completed"
  | "rejected";

export type AttendanceStatus = "attending" | "not_attending" | "maybe";

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          full_name: string | null;
          email: string | null;
          phone: string | null;
          avatar_url: string | null;
          role: UserRole;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          full_name?: string | null;
          email?: string | null;
          phone?: string | null;
          avatar_url?: string | null;
          role?: UserRole;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          full_name?: string | null;
          email?: string | null;
          phone?: string | null;
          avatar_url?: string | null;
          role?: UserRole;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      categories: {
        Row: {
          id: string;
          name: string;
          slug: string;
          description: string | null;
          thumbnail_url: string | null;
          is_active: boolean;
          sort_order: number;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          slug: string;
          description?: string | null;
          thumbnail_url?: string | null;
          is_active?: boolean;
          sort_order?: number;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          slug?: string;
          description?: string | null;
          thumbnail_url?: string | null;
          is_active?: boolean;
          sort_order?: number;
          created_at?: string;
          updated_at?: string;
        };
      };
      templates: {
        Row: {
          id: string;
          category_id: string;
          name: string;
          slug: string;
          description: string | null;
          thumbnail_url: string | null;
          demo_url: string | null;
          current_version_id: string | null;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          category_id: string;
          name: string;
          slug: string;
          description?: string | null;
          thumbnail_url?: string | null;
          demo_url?: string | null;
          current_version_id?: string | null;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          category_id?: string;
          name?: string;
          slug?: string;
          description?: string | null;
          thumbnail_url?: string | null;
          demo_url?: string | null;
          current_version_id?: string | null;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      template_versions: {
        Row: {
          id: string;
          template_id: string;
          version_number: number;
          version_key: string;
          config: Json;
          changelog: string | null;
          is_active: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          template_id: string;
          version_number: number;
          version_key: string;
          config?: Json;
          changelog?: string | null;
          is_active?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          template_id?: string;
          version_number?: number;
          version_key?: string;
          config?: Json;
          changelog?: string | null;
          is_active?: boolean;
          created_at?: string;
        };
      };
      packages: {
        Row: {
          id: string;
          name: string;
          slug: string;
          description: string | null;
          price: number;
          currency: string;
          revision_limit: number;
          duration_days: number | null;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          slug: string;
          description?: string | null;
          price: number;
          currency?: string;
          revision_limit?: number;
          duration_days?: number | null;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          slug?: string;
          description?: string | null;
          price?: number;
          currency?: string;
          revision_limit?: number;
          duration_days?: number | null;
          is_active?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      package_features: {
        Row: {
          id: string;
          package_id: string;
          feature_name: string;
          feature_value: string | null;
          is_included: boolean;
          sort_order: number;
        };
        Insert: {
          id?: string;
          package_id: string;
          feature_name: string;
          feature_value?: string | null;
          is_included?: boolean;
          sort_order?: number;
        };
        Update: {
          id?: string;
          package_id?: string;
          feature_name?: string;
          feature_value?: string | null;
          is_included?: boolean;
          sort_order?: number;
        };
      };
      orders: {
        Row: {
          id: string;
          order_number: string;
          customer_id: string;
          status: OrderStatus;
          subtotal: number;
          discount_amount: number;
          total_amount: number;
          currency: string;
          customer_notes: string | null;
          expires_at: string | null;
          paid_at: string | null;
          completed_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          order_number: string;
          customer_id: string;
          status?: OrderStatus;
          subtotal?: number;
          discount_amount?: number;
          total_amount: number;
          currency?: string;
          customer_notes?: string | null;
          expires_at?: string | null;
          paid_at?: string | null;
          completed_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          order_number?: string;
          customer_id?: string;
          status?: OrderStatus;
          subtotal?: number;
          discount_amount?: number;
          total_amount?: number;
          currency?: string;
          customer_notes?: string | null;
          expires_at?: string | null;
          paid_at?: string | null;
          completed_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      order_items: {
        Row: {
          id: string;
          order_id: string;
          template_id: string;
          package_id: string;
          template_version_id: string | null;
          template_name_snapshot: string;
          package_name_snapshot: string;
          unit_price: number;
          quantity: number;
          subtotal: number;
          package_snapshot: Json;
          created_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          template_id: string;
          package_id: string;
          template_version_id?: string | null;
          template_name_snapshot: string;
          package_name_snapshot: string;
          unit_price: number;
          quantity?: number;
          subtotal: number;
          package_snapshot?: Json;
          created_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          template_id?: string;
          package_id?: string;
          template_version_id?: string | null;
          template_name_snapshot?: string;
          package_name_snapshot?: string;
          unit_price?: number;
          quantity?: number;
          subtotal?: number;
          package_snapshot?: Json;
          created_at?: string;
        };
      };
      payments: {
        Row: {
          id: string;
          order_id: string;
          payment_method: PaymentMethod;
          provider: string | null;
          provider_transaction_id: string | null;
          amount: number;
          currency: string;
          status: PaymentStatus;
          payment_url: string | null;
          proof_storage_path: string | null;
          verified_by: string | null;
          verified_at: string | null;
          paid_at: string | null;
          expires_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          payment_method: PaymentMethod;
          provider?: string | null;
          provider_transaction_id?: string | null;
          amount: number;
          currency?: string;
          status?: PaymentStatus;
          payment_url?: string | null;
          proof_storage_path?: string | null;
          verified_by?: string | null;
          verified_at?: string | null;
          paid_at?: string | null;
          expires_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          payment_method?: PaymentMethod;
          provider?: string | null;
          provider_transaction_id?: string | null;
          amount?: number;
          currency?: string;
          status?: PaymentStatus;
          payment_url?: string | null;
          proof_storage_path?: string | null;
          verified_by?: string | null;
          verified_at?: string | null;
          paid_at?: string | null;
          expires_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      payment_events: {
        Row: {
          id: string;
          payment_id: string | null;
          provider: string;
          provider_event_id: string;
          event_type: string;
          payload: Json;
          signature_valid: boolean;
          processed_at: string | null;
          processing_status: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          payment_id?: string | null;
          provider: string;
          provider_event_id: string;
          event_type: string;
          payload?: Json;
          signature_valid?: boolean;
          processed_at?: string | null;
          processing_status?: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          payment_id?: string | null;
          provider?: string;
          provider_event_id?: string;
          event_type?: string;
          payload?: Json;
          signature_valid?: boolean;
          processed_at?: string | null;
          processing_status?: string;
          created_at?: string;
        };
      };
      invitation_contents: {
        Row: {
          id: string;
          order_id: string;
          category_id: string;
          content_json: Json;
          production_json: Json;
          submission_status: SubmissionStatus;
          production_status: ProductionStatus;
          submitted_at: string | null;
          reviewed_at: string | null;
          reviewed_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          category_id: string;
          content_json?: Json;
          production_json?: Json;
          submission_status?: SubmissionStatus;
          production_status?: ProductionStatus;
          submitted_at?: string | null;
          reviewed_at?: string | null;
          reviewed_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          category_id?: string;
          content_json?: Json;
          production_json?: Json;
          submission_status?: SubmissionStatus;
          production_status?: ProductionStatus;
          submitted_at?: string | null;
          reviewed_at?: string | null;
          reviewed_by?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      media_assets: {
        Row: {
          id: string;
          order_id: string;
          uploaded_by: string;
          file_name: string;
          storage_bucket: string;
          storage_path: string;
          mime_type: string;
          file_size: number;
          asset_type: string;
          visibility: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          uploaded_by: string;
          file_name: string;
          storage_bucket: string;
          storage_path: string;
          mime_type: string;
          file_size: number;
          asset_type: string;
          visibility?: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          uploaded_by?: string;
          file_name?: string;
          storage_bucket?: string;
          storage_path?: string;
          mime_type?: string;
          file_size?: number;
          asset_type?: string;
          visibility?: string;
          created_at?: string;
        };
      };
      revisions: {
        Row: {
          id: string;
          order_id: string;
          requested_by: string;
          revision_number: number;
          description: string;
          status: RevisionStatus;
          assigned_to: string | null;
          completed_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          requested_by: string;
          revision_number: number;
          description: string;
          status?: RevisionStatus;
          assigned_to?: string | null;
          completed_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          requested_by?: string;
          revision_number?: number;
          description?: string;
          status?: RevisionStatus;
          assigned_to?: string | null;
          completed_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      revision_messages: {
        Row: {
          id: string;
          revision_id: string;
          sender_id: string;
          message: string;
          attachments: Json;
          created_at: string;
        };
        Insert: {
          id?: string;
          revision_id: string;
          sender_id: string;
          message: string;
          attachments?: Json;
          created_at?: string;
        };
        Update: {
          id?: string;
          revision_id?: string;
          sender_id?: string;
          message?: string;
          attachments?: Json;
          created_at?: string;
        };
      };
      invitation_publications: {
        Row: {
          id: string;
          order_id: string;
          template_version_id: string;
          slug: string;
          content_snapshot: Json;
          template_config_snapshot: Json;
          status: PublicationStatus;
          published_at: string | null;
          expires_at: string | null;
          unpublished_at: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          template_version_id: string;
          slug: string;
          content_snapshot?: Json;
          template_config_snapshot?: Json;
          status?: PublicationStatus;
          published_at?: string | null;
          expires_at?: string | null;
          unpublished_at?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          template_version_id?: string;
          slug?: string;
          content_snapshot?: Json;
          template_config_snapshot?: Json;
          status?: PublicationStatus;
          published_at?: string | null;
          expires_at?: string | null;
          unpublished_at?: string | null;
          created_at?: string;
        };
      };
      guests: {
        Row: {
          id: string;
          publication_id: string;
          guest_name: string;
          guest_token_hash: string | null;
          phone: string | null;
          invitation_group: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          publication_id: string;
          guest_name: string;
          guest_token_hash?: string | null;
          phone?: string | null;
          invitation_group?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          publication_id?: string;
          guest_name?: string;
          guest_token_hash?: string | null;
          phone?: string | null;
          invitation_group?: string | null;
          created_at?: string;
          updated_at?: string;
        };
      };
      rsvps: {
        Row: {
          id: string;
          guest_id: string;
          attendance_status: AttendanceStatus;
          guest_count: number;
          message: string | null;
          submitted_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          guest_id: string;
          attendance_status: AttendanceStatus;
          guest_count?: number;
          message?: string | null;
          submitted_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          guest_id?: string;
          attendance_status?: AttendanceStatus;
          guest_count?: number;
          message?: string | null;
          submitted_at?: string;
          updated_at?: string;
        };
      };
      order_status_history: {
        Row: {
          id: string;
          order_id: string;
          old_status: string | null;
          new_status: string;
          changed_by: string | null;
          notes: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          order_id: string;
          old_status?: string | null;
          new_status: string;
          changed_by?: string | null;
          notes?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          order_id?: string;
          old_status?: string | null;
          new_status?: string;
          changed_by?: string | null;
          notes?: string | null;
          created_at?: string;
        };
      };
      admin_activity_logs: {
        Row: {
          id: string;
          actor_id: string;
          action: string;
          entity_type: string;
          entity_id: string | null;
          metadata: Json;
          ip_address: string | null;
          user_agent: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          actor_id: string;
          action: string;
          entity_type: string;
          entity_id?: string | null;
          metadata?: Json;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          actor_id?: string;
          action?: string;
          entity_type?: string;
          entity_id?: string | null;
          metadata?: Json;
          ip_address?: string | null;
          user_agent?: string | null;
          created_at?: string;
        };
      };
    };
  };
}
