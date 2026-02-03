-- ============================================================================
-- EMPOWERMENT FARM - RLS DEBUG & FIX SCRIPT
-- Run this in Supabase SQL Editor
-- ============================================================================

-- STEP 1: Check current grants on the table
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'surveyresponses';

-- STEP 2: Check if RLS is actually enabled
SELECT relname, relrowsecurity, relforcerowsecurity 
FROM pg_class 
WHERE relname = 'surveyresponses';

-- STEP 3: Check current policies (you've done this but let's be thorough)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'surveyresponses';

-- ============================================================================
-- ATTEMPT 1: Force the anon role to have INSERT privileges
-- ============================================================================
GRANT USAGE ON SCHEMA public TO anon;
GRANT INSERT ON surveyresponses TO anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;

-- ============================================================================
-- ATTEMPT 2: Make the policy PERMISSIVE explicitly (default, but let's be sure)
-- ============================================================================
DROP POLICY IF EXISTS "Allow public survey submissions" ON surveyresponses;

CREATE POLICY "Allow public survey submissions" ON surveyresponses
    AS PERMISSIVE
    FOR INSERT 
    TO anon, authenticated
    WITH CHECK (true);

-- ============================================================================
-- ATTEMPT 3: Also grant USAGE on uuid-ossp extension functions
-- (Required for uuid_generate_v4() default value)
-- ============================================================================
GRANT EXECUTE ON FUNCTION uuid_generate_v4() TO anon;

-- ============================================================================
-- ATTEMPT 4: Grant INSERT on the table to PUBLIC (nuclear option)
-- ============================================================================
-- GRANT INSERT ON surveyresponses TO PUBLIC;

-- ============================================================================
-- VERIFICATION: Test insert as anon user
-- ============================================================================
-- Run this in a separate query to test:
/*
SET ROLE anon;

INSERT INTO surveyresponses (
    experience_type,
    is_present_engaged,
    connection_others_score,
    connection_nature_score,
    calmness_score,
    learning_intent_score,
    community_benefit_score,
    age_range_bracket,
    would_recommend
) VALUES (
    'Test Program',
    3,
    3,
    3,
    3,
    3,
    3,
    '18-25',
    true
);

RESET ROLE;
*/

-- ============================================================================
-- Final verification query
-- ============================================================================
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'surveyresponses'
ORDER BY grantee;
