
-- Companies table
CREATE TABLE public.companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  agreement_price NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read companies" ON public.companies FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage companies" ON public.companies FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Company payments
CREATE TABLE public.company_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  amount NUMERIC DEFAULT 0,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.company_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read company_payments" ON public.company_payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage company_payments" ON public.company_payments FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Courier collections
CREATE TABLE public.courier_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  courier_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  amount NUMERIC DEFAULT 0,
  collected_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.courier_collections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated can read courier_collections" ON public.courier_collections FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated can manage courier_collections" ON public.courier_collections FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Add company_id to orders
ALTER TABLE public.orders ADD COLUMN company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL;

-- Auto-generate diary_number
CREATE OR REPLACE FUNCTION public.set_diary_number()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF NEW.diary_number IS NULL OR NEW.diary_number = 0 THEN
    SELECT COALESCE(MAX(diary_number), 0) + 1 INTO NEW.diary_number
    FROM public.diaries WHERE office_id = NEW.office_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER auto_diary_number
  BEFORE INSERT ON public.diaries
  FOR EACH ROW EXECUTE FUNCTION public.set_diary_number();

-- Make diary_number have a default so inserts without it work
ALTER TABLE public.diaries ALTER COLUMN diary_number SET DEFAULT 0;
