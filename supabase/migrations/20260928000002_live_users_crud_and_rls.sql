-- ==============================================================================
-- Migration: 20260928000002_live_users_crud_and_rls.sql
-- Description: Enable Live User Management CRUD & Permissive Development RLS
-- ==============================================================================

-- 1. Ensure required columns exist on public.users
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS flat_number VARCHAR(50);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT false;

-- 2. Drop auth.users foreign key constraint so users can be managed directly in dev
ALTER TABLE public.users ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_id_fkey;

-- 3. Fix handle_new_auth_user trigger with explicit schema search_path
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role public.user_role := 'RESIDENT';
    user_full_name TEXT := COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1));
    user_society_id UUID := NULL;
BEGIN
    IF (NEW.raw_user_meta_data->>'role') IS NOT NULL THEN
        BEGIN
            default_role := (NEW.raw_user_meta_data->>'role')::public.user_role;
        EXCEPTION WHEN OTHERS THEN
            default_role := 'RESIDENT'::public.user_role;
        END;
    END IF;

    IF (NEW.raw_user_meta_data->>'society_id') IS NOT NULL AND (NEW.raw_user_meta_data->>'society_id') != '' THEN
        BEGIN
            user_society_id := (NEW.raw_user_meta_data->>'society_id')::UUID;
        EXCEPTION WHEN OTHERS THEN
            user_society_id := NULL;
        END;
    END IF;

    INSERT INTO public.users (id, email, full_name, role, society_id, avatar_url, flat_number, must_change_password)
    VALUES (
        NEW.id,
        NEW.email,
        user_full_name,
        default_role,
        user_society_id,
        NEW.raw_user_meta_data->>'avatar_url',
        NEW.raw_user_meta_data->>'flat_number',
        COALESCE((NEW.raw_user_meta_data->>'must_change_password')::BOOLEAN, false)
    )
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role,
        society_id = EXCLUDED.society_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Re-attach trigger
DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- 4. Permissive Development RLS Policies on public.users
DROP POLICY IF EXISTS "Users can read members in same society" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users manageable by admin or app" ON public.users;
DROP POLICY IF EXISTS "Users manageable in development" ON public.users;

CREATE POLICY "Users manageable in development"
    ON public.users FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- 5. Seed Initial Admin & Society Users
INSERT INTO public.users (id, email, full_name, phone, role, society_id, is_active, must_change_password)
VALUES
    (
        '00000000-0000-0000-0000-000000000001',
        'superadmin@societymanagement.com',
        'Shrujal Shah',
        '+91 99988 87776',
        'SUPER_ADMIN',
        NULL,
        true,
        false
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        'admin@shyamheights.in',
        'Rajesh Patel',
        '+91 98765 43210',
        'SOCIETY_ADMIN',
        '7d50533b-ad29-461a-8d10-477987357e44',
        true,
        false
    )
ON CONFLICT (email) DO UPDATE
SET full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    role = EXCLUDED.role,
    society_id = EXCLUDED.society_id,
    is_active = EXCLUDED.is_active;
