-- ==============================================================================
-- Seed Data: Phase 1 Initial Demo Data
-- Society: Shyam Heights
-- ==============================================================================

DO $$
DECLARE
    v_society_id UUID;
    v_tower_a_id UUID;
    v_tower_b_id UUID;
    v_floor_1_id UUID;
    v_floor_2_id UUID;
BEGIN
    -- 1. Insert Society (Shyam Heights)
    INSERT INTO public.societies (name, address, rera_number, logo_url, total_units, is_active)
    VALUES (
        'Shyam Heights',
        '100 Feet Ring Road, Satellite, Ahmedabad, Gujarat 380015',
        'PR/GJ/AHMEDABAD/AHMEDABAD-CITY/AUDA/RAA00001/010120',
        NULL,
        120,
        true
    )
    RETURNING id INTO v_society_id;

    -- 2. Insert Towers
    INSERT INTO public.towers (society_id, name, total_floors, is_active)
    VALUES (v_society_id, 'Tower A', 14, true)
    RETURNING id INTO v_tower_a_id;

    INSERT INTO public.towers (society_id, name, total_floors, is_active)
    VALUES (v_society_id, 'Tower B', 14, true)
    RETURNING id INTO v_tower_b_id;

    -- 3. Insert Floors for Tower A
    INSERT INTO public.floors (tower_id, society_id, floor_number, floor_name, is_active)
    VALUES (v_tower_a_id, v_society_id, 1, '1st Floor', true)
    RETURNING id INTO v_floor_1_id;

    INSERT INTO public.floors (tower_id, society_id, floor_number, floor_name, is_active)
    VALUES (v_tower_a_id, v_society_id, 2, '2nd Floor', true)
    RETURNING id INTO v_floor_2_id;

    -- 4. Insert Flats for Floor 1
    INSERT INTO public.flats (society_id, tower_id, floor_id, flat_number, bhk_type, status, area_sqft, resident_name, resident_phone)
    VALUES
        (v_society_id, v_tower_a_id, v_floor_1_id, '101', '3BHK', 'OCCUPIED', 1650.0, 'Rajesh Patel', '+91 98765 43210'),
        (v_society_id, v_tower_a_id, v_floor_1_id, '102', '2BHK', 'VACANT', 1250.0, NULL, NULL),
        (v_society_id, v_tower_a_id, v_floor_1_id, '103', '3BHK', 'UNDER_MAINTENANCE', 1700.0, NULL, NULL),
        (v_society_id, v_tower_a_id, v_floor_1_id, '104', '4BHK', 'OCCUPIED', 2200.0, 'Sneha Shah', '+91 98222 11000');

    -- 5. Insert Flats for Floor 2
    INSERT INTO public.flats (society_id, tower_id, floor_id, flat_number, bhk_type, status, area_sqft, resident_name, resident_phone)
    VALUES
        (v_society_id, v_tower_a_id, v_floor_2_id, '201', '3BHK', 'OCCUPIED', 1650.0, 'Amit Sharma', '+91 98111 22334'),
        (v_society_id, v_tower_a_id, v_floor_2_id, '202', '2BHK', 'VACANT', 1250.0, NULL, NULL);

END $$;
