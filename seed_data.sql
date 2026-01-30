-- ============================================================================
-- Empowerment Farm - Seed Data
-- ============================================================================
-- NOTE: 'ExperienceTypes' table does not exist. Programs are defined in 'programcatalog' in schema.sql.
-- This script ONLY populates the 'surveyresponses' table for analytics testing.

-- Mock Survey Responses (Rich Data for Analytics)
-- Includes variations in:
-- - Dates (Jan 2025 - Jan 2026) for "Monthly Trends"
-- - Times (Morning, Afternoon, Evening) for "Peak Times"
-- - Scores (Improved mood) for "Impact" metrics

INSERT INTO SurveyResponses (
    experience_type, 
    is_present_engaged, connection_others_score, connection_nature_score, 
    calmness_score, learning_intent_score, community_benefit_score,
    mood_before_raw, mood_after_raw, nature_connection_raw,
    is_returning_visitor,
    referral_source, age_range_bracket, standout_moment, would_recommend,
    additional_feedback, participant_name, photo_url, submitted_at, created_at
) VALUES

-- ========== EARLY 2025 (Foundation) ==========
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 4, 3, FALSE, 'Word of Mouth', '41-60', 'First visit of the year', TRUE, NULL, NULL, NULL, '2025-01-14 10:00:00', '2025-01-14 10:00:00'),
('Cow Yoga', 2, 2, 3, 3, 2, 3, 2, 4, 3, FALSE, 'Social Media', '26-40', 'New years resolution to try new things', TRUE, NULL, NULL, NULL, '2025-01-20 17:00:00', '2025-01-20 17:00:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 3, 5, 4, TRUE, 'Friend/Family', '0-17', 'Chilly but fun', TRUE, NULL, NULL, NULL, '2025-02-11 18:00:00', '2025-02-11 18:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Flyer/Poster', '61+', 'Lovely weather for a farm walk', TRUE, NULL, NULL, NULL, '2025-02-08 11:00:00', '2025-02-08 11:00:00'),
('Paint & Pollinators', 3, 3, 3, 3, 3, 3, 3, 4, 4, FALSE, 'Newsletter', '41-60', 'Spring flowers are starting', TRUE, NULL, NULL, NULL, '2025-03-15 12:00:00', '2025-03-15 12:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Social Media', '26-40', 'Best way to start spring', TRUE, NULL, NULL, NULL, '2025-03-22 17:30:00', '2025-03-22 17:30:00'),

-- ========== SPRING 2025 (Growth) ==========
('Educational Field Trips', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'School', '0-17', 'Baby chicks were so cute', TRUE, NULL, NULL, NULL, '2025-04-10 10:00:00', '2025-04-10 10:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 2, 3, 3, 3, 3, 5, 4, TRUE, 'Word of Mouth', '26-40', 'Brought the neighbors', TRUE, NULL, NULL, NULL, '2025-04-12 11:30:00', '2025-04-12 11:30:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 4, 5, 5, TRUE, 'Parent', '0-17', 'Sunset was beautiful', TRUE, NULL, NULL, NULL, '2025-05-14 19:30:00', '2025-05-14 19:30:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Social Media', '18-25', 'Goat yoga selfie!', TRUE, NULL, NULL, NULL, '2025-05-23 18:00:00', '2025-05-23 18:00:00'),
('Seedlings for Spring', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Newsletter', '41-60', 'Garden is going to look great', TRUE, NULL, NULL, NULL, '2025-06-07 09:00:00', '2025-06-07 09:00:00'),

-- ========== SUMMER 2025 (Steady) ==========
('Cow Yoga', 2, 2, 1, 2, 2, 3, 2, 4, 2, FALSE, 'Word of Mouth', '26-40', 'First time with the cows, felt nervous but curious', TRUE, NULL, 'Maria Santos', 'https://placehold.co/400x300/228B22/white?text=CowYoga1', '2025-07-15 09:30:00', '2025-07-15 09:30:00'),
('Yoga with the Animals', 2, 2, 2, 2, 2, 3, 3, 4, 3, FALSE, 'Social Media', '41-60', 'Different from regular yoga', TRUE, NULL, 'James Wilson', NULL, '2025-07-25 17:45:00', '2025-07-25 17:45:00'),
('Tuesday Night Tuck-In', 2, 2, 2, 2, 3, 3, 2, 4, 3, FALSE, 'Friend/Family', '26-40', 'Story time in the pavilion was lovely', TRUE, NULL, 'Emily Chen', NULL, '2025-08-05 18:30:00', '2025-08-05 18:30:00'),
('Open Farm (Second Saturdays)', 3, 3, 2, 3, 2, 3, 3, 4, 4, TRUE, 'Social Media', '41-60', 'Met other volunteers', TRUE, NULL, 'James Wilson', 'https://placehold.co/400x300/228B22/white?text=OpenFarm2', '2025-08-10 10:15:00', '2025-08-10 10:15:00'),
('Tuesday Night Tuck-In', 2, 3, 2, 2, 2, 3, 3, 4, 3, TRUE, 'Word of Mouth', '26-40', 'Kids loved tucking in the chickens', TRUE, NULL, 'Maria Santos', NULL, '2025-08-12 18:15:00', '2025-08-12 18:15:00'),

-- ========== FALL 2025 (Peak Season) ==========
('Educational Field Trips', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'School', '0-17', 'Learned about composting and plant cycles', TRUE, 'So much better than regular school!', 'Aiden Thompson', 'https://placehold.co/400x300/228B22/white?text=FieldTrip1', '2025-09-05 10:30:00', '2025-09-05 10:30:00'),
('Open Farm (Second Saturdays)', 3, 3, 2, 3, 3, 3, 3, 5, 4, TRUE, 'Word of Mouth', '26-40', 'The food forest tour was eye-opening', TRUE, 'Great for families!', 'Maria Santos', 'https://placehold.co/400x300/228B22/white?text=OpenFarm1', '2025-09-14 11:45:00', '2025-09-14 11:45:00'),
('Seedlings for Spring', 3, 3, 2, 3, 3, 3, 3, 5, 4, TRUE, 'Friend/Family', '26-40', 'Learning seed starting techniques', TRUE, NULL, 'Emily Chen', 'https://placehold.co/400x300/228B22/white?text=Seedlings1', '2025-09-14 09:30:00', '2025-09-14 09:30:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 2, 5, 5, TRUE, 'Social Media', '41-60', 'Buttercup is so gentle', TRUE, 'Best stress relief!', 'James Wilson', NULL, '2025-09-26 18:00:00', '2025-09-26 18:00:00'),
('JusTeenys Greenies', 3, 3, 3, 3, 3, 3, 4, 5, 5, TRUE, 'Social Media', '41-60', 'Growing my own microgreens now', TRUE, NULL, 'James Wilson', 'https://placehold.co/400x300/228B22/white?text=Microgreens1', '2025-10-04 10:00:00', '2025-10-04 10:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Parent', '0-17', 'Met new friends at the farm', TRUE, NULL, 'Noah Lewis', 'https://placehold.co/400x300/228B22/white?text=OpenFarm3', '2025-10-12 11:30:00', '2025-10-12 11:30:00'),
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Nonprofit Partner', '0-17', 'StarAbility Foundation visit', TRUE, 'So inclusive and welcoming', NULL, NULL, '2025-10-17 14:30:00', '2025-10-17 14:30:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Word of Mouth', '26-40', 'Daisy came right up to me during meditation', TRUE, 'Feeling much more connected', 'Maria Santos', NULL, '2025-10-24 17:30:00', '2025-10-24 17:30:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Friend/Family', '26-40', 'Clover the goat joined my mat!', TRUE, 'Best yoga experience ever', 'Emily Chen', NULL, '2025-10-24 16:45:00', '2025-10-24 16:45:00'),

-- ========== WINTER 2025 (Holidays) ==========
('Paint & Pollinators', 3, 3, 3, 3, 3, 3, 4, 5, 5, TRUE, 'Word of Mouth', '26-40', 'Painting while surrounded by butterflies was magical', TRUE, 'My favorite session yet!', 'Maria Santos', 'https://placehold.co/400x300/228B22/white?text=Painting1', '2025-11-15 13:00:00', '2025-11-15 13:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Social Media', '26-40', 'The cows are surprisingly calming', TRUE, 'Best wellness experience in Naples', 'Michelle Thomas', 'https://placehold.co/400x300/228B22/white?text=CowYoga3', '2025-11-21 17:45:00', '2025-11-21 17:45:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 4, 5, 5, TRUE, 'Word of Mouth', '0-17', 'Holiday lights were pretty', TRUE, NULL, NULL, NULL, '2025-12-09 18:00:00', '2025-12-09 18:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Friend/Family', '61+', 'Bought gifts at the market', TRUE, NULL, NULL, NULL, '2025-12-14 11:00:00', '2025-12-14 11:00:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Friend/Family', '26-40', 'End of year relaxation', TRUE, NULL, NULL, NULL, '2025-12-28 17:00:00', '2025-12-28 17:00:00'),

-- ========== 2026 (Current Year Start) ==========
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Word of Mouth', '26-40', 'New year new farm visit', TRUE, NULL, NULL, NULL, '2026-01-11 11:00:00', '2026-01-11 11:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Social Media', '18-25', 'Great start to 2026', TRUE, NULL, NULL, NULL, '2026-01-24 17:00:00', '2026-01-24 17:00:00'),

-- ========== Additional ANONYMOUS walk-in surveys (Peak times simulation) ==========
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 5, 4, FALSE, 'Drove By', '26-40', 'Just stopped in on a whim', TRUE, NULL, NULL, NULL, '2025-09-14 11:15:00', '2025-09-14 11:15:00'),
('Open Farm (Second Saturdays)', 2, 2, 3, 3, 2, 3, 2, 3, 4, FALSE, 'Flyer/Poster', '41-60', 'Nice escape from the city', TRUE, NULL, NULL, NULL, '2025-03-08 12:45:00', '2025-03-08 12:45:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Word of Mouth', '26-40', 'Kids loved every minute', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=TuckIn3', '2025-04-08 18:30:00', '2025-04-08 18:30:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Social Media', '18-25', 'Instagram-worthy', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=CowYoga4', '2025-05-20 17:45:00', '2025-05-20 17:45:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Friend/Family', '61+', 'Brought my grandkids', TRUE, 'Wonderful', NULL, NULL, '2025-11-09 10:15:00', '2025-11-09 10:15:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Google Search', '26-40', 'Found my new monthly ritual', TRUE, NULL, NULL, NULL, '2025-10-24 17:15:00', '2025-10-24 17:15:00'),
('Open Farm (Second Saturdays)', 3, 2, 2, 3, 2, 3, 3, 4, 3, TRUE, 'Event Listing', '41-60', 'First visit', TRUE, NULL, NULL, NULL, '2025-06-14 11:45:00', '2025-06-14 11:45:00'),
('JusTeenys Greenies', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Newsletter', '26-40', 'Growing greens at home', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=Microgreens2', '2025-02-15 10:00:00', '2025-02-15 10:00:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 4, 5, 5, TRUE, 'Parent', '26-40', 'Best Tuesday tradition', TRUE, NULL, NULL, NULL, '2025-11-19 18:30:00', '2025-11-19 18:30:00'),
('Sweethearts and Songbirds', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Newsletter', '41-60', 'Made a beautiful bird feeder', TRUE, 'Great project', NULL, 'https://placehold.co/400x300/228B22/white?text=Birdfeeder1', '2026-02-14 12:15:00', '2026-02-14 12:15:00'),

-- ========== GROUP PROGRAMS - Mid-day activity ==========
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Nonprofit Partner', '0-17', 'Boys & Girls Club field trip', TRUE, NULL, NULL, NULL, '2025-10-03 14:15:00', '2025-10-03 14:15:00'),
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 3, 5, 5, FALSE, 'Nonprofit Partner', '0-17', 'StarAbility Foundation visit', TRUE, 'So inclusive', NULL, NULL, '2025-10-17 14:30:00', '2025-10-17 14:30:00'),
('Farms Without Fences (Off-Site)', 3, 3, 3, 3, 3, 3, 4, 5, 4, FALSE, 'School', '0-17', 'Loved when the farm came to us', TRUE, NULL, NULL, NULL, '2025-04-25 10:00:00', '2025-04-25 10:00:00'),
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 3, 5, 5, TRUE, 'Nonprofit Partner', '61+', 'Senior center outing', TRUE, 'Great for all abilities', NULL, 'https://placehold.co/400x300/228B22/white?text=SeniorGroup1', '2025-11-05 11:30:00', '2025-11-05 11:30:00');

-- ============================================================================
-- END OF MOCK DATA
-- ============================================================================
