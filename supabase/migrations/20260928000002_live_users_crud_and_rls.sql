-- ==============================================================================
-- Migration: 20260928000002_live_users_crud_and_rls.sql
-- Description: Provision Live Quick-Login Users & Enable Development CRUD in Supabase
-- Run this in your Supabase SQL Editor (https://supabase.com/dashboard)
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

-- 4. Fix handle_new_auth_user trigger function
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

-- Re-attach trigger
DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

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
-- 6. PROVISION QUICK-LOGIN USERS IN AUTH.USERS & PUBLIC.USERS
-- Passwords matching quick login pills:
--   - Super Admin:     9998887776 -> password: super123
--   - Society Admin:   9876543210 -> password: admin123
--   - Resident:        9123456780 -> password: resident123
--   - Security:        9123456782 -> password: security123
-- ==============================================================================

DO $$
DECLARE
    v_society_id UUID := '7d50533b-ad29-461a-8d10-477987357e44'; -- Shyam Heights
    v_uid_super UUID := '11111111-1111-1111-1111-111111111111';
    v_uid_admin UUID := '22222222-2222-2222-2222-222222222222';
    v_uid_resident UUID := '33333333-3333-3333-3333-333333333333';
    v_uid_security UUID := '44444444-4444-4444-4444-444444444444';
BEGIN
    -- Verify society exists
    IF NOT EXISTS (SELECT 1 FROM public.societies WHERE id = v_society_id) THEN
        INSERT INTO public.societies (id, name, address, total_units, is_active)
        VALUES (v_society_id, 'Shyam Heights', 'Near Sargasan Cross Road, Gandhinagar, Gujarat', 120, true)
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- Disable trigger temporarily during seed to prevent conflict
    ALTER TABLE auth.users DISABLE TRIGGER trg_on_auth_user_created;

    -- --- 1. SUPER ADMIN (Shrujal Shah) ---
    DELETE FROM auth.users WHERE email = 'superadmin@societymanagement.com' OR id = v_uid_super;
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
        v_uid_super,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        'superadmin@societymanagement.com',
        crypt('super123', gen_salt('bf')),
        now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"full_name":"Shrujal Shah","role":"SUPER_ADMIN","phone":"+91 99988 87776"}'::jsonb,
        now(),
        now()
    );

    DELETE FROM auth.identities WHERE id = v_uid_super::text;
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
    ) VALUES (
        v_uid_super::text,
        v_uid_super,
        jsonb_build_object('sub', v_uid_super::text, 'email', 'superadmin@societymanagement.com'),
        'email',
        'superadmin@societymanagement.com',
        now(),
        now(),
        now()
    );

    -- --- 2. SOCIETY ADMIN (Rajesh Patel) ---
    DELETE FROM auth.users WHERE email = 'admin@shyamheights.in' OR id = v_uid_admin;
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
        v_uid_admin,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        'admin@shyamheights.in',
        crypt('admin123', gen_salt('bf')),
        now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('full_name', 'Rajesh Patel', 'role', 'SOCIETY_ADMIN', 'phone', '+91 98765 43210', 'society_id', v_society_id),
        now(),
        now()
    );

    DELETE FROM auth.identities WHERE id = v_uid_admin::text;
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
    ) VALUES (
        v_uid_admin::text,
        v_uid_admin,
        jsonb_build_object('sub', v_uid_admin::text, 'email', 'admin@shyamheights.in'),
        'email',
        'admin@shyamheights.in',
        now(),
        now(),
        now()
    );

    -- --- 3. RESIDENT (Amit Sharma) ---
    DELETE FROM auth.users WHERE email = 'resident@shyamheights.in' OR id = v_uid_resident;
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
        v_uid_resident,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        'resident@shyamheights.in',
        crypt('resident123', gen_salt('bf')),
        now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('full_name', 'Amit Sharma', 'role', 'RESIDENT', 'phone', '+91 91234 56780', 'society_id', v_society_id, 'flat_number', 'A-101'),
        now(),
        now()
    );

    DELETE FROM auth.identities WHERE id = v_uid_resident::text;
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
    ) VALUES (
        v_uid_resident::text,
        v_uid_resident,
        jsonb_build_object('sub', v_uid_resident::text, 'email', 'resident@shyamheights.in'),
        'email',
        'resident@shyamheights.in',
        now(),
        now(),
        now()
    );

    -- --- 4. SECURITY (Bahadur Thapa) ---
    DELETE FROM auth.users WHERE email = 'security@shyamheights.in' OR id = v_uid_security;
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
    ) VALUES (
        v_uid_security,
        '00000000-0000-0000-0000-000000000000',
        'authenticated',
        'authenticated',
        'security@shyamheights.in',
        crypt('security123', gen_salt('bf')),
        now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('full_name', 'Bahadur Thapa', 'role', 'SECURITY', 'phone', '+91 91234 56782', 'society_id', v_society_id),
        now(),
        now()
    );

    DELETE FROM auth.identities WHERE id = v_uid_security::text;
    INSERT INTO auth.identities (
        id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
    ) VALUES (
        v_uid_security::text,
        v_uid_security,
        jsonb_build_object('sub', v_uid_security::text, 'email', 'security@shyamheights.in'),
        'email',
        'security@shyamheights.in',
        now(),
        now(),
        now()
    );

    -- Re-enable auth trigger
    ALTER TABLE auth.users ENABLE TRIGGER trg_on_auth_user_created;

    -- --- 5. INSERT DIRECTLY INTO PUBLIC.USERS ---
    INSERT INTO public.users (id, email, full_name, phone, role, society_id, flat_number, is_active, must_change_password)
    VALUES
        (
            v_uid_super,
            'superadmin@societymanagement.com',
            'Shrujal Shah',
            '9998887776',
            'SUPER_ADMIN',
            NULL,
            NULL,
            true,
            false
        ),
        (
            v_uid_admin,
            'admin@shyamheights.in',
            'Rajesh Patel',
            '9876543210',
            'SOCIETY_ADMIN',
            v_society_id,
            NULL,
            true,
            false
        ),
        (
            v_uid_resident,
            'resident@shyamheights.in',
            'Amit Sharma',
            '9123456780',
            'RESIDENT',
            v_society_id,
            'A-101',
            true,
            false
        ),
        (
            v_uid_security,
            'security@shyamheights.in',
            'Bahadur Thapa',
            '9123456782',
            'SECURITY',
            v_society_id,
            NULL,
            true,
            false
        )
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone,
        role = EXCLUDED.role,
        society_id = EXCLUDED.society_id,
        flat_number = EXCLUDED.flat_number,
        is_active = EXCLUDED.is_active,
        must_change_password = EXCLUDED.must_change_password;

END $$;
