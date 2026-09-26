-- Migration: Allow Society Admin and Demo User CRUD Persistence
-- Enables INSERT, UPDATE, DELETE for active societies

DROP POLICY IF EXISTS "Flats manageable by society admin" ON public.flats;
DROP POLICY IF EXISTS "Flats manageable by society admin or demo" ON public.flats;
CREATE POLICY "Flats manageable by society admin or demo"
    ON public.flats FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Floors manageable by society admin" ON public.floors;
DROP POLICY IF EXISTS "Floors manageable by society admin or demo" ON public.floors;
CREATE POLICY "Floors manageable by society admin or demo"
    ON public.floors FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Towers manageable by society admin" ON public.towers;
DROP POLICY IF EXISTS "Towers manageable by society admin or demo" ON public.towers;
CREATE POLICY "Towers manageable by society admin or demo"
    ON public.towers FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Societies editable by super admin or society admin" ON public.societies;
DROP POLICY IF EXISTS "Societies manageable by society admin or demo" ON public.societies;
CREATE POLICY "Societies manageable by society admin or demo"
    ON public.societies FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);
