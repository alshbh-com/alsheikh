export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      activity_logs: {
        Row: {
          action: string
          created_at: string
          details: Json | null
          id: string
          user_id: string | null
        }
        Insert: {
          action: string
          created_at?: string
          details?: Json | null
          id?: string
          user_id?: string | null
        }
        Update: {
          action?: string
          created_at?: string
          details?: Json | null
          id?: string
          user_id?: string | null
        }
        Relationships: []
      }
      advances: {
        Row: {
          amount: number | null
          created_at: string
          created_by: string | null
          id: string
          reason: string | null
          type: string | null
          user_id: string
        }
        Insert: {
          amount?: number | null
          created_at?: string
          created_by?: string | null
          id?: string
          reason?: string | null
          type?: string | null
          user_id: string
        }
        Update: {
          amount?: number | null
          created_at?: string
          created_by?: string | null
          id?: string
          reason?: string | null
          type?: string | null
          user_id?: string
        }
        Relationships: []
      }
      app_settings: {
        Row: {
          key: string
          updated_at: string
          value: string | null
        }
        Insert: {
          key: string
          updated_at?: string
          value?: string | null
        }
        Update: {
          key?: string
          updated_at?: string
          value?: string | null
        }
        Relationships: []
      }
      cash_flow_entries: {
        Row: {
          amount: number | null
          created_at: string
          entry_date: string
          id: string
          notes: string | null
          office_id: string | null
          reason: string | null
          type: string | null
        }
        Insert: {
          amount?: number | null
          created_at?: string
          entry_date?: string
          id?: string
          notes?: string | null
          office_id?: string | null
          reason?: string | null
          type?: string | null
        }
        Update: {
          amount?: number | null
          created_at?: string
          entry_date?: string
          id?: string
          notes?: string | null
          office_id?: string | null
          reason?: string | null
          type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "cash_flow_entries_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      courier_bonuses: {
        Row: {
          amount: number | null
          courier_id: string
          created_at: string
          created_by: string | null
          id: string
          reason: string | null
        }
        Insert: {
          amount?: number | null
          courier_id: string
          created_at?: string
          created_by?: string | null
          id?: string
          reason?: string | null
        }
        Update: {
          amount?: number | null
          courier_id?: string
          created_at?: string
          created_by?: string | null
          id?: string
          reason?: string | null
        }
        Relationships: []
      }
      courier_locations: {
        Row: {
          courier_id: string
          id: string
          latitude: number
          longitude: number
          updated_at: string
        }
        Insert: {
          courier_id: string
          id?: string
          latitude: number
          longitude: number
          updated_at?: string
        }
        Update: {
          courier_id?: string
          id?: string
          latitude?: number
          longitude?: number
          updated_at?: string
        }
        Relationships: []
      }
      delivery_prices: {
        Row: {
          created_at: string
          governorate: string
          id: string
          office_id: string
          pickup_price: number | null
          price: number | null
        }
        Insert: {
          created_at?: string
          governorate: string
          id?: string
          office_id: string
          pickup_price?: number | null
          price?: number | null
        }
        Update: {
          created_at?: string
          governorate?: string
          id?: string
          office_id?: string
          pickup_price?: number | null
          price?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "delivery_prices_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      diaries: {
        Row: {
          closed_at: string | null
          created_at: string
          diary_date: string
          diary_number: number
          id: string
          is_archived: boolean | null
          is_closed: boolean | null
          lock_status_updates: boolean | null
          notes: string | null
          office_id: string
          prevent_new_orders: boolean | null
          updated_at: string
        }
        Insert: {
          closed_at?: string | null
          created_at?: string
          diary_date?: string
          diary_number: number
          id?: string
          is_archived?: boolean | null
          is_closed?: boolean | null
          lock_status_updates?: boolean | null
          notes?: string | null
          office_id: string
          prevent_new_orders?: boolean | null
          updated_at?: string
        }
        Update: {
          closed_at?: string | null
          created_at?: string
          diary_date?: string
          diary_number?: number
          id?: string
          is_archived?: boolean | null
          is_closed?: boolean | null
          lock_status_updates?: boolean | null
          notes?: string | null
          office_id?: string
          prevent_new_orders?: boolean | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "diaries_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      diary_orders: {
        Row: {
          arrived: number | null
          balance: number | null
          created_at: string
          diary_id: string
          due_with_postponed: boolean | null
          executed: number | null
          extra_due: number | null
          fees: number | null
          id: string
          manual_arrived_total: number | null
          n_column: string | null
          orange_arrived: number | null
          orange_notes: string | null
          orange_pickup: number | null
          orange_shipping: number | null
          order_id: string
          pickup: number | null
          postponed: number | null
          return_status: string | null
          returns: number | null
          total_price: number | null
          updated_at: string
        }
        Insert: {
          arrived?: number | null
          balance?: number | null
          created_at?: string
          diary_id: string
          due_with_postponed?: boolean | null
          executed?: number | null
          extra_due?: number | null
          fees?: number | null
          id?: string
          manual_arrived_total?: number | null
          n_column?: string | null
          orange_arrived?: number | null
          orange_notes?: string | null
          orange_pickup?: number | null
          orange_shipping?: number | null
          order_id: string
          pickup?: number | null
          postponed?: number | null
          return_status?: string | null
          returns?: number | null
          total_price?: number | null
          updated_at?: string
        }
        Update: {
          arrived?: number | null
          balance?: number | null
          created_at?: string
          diary_id?: string
          due_with_postponed?: boolean | null
          executed?: number | null
          extra_due?: number | null
          fees?: number | null
          id?: string
          manual_arrived_total?: number | null
          n_column?: string | null
          orange_arrived?: number | null
          orange_notes?: string | null
          orange_pickup?: number | null
          orange_shipping?: number | null
          order_id?: string
          pickup?: number | null
          postponed?: number | null
          return_status?: string | null
          returns?: number | null
          total_price?: number | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "diary_orders_diary_id_fkey"
            columns: ["diary_id"]
            isOneToOne: false
            referencedRelation: "diaries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "diary_orders_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      expenses: {
        Row: {
          amount: number | null
          category: string | null
          created_at: string
          expense_date: string
          expense_name: string
          id: string
          notes: string | null
          office_id: string | null
        }
        Insert: {
          amount?: number | null
          category?: string | null
          created_at?: string
          expense_date?: string
          expense_name: string
          id?: string
          notes?: string | null
          office_id?: string | null
        }
        Update: {
          amount?: number | null
          category?: string | null
          created_at?: string
          expense_date?: string
          expense_name?: string
          id?: string
          notes?: string | null
          office_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "expenses_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      messages: {
        Row: {
          created_at: string
          id: string
          is_read: boolean | null
          message: string
          receiver_id: string
          sender_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_read?: boolean | null
          message: string
          receiver_id: string
          sender_id: string
        }
        Update: {
          created_at?: string
          id?: string
          is_read?: boolean | null
          message?: string
          receiver_id?: string
          sender_id?: string
        }
        Relationships: []
      }
      office_daily_closings: {
        Row: {
          closing_date: string
          created_at: string
          data_json: Json | null
          id: string
          is_closed: boolean | null
          is_locked: boolean | null
          office_id: string
          pickup_rate: number | null
          prevent_add: boolean | null
          updated_at: string
        }
        Insert: {
          closing_date?: string
          created_at?: string
          data_json?: Json | null
          id?: string
          is_closed?: boolean | null
          is_locked?: boolean | null
          office_id: string
          pickup_rate?: number | null
          prevent_add?: boolean | null
          updated_at?: string
        }
        Update: {
          closing_date?: string
          created_at?: string
          data_json?: Json | null
          id?: string
          is_closed?: boolean | null
          is_locked?: boolean | null
          office_id?: string
          pickup_rate?: number | null
          prevent_add?: boolean | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "office_daily_closings_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      office_payments: {
        Row: {
          amount: number | null
          created_at: string
          created_by: string | null
          id: string
          notes: string | null
          office_id: string
          type: string | null
        }
        Insert: {
          amount?: number | null
          created_at?: string
          created_by?: string | null
          id?: string
          notes?: string | null
          office_id: string
          type?: string | null
        }
        Update: {
          amount?: number | null
          created_at?: string
          created_by?: string | null
          id?: string
          notes?: string | null
          office_id?: string
          type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "office_payments_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      offices: {
        Row: {
          address: string | null
          can_add_orders: boolean | null
          created_at: string
          id: string
          name: string
          notes: string | null
          owner_name: string | null
          owner_phone: string | null
          specialty: string | null
          updated_at: string
        }
        Insert: {
          address?: string | null
          can_add_orders?: boolean | null
          created_at?: string
          id?: string
          name: string
          notes?: string | null
          owner_name?: string | null
          owner_phone?: string | null
          specialty?: string | null
          updated_at?: string
        }
        Update: {
          address?: string | null
          can_add_orders?: boolean | null
          created_at?: string
          id?: string
          name?: string
          notes?: string | null
          owner_name?: string | null
          owner_phone?: string | null
          specialty?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      order_notes: {
        Row: {
          created_at: string
          id: string
          note: string
          order_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          note: string
          order_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          note?: string
          order_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_notes_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      order_statuses: {
        Row: {
          color: string | null
          created_at: string
          id: string
          name: string
          sort_order: number | null
        }
        Insert: {
          color?: string | null
          created_at?: string
          id?: string
          name: string
          sort_order?: number | null
        }
        Update: {
          color?: string | null
          created_at?: string
          id?: string
          name?: string
          sort_order?: number | null
        }
        Relationships: []
      }
      orders: {
        Row: {
          address: string | null
          barcode: string | null
          color: string | null
          courier_id: string | null
          created_at: string
          customer_code: string | null
          customer_name: string
          customer_phone: string
          delivery_price: number | null
          id: string
          is_closed: boolean | null
          is_courier_closed: boolean | null
          is_settled: boolean | null
          notes: string | null
          office_id: string | null
          partial_amount: number | null
          price: number | null
          priority: string | null
          product_id: string | null
          product_name: string | null
          quantity: number | null
          shipping_paid: number | null
          size: string | null
          status_id: string | null
          tracking_id: string | null
          updated_at: string
        }
        Insert: {
          address?: string | null
          barcode?: string | null
          color?: string | null
          courier_id?: string | null
          created_at?: string
          customer_code?: string | null
          customer_name: string
          customer_phone: string
          delivery_price?: number | null
          id?: string
          is_closed?: boolean | null
          is_courier_closed?: boolean | null
          is_settled?: boolean | null
          notes?: string | null
          office_id?: string | null
          partial_amount?: number | null
          price?: number | null
          priority?: string | null
          product_id?: string | null
          product_name?: string | null
          quantity?: number | null
          shipping_paid?: number | null
          size?: string | null
          status_id?: string | null
          tracking_id?: string | null
          updated_at?: string
        }
        Update: {
          address?: string | null
          barcode?: string | null
          color?: string | null
          courier_id?: string | null
          created_at?: string
          customer_code?: string | null
          customer_name?: string
          customer_phone?: string
          delivery_price?: number | null
          id?: string
          is_closed?: boolean | null
          is_courier_closed?: boolean | null
          is_settled?: boolean | null
          notes?: string | null
          office_id?: string | null
          partial_amount?: number | null
          price?: number | null
          priority?: string | null
          product_id?: string | null
          product_name?: string | null
          quantity?: number | null
          shipping_paid?: number | null
          size?: string | null
          status_id?: string | null
          tracking_id?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_office_id_fkey"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_status_id_fkey"
            columns: ["status_id"]
            isOneToOne: false
            referencedRelation: "order_statuses"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          created_at: string
          id: string
          name: string
          quantity: number | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          name: string
          quantity?: number | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          name?: string
          quantity?: number | null
          updated_at?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          address: string | null
          coverage_areas: string | null
          created_at: string
          full_name: string
          id: string
          login_code: string | null
          notes: string | null
          office_id: string | null
          phone: string | null
          salary: number | null
          updated_at: string
        }
        Insert: {
          address?: string | null
          coverage_areas?: string | null
          created_at?: string
          full_name?: string
          id: string
          login_code?: string | null
          notes?: string | null
          office_id?: string | null
          phone?: string | null
          salary?: number | null
          updated_at?: string
        }
        Update: {
          address?: string | null
          coverage_areas?: string | null
          created_at?: string
          full_name?: string
          id?: string
          login_code?: string | null
          notes?: string | null
          office_id?: string | null
          phone?: string | null
          salary?: number | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_profiles_office"
            columns: ["office_id"]
            isOneToOne: false
            referencedRelation: "offices"
            referencedColumns: ["id"]
          },
        ]
      }
      user_permissions: {
        Row: {
          id: string
          permission: string
          section: string
          user_id: string
        }
        Insert: {
          id?: string
          permission?: string
          section: string
          user_id: string
        }
        Update: {
          id?: string
          permission?: string
          section?: string
          user_id?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          id: string
          role: string
          user_id: string
        }
        Insert: {
          id?: string
          role: string
          user_id: string
        }
        Update: {
          id?: string
          role?: string
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      cleanup_old_logs: { Args: never; Returns: undefined }
      log_activity: {
        Args: { _action: string; _details?: Json }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
