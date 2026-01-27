-- ============================================================================
-- EMPOWERMENT FARM DATABASE SCHEMA
-- ============================================================================
-- Client: Empowerment Farm (Naples, FL)
-- Mission: "Labels Stop at the Gate" - Track outcomes without diagnostic labels
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CLEANUP (Optional - ensures clean state if needed)
-- ============================================================================
-- Uncomment these lines to DELETE ALL DATA and reset tables
-- DROP TABLE IF EXISTS survey_v2 CASCADE;
-- DROP TABLE IF EXISTS surveyresponses CASCADE;
-- DROP TABLE IF EXISTS experiences CASCADE;
-- DROP TABLE IF EXISTS constituentprofiles CASCADE;
-- DROP TABLE IF EXISTS constituents CASCADE;
-- DROP TABLE IF EXISTS animals CASCADE;
-- DROP TABLE IF EXISTS farmzones CASCADE;
-- DROP TABLE IF EXISTS programcatalog CASCADE;
-- DROP TABLE IF EXISTS audit_log CASCADE;

-- Drop unwanted table "survey_v2" if the user wants to consolidate
DROP TABLE IF EXISTS survey_v2;

-- ============================================================================
-- TABLE: programcatalog
-- ============================================================================
CREATE TABLE IF NOT EXISTS programcatalog (
    program_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name      VARCHAR(150) NOT NULL UNIQUE,
    program_category  VARCHAR(100) NOT NULL,
    description       TEXT,
    schedule_notes    VARCHAR(255),
    cost_notes        VARCHAR(100),
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert programs (ON CONFLICT DO NOTHING prevents errors on re-run)
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
CREATE TABLE IF NOT EXISTS farmzones (
    zone_id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_name     VARCHAR(100) NOT NULL UNIQUE,
    zone_type     VARCHAR(50) NOT NULL,
    description   TEXT,
    is_accessible BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
CREATE TABLE IF NOT EXISTS animals (
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

-- ============================================================================
-- TABLE: constituents
-- ============================================================================
CREATE TABLE IF NOT EXISTS constituents (
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

-- ============================================================================
-- TABLE: constituentprofiles
-- ============================================================================
CREATE TABLE IF NOT EXISTS constituentprofiles (
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

-- ============================================================================
-- TABLE: experiences
-- ============================================================================
CREATE TABLE IF NOT EXISTS experiences (
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

-- ============================================================================
-- TABLE: surveyresponses
-- ============================================================================
CREATE TABLE IF NOT EXISTS surveyresponses (
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
    
    -- High Fidelity Raw Scores (1-5) - Added for Vibe Check
    mood_before_raw           INT, -- 1-5 Scale
    mood_after_raw            INT, -- 1-5 Scale
    nature_connection_raw     INT, -- 1-5 Scale
    
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
    created_at                TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TABLE: audit_log
-- ============================================================================
CREATE TABLE IF NOT EXISTS audit_log (
    log_id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name        VARCHAR(100) NOT NULL,
    record_id         UUID,
    action            VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_by        UUID,
    changed_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    old_values        JSONB,
    new_values        JSONB
);

-- ============================================================================
-- INDEXES (IF NOT EXISTS logic)
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_survey_experience_type ON surveyresponses(experience_type);
CREATE INDEX IF NOT EXISTS idx_survey_age_range ON surveyresponses(age_range_bracket);
CREATE INDEX IF NOT EXISTS idx_survey_referral ON surveyresponses(referral_source);
CREATE INDEX IF NOT EXISTS idx_survey_submitted ON surveyresponses(submitted_at);
CREATE INDEX IF NOT EXISTS idx_experiences_program ON experiences(program_id);
CREATE INDEX IF NOT EXISTS idx_experiences_date ON experiences(experience_date);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
-- Ensure RLS is enabled
ALTER TABLE surveyresponses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid duplicates before recreating
DROP POLICY IF EXISTS "Allow public survey submissions" ON surveyresponses;
DROP POLICY IF EXISTS "Only authenticated can view surveys" ON surveyresponses;
DROP POLICY IF EXISTS "Only authenticated can update" ON surveyresponses;
DROP POLICY IF EXISTS "Only authenticated can delete" ON surveyresponses;

CREATE POLICY "Allow public survey submissions" ON surveyresponses
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

CREATE POLICY "Only authenticated can view surveys" ON surveyresponses
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "Only authenticated can update" ON surveyresponses
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "Only authenticated can delete" ON surveyresponses
    FOR DELETE TO authenticated
    USING (true);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Impact Dashboard View
DROP VIEW IF EXISTS vw_impact_dashboard;
CREATE OR REPLACE VIEW vw_impact_dashboard AS
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

-- Survey with programs view
DROP VIEW IF EXISTS vw_survey_with_programs;
CREATE OR REPLACE VIEW vw_survey_with_programs AS
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
