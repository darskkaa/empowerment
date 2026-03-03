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
DROP TABLE IF EXISTS custom_questions CASCADE;
DROP TABLE IF EXISTS core_questions_config CASCADE;
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

-- Insert programs (Updated per Tiffany's email Feb 1, 2026)
INSERT INTO programcatalog (program_name, program_category, description, schedule_notes, cost_notes) VALUES
('Open Farm on Second Saturday', 'Open Farm', 'Self-guided tours, animal meet and greets, farm market shopping', '2nd Saturday monthly, 9AM-1PM', '$10/Adult, $25/Family'),
('Yoga on the Farm', 'Yoga', 'Monthly yoga on the farm with animals, includes relaxation and connection to nature', '4th Thursday monthly, 4-6PM', '$30/Person'),
('Tuesday Night Tuck-In', 'Family Program', 'Afterschool wind-down: open play, tuck animals in for bed, story time', 'Every Tuesday 3:30-5:30PM', '$25/Family'),
('Group Program', 'Group Program', 'Customized group experiences including educational field trips and workshops', 'By appointment', 'Contact for pricing')
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
    is_present_engaged        INT CHECK (is_present_engaged BETWEEN 1 AND 3),
    connection_others_score   INT CHECK (connection_others_score BETWEEN 1 AND 3),
    connection_nature_score   INT CHECK (connection_nature_score BETWEEN 1 AND 3),
    calmness_score            INT CHECK (calmness_score BETWEEN 1 AND 3),
    learning_intent_score     INT CHECK (learning_intent_score BETWEEN 1 AND 3),
    community_benefit_score   INT CHECK (community_benefit_score BETWEEN 1 AND 3),
    
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
    is_returning_visitor      BOOLEAN DEFAULT FALSE,
    
    -- New questions added Feb 2, 2026
    will_return               BOOLEAN,
    donation_interest         VARCHAR(10) CHECK (donation_interest IN ('yes', 'maybe', 'no'))
);

COMMENT ON COLUMN surveyresponses.is_returning_visitor IS 'True if the user self-identifies as a returning visitor';

-- RLS for surveyresponses - THE CRITICAL PART
ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;

-- Policy: Anonymous users CAN insert surveys (explicit anon for Supabase/PostgREST)
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
-- Required for default uuid_generate_v4() on insert as anon
GRANT EXECUTE ON FUNCTION uuid_generate_v4() TO anon;

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
-- TABLE: custom_questions (CLIENT-MANAGEABLE DYNAMIC QUESTIONS)
-- ============================================================================
CREATE TABLE custom_questions (
    question_id    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_text  VARCHAR(300) NOT NULL,
    emoji          VARCHAR(10) DEFAULT '✨',
    display_order  INT DEFAULT 0,
    is_active      BOOLEAN DEFAULT TRUE,
    created_by     UUID,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE custom_questions IS 'Client-defined survey questions manageable from dashboard';

-- RLS for custom_questions
ALTER TABLE custom_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active questions" ON custom_questions 
    FOR SELECT TO anon, authenticated USING (is_active = TRUE);
CREATE POLICY "Authenticated can manage questions" ON custom_questions 
    FOR ALL TO authenticated USING (true);
GRANT SELECT ON custom_questions TO anon, authenticated;
GRANT ALL ON custom_questions TO authenticated;

-- Add JSONB column to surveyresponses for custom question responses
ALTER TABLE surveyresponses ADD COLUMN IF NOT EXISTS custom_responses JSONB DEFAULT '{}'::jsonb;
COMMENT ON COLUMN surveyresponses.custom_responses IS 'Stores responses to custom questions as {question_uuid: score(1-3)}';

-- ============================================================================
-- TABLE: core_questions_config (reorder, remove, edit text for mission block)
-- ============================================================================
CREATE TABLE core_questions_config (
    core_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code            TEXT NOT NULL UNIQUE,
    default_text    TEXT NOT NULL,
    current_text    TEXT,
    emoji           VARCHAR(10) DEFAULT '✨',
    display_order   INT DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
COMMENT ON TABLE core_questions_config IS 'Configurable text and order for core mission questions; code maps to surveyresponses columns';

ALTER TABLE core_questions_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active core questions" ON core_questions_config
    FOR SELECT TO anon, authenticated USING (is_active = TRUE);
CREATE POLICY "Authenticated can manage core questions" ON core_questions_config
    FOR ALL TO authenticated USING (true);
GRANT SELECT ON core_questions_config TO anon, authenticated;
GRANT ALL ON core_questions_config TO authenticated;

-- ============================================================================
-- TABLE: survey_questions_order (UNIFIED ORDER FOR CORE + CUSTOM QUESTIONS)
-- ============================================================================
CREATE TABLE survey_questions_order (
    order_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_type TEXT NOT NULL CHECK (question_type IN ('core', 'custom')),
    core_id       UUID REFERENCES core_questions_config(core_id) ON DELETE CASCADE,
    question_id   UUID REFERENCES custom_questions(question_id) ON DELETE CASCADE,
    display_order INT NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT survey_questions_order_one_ref_chk CHECK (
        (question_type = 'core' AND core_id IS NOT NULL AND question_id IS NULL)
        OR
        (question_type = 'custom' AND question_id IS NOT NULL AND core_id IS NULL)
    )
);

COMMENT ON TABLE survey_questions_order IS 'Unified, interleavable order for survey questions (core + custom). Dashboard manages; public survey reads active order.';

ALTER TABLE survey_questions_order ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active survey question order" ON survey_questions_order
    FOR SELECT TO anon, authenticated USING (is_active = TRUE);
CREATE POLICY "Authenticated can manage survey question order" ON survey_questions_order
    FOR ALL TO authenticated USING (true);
GRANT SELECT ON survey_questions_order TO anon, authenticated;
GRANT ALL ON survey_questions_order TO authenticated;

-- ============================================================================
-- INDEXES
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_survey_experience_type ON surveyresponses(experience_type);
CREATE INDEX IF NOT EXISTS idx_survey_age_range ON surveyresponses(age_range_bracket);
CREATE INDEX IF NOT EXISTS idx_survey_referral ON surveyresponses(referral_source);
CREATE INDEX IF NOT EXISTS idx_survey_submitted ON surveyresponses(submitted_at);
CREATE INDEX IF NOT EXISTS idx_experiences_program ON experiences(program_id);
CREATE INDEX IF NOT EXISTS idx_experiences_date ON experiences(experience_date);
CREATE INDEX IF NOT EXISTS idx_custom_questions_active ON custom_questions(is_active, display_order);
CREATE UNIQUE INDEX IF NOT EXISTS idx_custom_questions_active_order ON custom_questions (display_order) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_core_questions_config_active_order ON core_questions_config(is_active, display_order);
CREATE INDEX IF NOT EXISTS idx_survey_questions_order_active_order ON survey_questions_order(is_active, display_order);
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_questions_order_active_display_order ON survey_questions_order(display_order) WHERE is_active = TRUE;
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_questions_order_active_core ON survey_questions_order(core_id) WHERE is_active = TRUE AND question_type = 'core';
CREATE UNIQUE INDEX IF NOT EXISTS idx_survey_questions_order_active_custom ON survey_questions_order(question_id) WHERE is_active = TRUE AND question_type = 'custom';

-- Seed core mission questions (idempotent)
INSERT INTO core_questions_config (code, default_text, current_text, emoji, display_order, is_active) VALUES
    ('present_engaged', 'Did you feel present and engaged?', NULL, '✨', 0, TRUE),
    ('connection_others', 'Feel more connected to others?', NULL, '👥', 1, TRUE),
    ('connection_nature', 'Feel more connected to nature?', NULL, '🌿', 2, TRUE),
    ('calmness', 'Feel calmer or more grounded?', NULL, '🧘', 3, TRUE),
    ('learning_intent', 'Will you use what you learned?', NULL, '🧠', 4, TRUE),
    ('community_benefit', 'Should we have more of this?', NULL, '🏛️', 5, TRUE)
ON CONFLICT (code) DO NOTHING;

-- Seed unified question order (idempotent): core then custom
INSERT INTO survey_questions_order (question_type, core_id, question_id, display_order, is_active)
SELECT * FROM (
    WITH core AS (
        SELECT core_id, ROW_NUMBER() OVER (ORDER BY display_order, created_at) - 1 AS ord
        FROM core_questions_config
        WHERE is_active = TRUE
    ),
    core_count AS (SELECT COUNT(*)::INT AS n FROM core),
    custom AS (
        SELECT question_id, ROW_NUMBER() OVER (ORDER BY display_order, created_at) - 1 AS ord
        FROM custom_questions
        WHERE is_active = TRUE
    )
    SELECT 'core'::TEXT, core.core_id, NULL::UUID, core.ord::INT, TRUE FROM core
    UNION ALL
    SELECT 'custom'::TEXT, NULL::UUID, custom.question_id, (custom.ord + (SELECT n FROM core_count))::INT, TRUE FROM custom
) seeded
WHERE NOT EXISTS (SELECT 1 FROM survey_questions_order);

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
