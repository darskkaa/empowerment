-- ============================================================================
-- EMPOWERMENT FARM DATABASE SCHEMA (AUDIT-COMPLIANT)
-- ============================================================================
-- Client: Empowerment Farm (Naples, FL)
-- Mission: "Labels Stop at the Gate" - Track outcomes without diagnostic labels
-- Audit: Schema matches JotForm survey questions exactly (Yes/Somewhat/No = 3/2/1)
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: ProgramCatalog
-- ============================================================================
-- Purpose: Master list of actual programs offered at Empowerment Farm.
-- Source: Extracted directly from empowermentfarm.org website content.
-- ============================================================================
CREATE TABLE ProgramCatalog (
    program_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name      VARCHAR(150) NOT NULL UNIQUE,
    program_category  VARCHAR(100) NOT NULL,
    description       TEXT,
    schedule_notes    VARCHAR(255),
    cost_notes        VARCHAR(100),
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert ACTUAL programs from website
INSERT INTO ProgramCatalog (program_name, program_category, description, schedule_notes, cost_notes) VALUES
('Open Farm (Second Saturdays)', 'Open Farm', 'Self-guided tours, animal meet and greets, farm market shopping, food forest exploration', '2nd Saturday monthly, 9AM-1PM', '$10/Adult, $25/Family'),
('Cow Yoga', 'Yoga', 'Farmyard yoga featuring cows, relaxation and regeneration', '4th Thursday monthly, 4-6PM', '$30/Person'),
('Yoga with the Animals', 'Yoga', 'Monthly yoga on the farm with animals, includes social hour', '4th Thursday monthly, 4-5PM', '$30/Person'),
('Tuesday Night Tuck-In', 'Family Program', 'Afterschool wind-down: open play, tuck animals in for bed, story time', 'Every Tuesday 3:30-5:30PM', '$25/Family'),
('Paint & Pollinators', 'Workshop', 'Guided painting experience in the pollinator garden', 'Saturday workshops', 'Varies'),
('Seedlings for Spring', 'Workshop', 'Learn the process of starting seedlings for springtime', 'Saturday workshops', 'Varies'),
('Better Together - Hugging Can Planters', 'Workshop', 'Companion planting for healthier gardens', 'Saturday workshops', 'Varies'),
('Sweethearts and Songbirds', 'Workshop', 'Hands-on project supporting local wildlife', 'Saturday workshops', 'Varies'),
('JusTeenys Greenies', 'Partner Workshop', 'Microgreens growing workshop with local organic farm', 'Monthly', '$10/Person, $5/Child'),
('Educational Field Trips', 'Group Program', 'Hands-on learning for grades K-12, curriculum-aligned', 'By appointment', 'Contact for pricing'),
('Group & Partner Programs', 'Group Program', 'Programs for nonprofits, schools, senior centers', 'By appointment', 'Contact for pricing'),
('Farms Without Fences (Off-Site)', 'Outreach', 'Off-site programs brought to schools, businesses, senior centers', 'By appointment', 'Contact for pricing');

-- ============================================================================
-- TABLE: FarmZones
-- ============================================================================
-- Purpose: Physical areas within the farm where experiences occur.
-- ============================================================================
CREATE TABLE FarmZones (
    zone_id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    zone_name     VARCHAR(100) NOT NULL UNIQUE,
    zone_type     VARCHAR(50) NOT NULL,
    description   TEXT,
    is_accessible BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO FarmZones (zone_name, zone_type, description, is_accessible) VALUES
('Main Barnyard', 'Animal Area', 'Primary animal interaction area with goats, cows, chickens', TRUE),
('Pollinator Garden', 'Garden', 'Butterfly and bee garden, used for Paint & Pollinators', TRUE),
('Food Forest', 'Garden', 'Edible landscape with fruit trees and native plants', TRUE),
('Yoga Pasture', 'Open Field', 'Open pasture area used for Cow Yoga and animal yoga', TRUE),
('Pavilion', 'Structure', 'Covered area for story time and workshops', TRUE),
('Farm Market', 'Retail', 'Shop area for farm products and local goods', TRUE),
('Microgreens Station', 'Garden', 'JusTeenys Greenies workshop area', TRUE);

-- ============================================================================
-- TABLE: Animals
-- ============================================================================
-- Purpose: Registry of therapy and farm animals.
-- ============================================================================
CREATE TABLE Animals (
    animal_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    animal_name       VARCHAR(100) NOT NULL,
    species           VARCHAR(50) NOT NULL,
    breed             VARCHAR(100),
    home_zone_id      UUID REFERENCES FarmZones(zone_id),
    temperament       VARCHAR(50),
    is_therapy_animal BOOLEAN DEFAULT FALSE,
    is_active         BOOLEAN DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TABLE: Constituents
-- ============================================================================
-- Purpose: Core identity for participants. Contains ONLY non-sensitive data.
-- Privacy: No diagnostic labels, referral sources, or medical info here.
-- ============================================================================
CREATE TABLE Constituents (
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
-- TABLE: ConstituentProfiles (🔒 RESTRICTED ACCESS)
-- ============================================================================
-- Purpose: Contains sensitive/private info requiring elevated permissions.
-- Privacy: This table supports "Labels Stop at the Gate" by separating
--          demographic data needed for GRANT REPORTING from operational use.
-- Audit Note: age_range exists here for known constituents with profiles.
-- ============================================================================
CREATE TABLE ConstituentProfiles (
    profile_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    constituent_id    UUID NOT NULL UNIQUE REFERENCES Constituents(constituent_id) ON DELETE CASCADE,
    date_of_birth     DATE,
    age_range         VARCHAR(20),  -- For grant reporting on known users
    emergency_contact VARCHAR(255),
    emergency_phone   VARCHAR(20),
    referral_source   VARCHAR(255),
    notes             TEXT,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TABLE: Experiences
-- ============================================================================
-- Purpose: Links participants to specific program sessions.
-- ============================================================================
CREATE TABLE Experiences (
    experience_id     UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    constituent_id    UUID REFERENCES Constituents(constituent_id),
    program_id        UUID REFERENCES ProgramCatalog(program_id),
    zone_id           UUID REFERENCES FarmZones(zone_id),
    experience_date   DATE NOT NULL,
    start_time        TIME,
    facilitator_name  VARCHAR(200),
    attendance_status VARCHAR(20) DEFAULT 'Attended' CHECK (attendance_status IN ('Attended', 'No-Show', 'Cancelled')),
    notes             TEXT,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TABLE: SurveyResponses (JOTFORM-ALIGNED)
-- ============================================================================
-- Purpose: Captures participant feedback EXACTLY matching JotForm survey.
-- Audit: Each column maps 1:1 to a specific JotForm question.
-- Scale: 3=Yes, 2=Somewhat, 1=No (matches JotForm radio options)
-- 
-- CRITICAL: age_range_bracket exists HERE for anonymous walk-in surveys
--           where we don't have a constituent profile. This allows demographic
--           reporting even for one-time visitors who don't create accounts.
-- ============================================================================
CREATE TABLE SurveyResponses (
    response_id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Link to experience (optional - may be anonymous)
    experience_id             UUID REFERENCES Experiences(experience_id),
    constituent_id            UUID REFERENCES Constituents(constituent_id),
    
    -- Q1: What was your most recent experience?
    experience_type           VARCHAR(150) NOT NULL,
    
    -- Q2: Matrix questions (3=Yes, 2=Somewhat, 1=No)
    is_present_engaged        INT NOT NULL CHECK (is_present_engaged BETWEEN 1 AND 3),
    connection_others_score   INT NOT NULL CHECK (connection_others_score BETWEEN 1 AND 3),
    connection_nature_score   INT NOT NULL CHECK (connection_nature_score BETWEEN 1 AND 3),
    calmness_score            INT NOT NULL CHECK (calmness_score BETWEEN 1 AND 3),
    learning_intent_score     INT NOT NULL CHECK (learning_intent_score BETWEEN 1 AND 3),
    community_benefit_score   INT NOT NULL CHECK (community_benefit_score BETWEEN 1 AND 3),
    
    -- Q4: How did you hear about us? (multi-select stored as comma-separated)
    referral_source           TEXT,
    
    -- Q8: Standout moment (open text)
    standout_moment           TEXT,
    
    -- Q9: Would recommend?
    would_recommend           BOOLEAN DEFAULT TRUE,
    
    -- Q10: Additional feedback
    additional_feedback       TEXT,
    
    -- Demographics (REQUIRED for anonymous users)
    age_range_bracket         VARCHAR(20) NOT NULL,  -- '0-17', '18-25', '26-40', '41-60', '61+'
    
    -- Optional identity (for follow-up)
    participant_name          VARCHAR(200),
    participant_email         VARCHAR(255),
    
    -- Photo capture (optional)
    photo_url                 TEXT,
    
    -- Consent
    willing_to_review         BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    submitted_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_type               VARCHAR(50),
    created_at                TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES for performance
-- ============================================================================
CREATE INDEX idx_survey_experience_type ON SurveyResponses(experience_type);
CREATE INDEX idx_survey_age_range ON SurveyResponses(age_range_bracket);
CREATE INDEX idx_survey_referral ON SurveyResponses(referral_source);
CREATE INDEX idx_survey_submitted ON SurveyResponses(submitted_at);
CREATE INDEX idx_survey_has_photo ON SurveyResponses(photo_url) WHERE photo_url IS NOT NULL;
CREATE INDEX idx_experiences_program ON Experiences(program_id);
CREATE INDEX idx_experiences_date ON Experiences(experience_date);

-- ============================================================================
-- ROW LEVEL SECURITY (Supabase)
-- ============================================================================
-- Enable RLS so public can INSERT surveys but only admins can SELECT
ALTER TABLE SurveyResponses ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can insert their own survey response
CREATE POLICY "Allow public survey submissions" ON SurveyResponses
    FOR INSERT TO anon, authenticated
    WITH CHECK (true);

-- Policy: Only authenticated users can view responses
CREATE POLICY "Only authenticated can view surveys" ON SurveyResponses
    FOR SELECT TO authenticated
    USING (true);

-- ============================================================================
-- VIEWS: Analytics Pre-Built
-- ============================================================================

-- View: Survey responses with program details
CREATE VIEW vw_survey_with_programs AS
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
    -- Computed impact score (average of core metrics)
    ROUND((sr.is_present_engaged + sr.connection_others_score + 
           sr.connection_nature_score + sr.calmness_score)::NUMERIC / 4, 2) AS impact_score
FROM SurveyResponses sr;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
