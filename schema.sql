-- ============================================================================
-- EMPOWERMENT FARM DATABASE SCHEMA (PRODUCTION-READY)
-- ============================================================================
-- Version: 2.0 - Full security compliance
-- Last Updated: 2026-01-29
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PGCrypto for secure encryption (Future-proofing for column-level security)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- CLEANUP - DROP EVERYTHING FOR CLEAN SLATE
-- ============================================================================
DROP VIEW IF EXISTS vw_impact_dashboard CASCADE;
DROP VIEW IF EXISTS vw_survey_with_programs CASCADE;
DROP TABLE IF EXISTS surveyresponses CASCADE;
DROP TABLE IF EXISTS experiences CASCADE;
DROP TABLE IF EXISTS constituentprofiles CASCADE;
DROP TABLE IF EXISTS constituents CASCADE;
DROP TABLE IF EXISTS animals CASCADE;
DROP TABLE IF EXISTS farmzones CASCADE;
DROP TABLE IF EXISTS programcatalog CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;

-- ============================================================================
-- TABLE: programcatalog
-- ============================================================================
CREATE TABLE programcatalog (
    program_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name      VARCHAR(150) NOT NULL UNIQUE,
    program_category  VARCHAR(100) NOT NULL,
    description       TEXT,
    schedule_notes    VARCHAR(255),
    cost_notes        VARCHAR(100),
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for programcatalog (read-only for all)
ALTER TABLE programcatalog ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view programs" ON programcatalog FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Only authenticated can modify programs" ON programcatalog FOR ALL TO authenticated USING (true);
GRANT SELECT ON programcatalog TO anon, authenticated;
GRANT ALL ON programcatalog TO authenticated;

-- Insert programs
INSERT INTO programcatalog (program_name, program_category, description, schedule_notes, cost_notes) VALUES
('Open Farm (Second Saturdays)', 'Open Farm', 'Self-guided tours, animal meet and greets, farm market shopping', '2nd Saturday monthly, 9AM-1PM', '$10/Adult, $25/Family'),
('Cow Yoga', 'Yoga', 'Farmyard yoga featuring cows, relaxation and regeneration', '4th Thursday monthly, 4-6PM', '$30/Person'),
('Yoga with the Animals', 'Yoga', 'Monthly yoga on the farm with animals, includes social hour', '4th Thursday monthly, 4-5PM', '$30/Person'),
('Tuesday Night Tuck-In', 'Family Program', 'Afterschool wind-down: open play, tuck animals in for bed, story time', 'Every Tuesday 3:30-5:30PM', '$25/Family'),
('Seedlings for Spring', 'Workshop', 'Learn the process of starting seedlings for springtime', 'Saturday workshops', 'Varies'),
('JusTeenys Greenies', 'Partner Workshop', 'Microgreens growing workshop with local organic farm', 'Monthly', '$10/Person, $5/Child'),
('Educational Field Trips', 'Group Program', 'Hands-on learning for grades K-12, curriculum-aligned', 'By appointment', 'Contact for pricing')
ON CONFLICT (program_name) DO NOTHING;

-- ============================================================================
-- TABLE: farmzones
-- ============================================================================
CREATE TABLE farmzones (
    zone_id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_name     VARCHAR(100) NOT NULL UNIQUE,
    zone_type     VARCHAR(50) NOT NULL,
    description   TEXT,
    is_accessible BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for farmzones
ALTER TABLE farmzones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view zones" ON farmzones FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Only authenticated can modify zones" ON farmzones FOR ALL TO authenticated USING (true);
GRANT SELECT ON farmzones TO anon, authenticated;
GRANT ALL ON farmzones TO authenticated;

INSERT INTO farmzones (zone_name, zone_type, description, is_accessible) VALUES
('Main Barnyard', 'Animal Area', 'Primary animal interaction area with goats, cows, chickens', TRUE),
('Pollinator Garden', 'Garden', 'Butterfly and bee garden', TRUE),
('Food Forest', 'Garden', 'Edible landscape with fruit trees and native plants', TRUE),
('Yoga Pasture', 'Open Field', 'Open pasture area used for Cow Yoga', TRUE),
('Pavilion', 'Structure', 'Covered area for story time and workshops', TRUE)
ON CONFLICT (zone_name) DO NOTHING;

-- ============================================================================
-- TABLE: animals
-- ============================================================================
CREATE TABLE animals (
    animal_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_name       VARCHAR(100) NOT NULL,
    species           VARCHAR(50) NOT NULL,
    breed             VARCHAR(100),
    home_zone_id      UUID REFERENCES farmzones(zone_id),
    temperament       VARCHAR(50),
    is_therapy_animal BOOLEAN DEFAULT FALSE,
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for animals
ALTER TABLE animals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view animals" ON animals FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Only authenticated can modify animals" ON animals FOR ALL TO authenticated USING (true);
GRANT SELECT ON animals TO anon, authenticated;
GRANT ALL ON animals TO authenticated;

-- ============================================================================
-- TABLE: constituents
-- ============================================================================
CREATE TABLE constituents (
    constituent_id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name        VARCHAR(100),
    last_name         VARCHAR(100),
    email             VARCHAR(255) UNIQUE,
    role_type         VARCHAR(50) CHECK (role_type IN ('Volunteer', 'Student', 'Visitor', 'Staff', 'Partner')),
    enrollment_date   DATE DEFAULT CURRENT_DATE,
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for constituents
ALTER TABLE constituents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only authenticated can access constituents" ON constituents FOR ALL TO authenticated USING (true);
GRANT ALL ON constituents TO authenticated;

-- ============================================================================
-- TABLE: constituentprofiles
-- ============================================================================
CREATE TABLE constituentprofiles (
    profile_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    constituent_id    UUID NOT NULL UNIQUE REFERENCES constituents(constituent_id) ON DELETE CASCADE,
    date_of_birth     DATE,
    age_range         VARCHAR(20),
    emergency_contact VARCHAR(255),
    emergency_phone   VARCHAR(20),
    referral_source   VARCHAR(255),
    notes             TEXT,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for constituentprofiles
ALTER TABLE constituentprofiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only authenticated can access profiles" ON constituentprofiles FOR ALL TO authenticated USING (true);
GRANT ALL ON constituentprofiles TO authenticated;

-- ============================================================================
-- TABLE: experiences
-- ============================================================================
CREATE TABLE experiences (
    experience_id     UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    constituent_id    UUID REFERENCES constituents(constituent_id),
    program_id        UUID REFERENCES programcatalog(program_id),
    zone_id           UUID REFERENCES farmzones(zone_id),
    experience_date   DATE NOT NULL,
    start_time        TIME,
    facilitator_name  VARCHAR(200),
    attendance_status VARCHAR(20) DEFAULT 'Attended' CHECK (attendance_status IN ('Attended', 'No-Show', 'Cancelled')),
    notes             TEXT,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for experiences
ALTER TABLE experiences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only authenticated can access experiences" ON experiences FOR ALL TO authenticated USING (true);
GRANT ALL ON experiences TO authenticated;

-- ============================================================================
-- TABLE: surveyresponses (MAIN TABLE - PUBLIC INSERT)
-- ============================================================================
CREATE TABLE surveyresponses (
    response_id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experience_id             UUID REFERENCES experiences(experience_id),
    constituent_id            UUID REFERENCES constituents(constituent_id),
    experience_type           VARCHAR(150) NOT NULL,
    
    -- Standard Audit Scores (1-3)
    is_present_engaged        INT NOT NULL CHECK (is_present_engaged BETWEEN 1 AND 3),
    connection_others_score   INT NOT NULL CHECK (connection_others_score BETWEEN 1 AND 3),
    connection_nature_score   INT NOT NULL CHECK (connection_nature_score BETWEEN 1 AND 3),
    calmness_score            INT NOT NULL CHECK (calmness_score BETWEEN 1 AND 3),
    learning_intent_score     INT NOT NULL CHECK (learning_intent_score BETWEEN 1 AND 3),
    community_benefit_score   INT NOT NULL CHECK (community_benefit_score BETWEEN 1 AND 3),
    
    -- High Fidelity Raw Scores (1-5)
    mood_before_raw           INT,
    mood_after_raw            INT,
    nature_connection_raw     INT,
    skills_learned_score      INT CHECK (skills_learned_score BETWEEN 0 AND 100), -- New 0-100 scale metric
    
    -- Other fields
    referral_source           TEXT,
    standout_moment           TEXT,
    would_recommend           BOOLEAN DEFAULT TRUE,
    additional_feedback       TEXT,
    age_range_bracket         VARCHAR(20) NOT NULL,
    participant_name          VARCHAR(200),
    participant_email         VARCHAR(255),
    photo_url                 TEXT,
    willing_to_review         BOOLEAN DEFAULT FALSE,
    submitted_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_type               VARCHAR(50),
    created_at                TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_returning_visitor      BOOLEAN DEFAULT FALSE
);

COMMENT ON COLUMN surveyresponses.is_returning_visitor IS 'True if the user self-identifies as a returning visitor';

-- RLS for surveyresponses - THE CRITICAL PART
ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users CAN insert surveys
CREATE POLICY "Allow public survey submissions" ON surveyresponses
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- Policy: Only authenticated users can read
CREATE POLICY "Only authenticated can view surveys" ON surveyresponses
    FOR SELECT TO authenticated
    USING (true);

-- Policy: Only authenticated users can update
CREATE POLICY "Only authenticated can update" ON surveyresponses
    FOR UPDATE TO authenticated
    USING (true);

-- Policy: Only authenticated users can delete
CREATE POLICY "Only authenticated can delete" ON surveyresponses
    FOR DELETE TO authenticated
    USING (true);

-- GRANTS - CRITICAL FOR RLS TO WORK
GRANT INSERT ON surveyresponses TO anon;
GRANT ALL ON surveyresponses TO authenticated;

-- ============================================================================
-- TABLE: audit_log
-- ============================================================================
CREATE TABLE audit_log (
    log_id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name        VARCHAR(100) NOT NULL,
    record_id         UUID,
    action            VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_by        UUID,
    changed_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    old_values        JSONB,
    new_values        JSONB
);

-- RLS for audit_log
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only authenticated can access audit_log" ON audit_log FOR ALL TO authenticated USING (true);
GRANT ALL ON audit_log TO authenticated;

-- ============================================================================
-- INDEXES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_survey_experience_type ON surveyresponses(experience_type);
CREATE INDEX IF NOT EXISTS idx_survey_age_range ON surveyresponses(age_range_bracket);
CREATE INDEX IF NOT EXISTS idx_survey_referral ON surveyresponses(referral_source);
CREATE INDEX IF NOT EXISTS idx_survey_submitted ON surveyresponses(submitted_at);
CREATE INDEX IF NOT EXISTS idx_experiences_program ON experiences(program_id);
CREATE INDEX IF NOT EXISTS idx_experiences_date ON experiences(experience_date);

-- ============================================================================
-- VIEWS (WITHOUT SECURITY DEFINER - Fixed!)
-- ============================================================================

-- Impact Dashboard View (SECURITY INVOKER - uses caller's permissions)
CREATE OR REPLACE VIEW vw_impact_dashboard 
WITH (security_invoker = true) AS
SELECT 
    experience_type,
    COUNT(*) as total_responses,
    ROUND(AVG(calmness_score)::NUMERIC, 2) as avg_calmness,
    ROUND(AVG(connection_nature_score)::NUMERIC, 2) as avg_nature_connection,
    ROUND(AVG(is_present_engaged)::NUMERIC, 2) as avg_engagement,
    SUM(CASE WHEN would_recommend THEN 1 ELSE 0 END) as promoters,
    COUNT(*) - SUM(CASE WHEN would_recommend THEN 1 ELSE 0 END) as detractors
FROM surveyresponses
GROUP BY experience_type;

-- Survey with programs view (SECURITY INVOKER)
CREATE OR REPLACE VIEW vw_survey_with_programs
WITH (security_invoker = true) AS
SELECT 
    sr.response_id,
    sr.experience_type,
    sr.is_present_engaged,
    sr.connection_others_score,
    sr.connection_nature_score,
    sr.calmness_score,
    sr.learning_intent_score,
    sr.community_benefit_score,
    sr.referral_source,
    sr.age_range_bracket,
    sr.photo_url,
    sr.would_recommend,
    sr.standout_moment,
    sr.submitted_at,
    ROUND((sr.is_present_engaged + sr.connection_others_score + 
           sr.connection_nature_score + sr.calmness_score)::NUMERIC / 4, 2) AS impact_score
FROM surveyresponses sr;

-- Grant view access
GRANT SELECT ON vw_impact_dashboard TO authenticated;
GRANT SELECT ON vw_survey_with_programs TO authenticated;

-- ============================================================================
-- SCHEMA PERMISSIONS (Ensure roles can use the schema)
-- ============================================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================
-- Run this to confirm everything is set up:
-- SELECT tablename, policyname, cmd, roles FROM pg_policies WHERE schemaname = 'public';

-- ============================================================================
-- ✅ SCHEMA COMPLETE - Ready for seed_data.sql
-- ============================================================================
