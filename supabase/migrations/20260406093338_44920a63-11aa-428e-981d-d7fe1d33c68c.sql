
-- 1. Profiles table (auto-created on auth signup)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  phone TEXT DEFAULT '',
  login_code TEXT DEFAULT '',
  office_id UUID,
  salary NUMERIC DEFAULT 0,
  coverage_areas TEXT DEFAULT '',
  address TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read profiles" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);
CREATE POLICY "Service role can insert profiles" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. User roles
CREATE TABLE public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner','admin','courier','office')),
  UNIQUE(user_id, role)
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read roles" ON public.user_roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage roles" ON public.user_roles FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 3. User permissions
CREATE TABLE public.user_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  section TEXT NOT NULL,
  permission TEXT NOT NULL DEFAULT 'edit' CHECK (permission IN ('view','edit','hidden')),
  UNIQUE(user_id, section)
);
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read permissions" ON public.user_permissions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage permissions" ON public.user_permissions FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 4. Offices
CREATE TABLE public.offices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  specialty TEXT DEFAULT '',
  owner_name TEXT DEFAULT '',
  owner_phone TEXT DEFAULT '',
  address TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  can_add_orders BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.offices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read offices" ON public.offices FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage offices" ON public.offices FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Add FK from profiles to offices
ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_office FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE SET NULL;

-- 5. Order statuses
CREATE TABLE public.order_statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  color TEXT DEFAULT '#666',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.order_statuses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read statuses" ON public.order_statuses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage statuses" ON public.order_statuses FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 6. Products
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  quantity INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read products" ON public.products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage products" ON public.products FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 7. Orders
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  barcode TEXT UNIQUE,
  tracking_id TEXT,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_code TEXT DEFAULT '',
  product_name TEXT DEFAULT 'بدون منتج',
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  quantity INTEGER DEFAULT 1,
  price NUMERIC DEFAULT 0,
  delivery_price NUMERIC DEFAULT 0,
  shipping_paid NUMERIC DEFAULT 0,
  partial_amount NUMERIC DEFAULT 0,
  color TEXT DEFAULT '',
  size TEXT DEFAULT '',
  address TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  priority TEXT DEFAULT 'normal',
  office_id UUID REFERENCES public.offices(id) ON DELETE SET NULL,
  courier_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status_id UUID REFERENCES public.order_statuses(id) ON DELETE SET NULL,
  is_closed BOOLEAN DEFAULT false,
  is_courier_closed BOOLEAN DEFAULT false,
  is_settled BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read orders" ON public.orders FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage orders" ON public.orders FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Barcode generation
CREATE OR REPLACE FUNCTION public.generate_barcode()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  new_barcode TEXT;
  counter INTEGER;
BEGIN
  IF NEW.barcode IS NULL OR NEW.barcode = '' THEN
    SELECT COUNT(*) + 1 INTO counter FROM public.orders;
    new_barcode := 'SH' || LPAD(counter::TEXT, 6, '0');
    WHILE EXISTS (SELECT 1 FROM public.orders WHERE barcode = new_barcode) LOOP
      counter := counter + 1;
      new_barcode := 'SH' || LPAD(counter::TEXT, 6, '0');
    END LOOP;
    NEW.barcode := new_barcode;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_barcode
  BEFORE INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.generate_barcode();

-- 8. Delivery prices
CREATE TABLE public.delivery_prices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  office_id UUID NOT NULL REFERENCES public.offices(id) ON DELETE CASCADE,
  governorate TEXT NOT NULL,
  price NUMERIC DEFAULT 0,
  pickup_price NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.delivery_prices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read delivery_prices" ON public.delivery_prices FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage delivery_prices" ON public.delivery_prices FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 9. Order notes
CREATE TABLE public.order_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  note TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.order_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read order_notes" ON public.order_notes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage order_notes" ON public.order_notes FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 10. Courier bonuses
CREATE TABLE public.courier_bonuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  courier_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC DEFAULT 0,
  reason TEXT DEFAULT '',
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.courier_bonuses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read courier_bonuses" ON public.courier_bonuses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage courier_bonuses" ON public.courier_bonuses FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 11. Courier locations
CREATE TABLE public.courier_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  courier_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.courier_locations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read courier_locations" ON public.courier_locations FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage courier_locations" ON public.courier_locations FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 12. Office payments
CREATE TABLE public.office_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  office_id UUID NOT NULL REFERENCES public.offices(id) ON DELETE CASCADE,
  amount NUMERIC DEFAULT 0,
  type TEXT DEFAULT 'advance' CHECK (type IN ('advance','commission','shipping_discount','partial_delivery','payment')),
  notes TEXT DEFAULT '',
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.office_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read office_payments" ON public.office_payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage office_payments" ON public.office_payments FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 13. Advances
CREATE TABLE public.advances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC DEFAULT 0,
  reason TEXT DEFAULT '',
  type TEXT DEFAULT 'advance' CHECK (type IN ('advance','deduction','bonus')),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.advances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read advances" ON public.advances FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage advances" ON public.advances FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 14. Messages
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own messages" ON public.messages FOR SELECT TO authenticated USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send messages" ON public.messages FOR INSERT TO authenticated WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Users can update own received messages" ON public.messages FOR UPDATE TO authenticated USING (auth.uid() = receiver_id);

-- Enable realtime for messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- 15. Activity logs
CREATE TABLE public.activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  details JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read activity_logs" ON public.activity_logs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can insert activity_logs" ON public.activity_logs FOR INSERT TO authenticated WITH CHECK (true);

-- log_activity RPC function
CREATE OR REPLACE FUNCTION public.log_activity(_action TEXT, _details JSONB DEFAULT '{}')
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.activity_logs (user_id, action, details)
  VALUES (auth.uid(), _action, _details);
END;
$$;

-- Auto-delete logs older than 7 days (can be called periodically)
CREATE OR REPLACE FUNCTION public.cleanup_old_logs()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.activity_logs WHERE created_at < now() - INTERVAL '7 days';
END;
$$;

-- 16. App settings
CREATE TABLE public.app_settings (
  key TEXT PRIMARY KEY,
  value TEXT DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read app_settings" ON public.app_settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage app_settings" ON public.app_settings FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 17. Diaries
CREATE TABLE public.diaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  office_id UUID NOT NULL REFERENCES public.offices(id) ON DELETE CASCADE,
  diary_number INTEGER NOT NULL,
  diary_date DATE NOT NULL DEFAULT CURRENT_DATE,
  is_closed BOOLEAN DEFAULT false,
  is_archived BOOLEAN DEFAULT false,
  closed_at TIMESTAMPTZ,
  lock_status_updates BOOLEAN DEFAULT false,
  prevent_new_orders BOOLEAN DEFAULT false,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.diaries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read diaries" ON public.diaries FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage diaries" ON public.diaries FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 18. Diary orders (with financial + orange sheet fields)
CREATE TABLE public.diary_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  diary_id UUID NOT NULL REFERENCES public.diaries(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  -- Financial sheet fields
  balance NUMERIC DEFAULT 0,
  arrived NUMERIC DEFAULT 0,
  returns NUMERIC DEFAULT 0,
  postponed NUMERIC DEFAULT 0,
  pickup NUMERIC DEFAULT 0,
  fees NUMERIC DEFAULT 0,
  executed NUMERIC DEFAULT 0,
  due_with_postponed BOOLEAN DEFAULT false,
  return_status TEXT DEFAULT '',
  n_column TEXT DEFAULT '',
  manual_arrived_total NUMERIC,
  -- Orange sheet fields
  total_price NUMERIC DEFAULT 0,
  extra_due NUMERIC DEFAULT 0,
  orange_arrived NUMERIC DEFAULT 0,
  orange_shipping NUMERIC DEFAULT 0,
  orange_pickup NUMERIC DEFAULT 0,
  orange_notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.diary_orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read diary_orders" ON public.diary_orders FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage diary_orders" ON public.diary_orders FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 19. Expenses
CREATE TABLE public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_name TEXT NOT NULL,
  amount NUMERIC DEFAULT 0,
  category TEXT DEFAULT 'أخرى',
  notes TEXT DEFAULT '',
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  office_id UUID REFERENCES public.offices(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read expenses" ON public.expenses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage expenses" ON public.expenses FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 20. Cash flow entries
CREATE TABLE public.cash_flow_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT DEFAULT 'inside' CHECK (type IN ('inside','outside')),
  amount NUMERIC DEFAULT 0,
  reason TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  office_id UUID REFERENCES public.offices(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.cash_flow_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read cash_flow_entries" ON public.cash_flow_entries FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage cash_flow_entries" ON public.cash_flow_entries FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 21. Office daily closings
CREATE TABLE public.office_daily_closings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  office_id UUID NOT NULL REFERENCES public.offices(id) ON DELETE CASCADE,
  closing_date DATE NOT NULL DEFAULT CURRENT_DATE,
  data_json JSONB DEFAULT '[]',
  pickup_rate NUMERIC DEFAULT 0,
  is_locked BOOLEAN DEFAULT false,
  is_closed BOOLEAN DEFAULT false,
  prevent_add BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(office_id, closing_date)
);
ALTER TABLE public.office_daily_closings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read closings" ON public.office_daily_closings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage closings" ON public.office_daily_closings FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Apply updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_offices_updated_at BEFORE UPDATE ON public.offices FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_diaries_updated_at BEFORE UPDATE ON public.diaries FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_diary_orders_updated_at BEFORE UPDATE ON public.diary_orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_closings_updated_at BEFORE UPDATE ON public.office_daily_closings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Indexes for performance
CREATE INDEX idx_orders_office_id ON public.orders(office_id);
CREATE INDEX idx_orders_courier_id ON public.orders(courier_id);
CREATE INDEX idx_orders_status_id ON public.orders(status_id);
CREATE INDEX idx_orders_barcode ON public.orders(barcode);
CREATE INDEX idx_orders_is_closed ON public.orders(is_closed);
CREATE INDEX idx_orders_is_courier_closed ON public.orders(is_courier_closed);
CREATE INDEX idx_diary_orders_diary_id ON public.diary_orders(diary_id);
CREATE INDEX idx_diary_orders_order_id ON public.diary_orders(order_id);
CREATE INDEX idx_diaries_office_id ON public.diaries(office_id);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX idx_activity_logs_created ON public.activity_logs(created_at);
