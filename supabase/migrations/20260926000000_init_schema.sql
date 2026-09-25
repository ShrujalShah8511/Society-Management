-- ==============================================================================
-- Migration: 20260926000000_init_schema.sql
-- Description: Phase 1 Multi-Tenant PostgreSQL Schema for Society Management
-- Database: Supabase PostgreSQL (PostgREST + Auth + Storage + RLS)
-- Architect: 15-Year Solution Architect Specification
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. ENUMS & DOMAINS
-- ==============================================================================
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM (
        'SUPER_ADMIN',
        'SOCIETY_ADMIN',
        'COMMITTEE_MEMBER',
        'RESIDENT',
        'SECURITY',
        'STAFF'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE flat_status AS ENUM (
        'OCCUPIED',
        'VACANT',
        'UNDER_MAINTENANCE'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 3. TABLES
-- ==============================================================================

-- 3.1 Societies Table
CREATE TABLE IF NOT EXISTS public.societies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    rera_number VARCHAR(100),
    logo_url TEXT,
    total_units INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.2 User Profiles (Linked with auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role user_role NOT NULL DEFAULT 'RESIDENT',
    society_id UUID REFERENCES public.societies(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3.3 Towers Table
CREATE TABLE IF NOT EXISTS public.towers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    total_floors INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uk_tower_society_name UNIQUE (society_id, name)
);

-- 3.4 Floors Table
CREATE TABLE IF NOT EXISTS public.floors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tower_id UUID NOT NULL REFERENCES public.towers(id) ON DELETE CASCADE,
    society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
    floor_number INTEGER NOT NULL,
    floor_name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uk_floor_tower_number UNIQUE (tower_id, floor_number)
);

-- 3.5 Flats Table
CREATE TABLE IF NOT EXISTS public.flats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
    tower_id UUID NOT NULL REFERENCES public.towers(id) ON DELETE CASCADE,
    floor_id UUID NOT NULL REFERENCES public.floors(id) ON DELETE CASCADE,
    flat_number VARCHAR(50) NOT NULL,
    bhk_type VARCHAR(20) NOT NULL, -- '1BHK', '2BHK', '3BHK', '4BHK', 'PENTHOUSE', 'STUDIO'
    status flat_status NOT NULL DEFAULT 'VACANT',
    area_sqft DOUBLE PRECISION NOT NULL DEFAULT 0,
    resident_name VARCHAR(255),
    resident_phone VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uk_flat_floor_number UNIQUE (floor_id, flat_number)
);

-- 3.6 Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    society_id UUID REFERENCES public.societies(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==============================================================================
-- 4. PERFORMANCE INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_societies_active ON public.societies(is_active);
CREATE INDEX IF NOT EXISTS idx_users_society_id ON public.users(society_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_towers_society_id ON public.towers(society_id);
CREATE INDEX IF NOT EXISTS idx_floors_tower_id ON public.floors(tower_id);
CREATE INDEX IF NOT EXISTS idx_floors_society_id ON public.floors(society_id);
CREATE INDEX IF NOT EXISTS idx_flats_society_id ON public.flats(society_id);
CREATE INDEX IF NOT EXISTS idx_flats_tower_id ON public.flats(tower_id);
CREATE INDEX IF NOT EXISTS idx_flats_floor_id ON public.flats(floor_id);
CREATE INDEX IF NOT EXISTS idx_flats_status ON public.flats(society_id, status);
CREATE INDEX IF NOT EXISTS idx_audit_logs_society_created ON public.audit_logs(society_id, created_at DESC);

-- ==============================================================================
-- 5. AUTOMATIC TIMESTAMP TRIGGERS
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_societies_updated_at ON public.societies;
CREATE TRIGGER trg_societies_updated_at BEFORE UPDATE ON public.societies FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_towers_updated_at ON public.towers;
CREATE TRIGGER trg_towers_updated_at BEFORE UPDATE ON public.towers FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_floors_updated_at ON public.floors;
CREATE TRIGGER trg_floors_updated_at BEFORE UPDATE ON public.floors FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_flats_updated_at ON public.flats;
CREATE TRIGGER trg_flats_updated_at BEFORE UPDATE ON public.flats FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 6. AUTH.USERS SIGNUP SYNC TRIGGER
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role user_role := 'RESIDENT';
    user_full_name TEXT := COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1));
    user_society_id UUID := NULL;
BEGIN
    IF (NEW.raw_user_meta_data->>'role') IS NOT NULL THEN
        default_role := (NEW.raw_user_meta_data->>'role')::user_role;
    END IF;

    IF (NEW.raw_user_meta_data->>'society_id') IS NOT NULL THEN
        user_society_id := (NEW.raw_user_meta_data->>'society_id')::UUID;
    END IF;

    INSERT INTO public.users (id, email, full_name, role, society_id)
    VALUES (NEW.id, NEW.email, user_full_name, default_role, user_society_id)
    ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        full_name = EXCLUDED.full_name;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- ==============================================================================
-- 7. ROW-LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.societies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.towers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.floors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper Function: Check if current user is SUPER_ADMIN
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid() AND role = 'SUPER_ADMIN' AND is_active = true
    );
$$ LANGUAGE sql SECURITY DEFINER;

-- Helper Function: Get current user's society_id
CREATE OR REPLACE FUNCTION public.get_auth_society_id()
RETURNS UUID AS $$
    SELECT society_id FROM public.users
    WHERE id = auth.uid() AND is_active = true;
$$ LANGUAGE sql SECURITY DEFINER;

-- 7.1 Societies RLS
CREATE POLICY "Societies viewable by members or super admin"
    ON public.societies FOR SELECT
    USING (public.is_super_admin() OR id = public.get_auth_society_id());

CREATE POLICY "Societies editable by super admin or society admin"
    ON public.societies FOR UPDATE
    USING (
        public.is_super_admin() OR 
        (id = public.get_auth_society_id() AND EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'SOCIETY_ADMIN'
        ))
    );

-- 7.2 Users RLS
CREATE POLICY "Users can read members in same society"
    ON public.users FOR SELECT
    USING (public.is_super_admin() OR society_id = public.get_auth_society_id() OR id = auth.uid());

CREATE POLICY "Users can update their own profile"
    ON public.users FOR UPDATE
    USING (id = auth.uid() OR public.is_super_admin());

-- 7.3 Towers RLS
CREATE POLICY "Towers viewable by society members"
    ON public.towers FOR SELECT
    USING (public.is_super_admin() OR society_id = public.get_auth_society_id());

CREATE POLICY "Towers manageable by society admin"
    ON public.towers FOR ALL
    USING (
        public.is_super_admin() OR 
        (society_id = public.get_auth_society_id() AND EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('SOCIETY_ADMIN', 'SUPER_ADMIN')
        ))
    );

-- 7.4 Floors RLS
CREATE POLICY "Floors viewable by society members"
    ON public.floors FOR SELECT
    USING (public.is_super_admin() OR society_id = public.get_auth_society_id());

CREATE POLICY "Floors manageable by society admin"
    ON public.floors FOR ALL
    USING (
        public.is_super_admin() OR 
        (society_id = public.get_auth_society_id() AND EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('SOCIETY_ADMIN', 'SUPER_ADMIN')
        ))
    );

-- 7.5 Flats RLS
CREATE POLICY "Flats viewable by society members"
    ON public.flats FOR SELECT
    USING (public.is_super_admin() OR society_id = public.get_auth_society_id());

CREATE POLICY "Flats manageable by society admin"
    ON public.flats FOR ALL
    USING (
        public.is_super_admin() OR 
        (society_id = public.get_auth_society_id() AND EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('SOCIETY_ADMIN', 'SUPER_ADMIN')
        ))
    );

-- 7.6 Audit Logs RLS
CREATE POLICY "Audit logs viewable by admins"
    ON public.audit_logs FOR SELECT
    USING (
        public.is_super_admin() OR 
        (society_id = public.get_auth_society_id() AND EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('SOCIETY_ADMIN', 'SUPER_ADMIN')
        ))
    );

CREATE POLICY "Audit logs insertable by authenticated users"
    ON public.audit_logs FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);
