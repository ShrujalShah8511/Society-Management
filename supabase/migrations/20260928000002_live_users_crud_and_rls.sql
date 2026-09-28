-- ==============================================================================
-- Migration: 20260928000002_live_users_crud_and_rls.sql
-- Description: Provision Live Quick-Login Users & Enable Development CRUD in Supabase
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard)
-- Note: Operates strictly on the 'public' schema owned by postgres
-- ==============================================================================

-- 1. Ensure required extensions exist
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Ensure columns exist on public.users
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS flat_number VARCHAR(50);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS must_change_password BOOLEAN NOT NULL DEFAULT false;

-- 3. Set default ID generation and relax foreign key constraint for flexible user management
ALTER TABLE public.users ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_id_fkey;

-- 4. Fix handle_new_auth_user trigger function in-place (without touching auth schema triggers)
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

    INSERT INTO public.users (id, email, full_name, phone, role, society_id, avatar_url, flat_number, must_change_password)
    VALUES (
        NEW.id,
        NEW.email,
        user_full_name,
        COALESCE(NEW.raw_user_meta_data->>'phone', NEW.phone, ''),
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

-- 5. Development RLS Policies: Allow anon & authenticated users to perform CRUD on public.users
DROP POLICY IF EXISTS "Users can read members in same society" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users manageable by admin or app" ON public.users;
DROP POLICY IF EXISTS "Users manageable in development" ON public.users;

CREATE POLICY "Users manageable in development"
    ON public.users FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- ==============================================================================
-- 6. SEED QUICK-LOGIN USERS DIRECTLY IN PUBLIC.USERS
-- ==============================================================================

DO $$
DECLARE
    v_society_id UUID := '7d50533b-ad29-461a-8d10-477987357e44'; -- Shyam Heights
BEGIN
    -- Ensure Shyam Heights society exists
    IF NOT EXISTS (SELECT 1 FROM public.societies WHERE id = v_society_id) THEN
        INSERT INTO public.societies (id, name, address, total_units, is_active)
        VALUES (v_society_id, 'Shyam Heights', 'Near Sargasan Cross Road, Gandhinagar, Gujarat', 120, true)
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- 1. Super Admin (Shrujal Shah - 9998887776)
    INSERT INTO public.users (id, email, full_name, phone, role, society_id, flat_number, is_active, must_change_password)
    VALUES (
        '11111111-1111-1111-1111-111111111111',
        'superadmin@societymanagement.com',
        'Shrujal Shah',
        '9998887776',
        'SUPER_ADMIN',
        NULL,
        NULL,
        true,
        false
    )
    ON CONFLICT (email) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone,
        role = EXCLUDED.role,
        society_id = EXCLUDED.society_id,
        is_active = EXCLUDED.is_active;

    -- 2. Society Admin (Rajesh Patel - 9876543210)
    INSERT INTO public.users (id, email, full_name, phone, role, society_id, flat_number, is_active, must_change_password)
    VALUES (
        '22222222-2222-2222-2222-222222222222',
        'admin@shyamheights.in',
        'Rajesh Patel',
        '9876543210',
        'SOCIETY_ADMIN',
        v_society_id,
        NULL,
        true,
        false
    )
    ON CONFLICT (email) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone,
        role = EXCLUDED.role,
        society_id = EXCLUDED.society_id,
        is_active = EXCLUDED.is_active;

    -- 3. Resident (Amit Sharma - 9123456780)
    INSERT INTO public.users (id, email, full_name, phone, role, society_id, flat_number, is_active, must_change_password)
    VALUES (
        '33333333-3333-3333-3333-333333333333',
        'resident@shyamheights.in',
        'Amit Sharma',
        '9123456780',
        'RESIDENT',
        v_society_id,
        'A-101',
        true,
        false
    )
    ON CONFLICT (email) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone,
        role = EXCLUDED.role,
        society_id = EXCLUDED.society_id,
        flat_number = EXCLUDED.flat_number,
        is_active = EXCLUDED.is_active;

    -- 4. Security (Bahadur Thapa - 9123456782)
    INSERT INTO public.users (id, email, full_name, phone, role, society_id, flat_number, is_active, must_change_password)
    VALUES (
        '44444444-4444-4444-4444-444444444444',
        'security@shyamheights.in',
        'Bahadur Thapa',
        '9123456782',
        'SECURITY',
        v_society_id,
        NULL,
        true,
        false
    )
    ON CONFLICT (email) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone,
        role = EXCLUDED.role,
        society_id = EXCLUDED.society_id,
        is_active = EXCLUDED.is_active;

END $$;
