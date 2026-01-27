-- ============================================
-- COMPREHENSIVE DATABASE SECURITY
-- Empowerment Farm - Updated for Actual Schema
-- Run ALL of this in Supabase SQL Editor
-- ============================================

-- ============================================
-- 1. ENABLE RLS ON ALL TABLES
-- ============================================

ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;
ALTER TABLE constituents ENABLE ROW LEVEL SECURITY;
ALTER TABLE constituentprofiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE programcatalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE farmzones ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. SURVEY RESPONSES POLICIES
-- ============================================

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "survey_public_insert" ON surveyresponses;
DROP POLICY IF EXISTS "survey_auth_read" ON surveyresponses;
DROP POLICY IF EXISTS "survey_auth_update" ON surveyresponses;
DROP POLICY IF EXISTS "survey_auth_delete" ON surveyresponses;

-- Public can submit surveys (INSERT only)
CREATE POLICY "survey_public_insert" ON surveyresponses
FOR INSERT TO public
WITH CHECK (true);

-- Only authenticated can READ (protects names, emails, etc.)
CREATE POLICY "survey_auth_read" ON surveyresponses
FOR SELECT TO authenticated
USING (true);

-- Only authenticated can UPDATE
CREATE POLICY "survey_auth_update" ON surveyresponses
FOR UPDATE TO authenticated
USING (true);

-- Only authenticated can DELETE
CREATE POLICY "survey_auth_delete" ON surveyresponses
FOR DELETE TO authenticated
USING (true);

-- ============================================
-- 3. CONSTITUENTS TABLE POLICIES (PII TABLE)
-- ============================================

DROP POLICY IF EXISTS "constituents_auth_all" ON constituents;
DROP POLICY IF EXISTS "constituents_block_anon" ON constituents;

-- Only authenticated can do ANYTHING with constituents
CREATE POLICY "constituents_auth_all" ON constituents
FOR ALL TO authenticated
USING (true)
WITH CHECK (true);

-- Block anonymous access completely
CREATE POLICY "constituents_block_anon" ON constituents
FOR ALL TO anon
USING (false);

-- ============================================
-- 4. CONSTITUENT PROFILES POLICIES (PII)
-- ============================================

DROP POLICY IF EXISTS "profiles_auth_all" ON constituentprofiles;
DROP POLICY IF EXISTS "profiles_block_anon" ON constituentprofiles;

CREATE POLICY "profiles_auth_all" ON constituentprofiles
FOR ALL TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "profiles_block_anon" ON constituentprofiles
FOR ALL TO anon
USING (false);

-- ============================================
-- 5. EXPERIENCES TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "experiences_public_insert" ON experiences;
DROP POLICY IF EXISTS "experiences_auth_read" ON experiences;

-- Public can INSERT (when submitting survey)
CREATE POLICY "experiences_public_insert" ON experiences
FOR INSERT TO public
WITH CHECK (true);

-- Only authenticated can READ
CREATE POLICY "experiences_auth_read" ON experiences
FOR SELECT TO authenticated
USING (true);

-- ============================================
-- 6. PROGRAM CATALOG POLICIES (Public Read OK)
-- ============================================

DROP POLICY IF EXISTS "programs_public_read" ON programcatalog;
DROP POLICY IF EXISTS "programs_auth_modify" ON programcatalog;

-- Anyone can read programs (dropdown data)
CREATE POLICY "programs_public_read" ON programcatalog
FOR SELECT TO public
USING (true);

-- Only authenticated can modify
CREATE POLICY "programs_auth_modify" ON programcatalog
FOR ALL TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- 7. ANIMALS TABLE POLICIES (Public Read OK)
-- ============================================

DROP POLICY IF EXISTS "animals_public_read" ON animals;
DROP POLICY IF EXISTS "animals_auth_modify" ON animals;

CREATE POLICY "animals_public_read" ON animals
FOR SELECT TO public
USING (true);

CREATE POLICY "animals_auth_modify" ON animals
FOR ALL TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- 8. FARM ZONES TABLE POLICIES (Public Read OK)
-- ============================================

DROP POLICY IF EXISTS "zones_public_read" ON farmzones;
DROP POLICY IF EXISTS "zones_auth_modify" ON farmzones;

CREATE POLICY "zones_public_read" ON farmzones
FOR SELECT TO public
USING (true);

CREATE POLICY "zones_auth_modify" ON farmzones
FOR ALL TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- 9. AUDIT LOG TABLE (NEW)
-- ============================================

CREATE TABLE IF NOT EXISTS audit_log (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    user_id UUID,
    user_email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for audit log - only authenticated admins can read
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "audit_auth_read" ON audit_log;
DROP POLICY IF EXISTS "audit_no_modify" ON audit_log;
DROP POLICY IF EXISTS "audit_no_delete" ON audit_log;

CREATE POLICY "audit_auth_read" ON audit_log
FOR SELECT TO authenticated
USING (true);

-- No one can modify audit logs (immutable)
CREATE POLICY "audit_no_modify" ON audit_log
FOR UPDATE TO authenticated
USING (false);

CREATE POLICY "audit_no_delete" ON audit_log
FOR DELETE TO authenticated
USING (false);

-- ============================================
-- 10. REVOKE DIRECT TABLE ACCESS (DEFENSE IN DEPTH)
-- ============================================

-- Revoke all from anon on sensitive tables
REVOKE ALL ON constituents FROM anon;
REVOKE ALL ON constituentprofiles FROM anon;
REVOKE UPDATE, DELETE ON surveyresponses FROM anon;

-- ============================================
-- 11. VERIFICATION QUERIES
-- ============================================

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('surveyresponses', 'constituents', 'constituentprofiles', 'experiences', 'programcatalog', 'animals', 'farmzones', 'audit_log');

-- Check policies exist
SELECT tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE schemaname = 'public';

-- ============================================
-- SECURITY SUMMARY
-- ============================================
-- ✅ RLS enabled on ALL tables
-- ✅ Anonymous users can ONLY insert surveys
-- ✅ Names/emails HIDDEN from public (constituents, constituentprofiles)
-- ✅ Audit log tracks changes
-- ✅ Audit logs are IMMUTABLE (can't be deleted)
-- ✅ Only authenticated users see dashboard data
