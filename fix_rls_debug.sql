-- ============================================================================
-- EMPOWERMENT FARM - RLS FIX FOR surveyresponses (anon INSERT)
-- Run this in Supabase SQL Editor if you get "new row violates row-level security policy"
-- ============================================================================

-- 1. Ensure anon can use schema and table
GRANT USAGE ON SCHEMA public TO anon;
GRANT INSERT ON surveyresponses TO anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;

-- 2. Allow anon to use uuid_generate_v4() for default response_id
GRANT EXECUTE ON FUNCTION uuid_generate_v4() TO anon;

-- 3. Replace INSERT policy with explicit anon (Supabase/PostgREST use role 'anon')
DROP POLICY IF EXISTS "Allow public survey submissions" ON surveyresponses;

CREATE POLICY "Allow public survey submissions" ON surveyresponses
    AS PERMISSIVE
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- 4. Verify (run separately if you want to check)
-- SELECT grantee, privilege_type FROM information_schema.role_table_grants WHERE table_name = 'surveyresponses';
-- SELECT tablename, policyname, roles, cmd FROM pg_policies WHERE tablename = 'surveyresponses';
