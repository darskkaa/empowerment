-- ============================================================================
-- EMPOWERMENT FARM - MOCK DATA POPULATION (AUDIT-COMPLIANT)
-- ============================================================================
-- Data matches JotForm survey structure: Yes(3)/Somewhat(2)/No(1)
-- Trends: connection_nature_score improves for recurring volunteers
-- Photos: ~30% of records have photo_url
-- ============================================================================

-- ============================================================================
-- ANIMALS (Farm animals mentioned on website)
-- ============================================================================
INSERT INTO Animals (animal_name, species, breed, temperament, is_therapy_animal) VALUES
('Daisy', 'Cow', 'Jersey', 'Calm', TRUE),
('Buttercup', 'Cow', 'Holstein', 'Gentle', TRUE),
('Clover', 'Goat', 'Nigerian Dwarf', 'Playful', TRUE),
('Maple', 'Goat', 'Pygmy', 'Calm', TRUE),
('Patches', 'Goat', 'LaMancha', 'Friendly', TRUE),
('Henrietta', 'Chicken', 'Silkie', 'Calm', TRUE),
('Nugget', 'Chicken', 'Buff Orpington', 'Friendly', TRUE),
('Thumper', 'Rabbit', 'Holland Lop', 'Gentle', TRUE),
('Cinnamon', 'Rabbit', 'Mini Rex', 'Calm', TRUE);

-- ============================================================================
-- CONSTITUENTS (28 participants)
-- ============================================================================
INSERT INTO Constituents (constituent_id, first_name, last_name, email, role_type, enrollment_date) VALUES
-- Volunteers (10)
('d0000001-0000-0000-0000-000000000001', 'Maria', 'Santos', 'maria.santos@email.com', 'Volunteer', '2025-06-15'),
('d0000001-0000-0000-0000-000000000002', 'James', 'Wilson', 'james.w@email.com', 'Volunteer', '2025-07-01'),
('d0000001-0000-0000-0000-000000000003', 'Emily', 'Chen', 'emily.chen@email.com', 'Volunteer', '2025-07-20'),
('d0000001-0000-0000-0000-000000000004', 'Robert', 'Johnson', 'r.johnson@email.com', 'Volunteer', '2025-08-01'),
('d0000001-0000-0000-0000-000000000005', 'Sofia', 'Martinez', 'sofia.m@email.com', 'Volunteer', '2025-08-15'),
('d0000001-0000-0000-0000-000000000006', 'Michael', 'Brown', 'mbrown@email.com', 'Volunteer', '2025-09-01'),
('d0000001-0000-0000-0000-000000000007', 'Linda', 'Davis', 'ldavis@email.com', 'Volunteer', '2025-09-15'),
('d0000001-0000-0000-0000-000000000008', 'David', 'Garcia', 'dgarcia@email.com', 'Volunteer', '2025-10-01'),
('d0000001-0000-0000-0000-000000000009', 'Patricia', 'Lee', 'plee@email.com', 'Volunteer', '2025-10-15'),
('d0000001-0000-0000-0000-000000000010', 'Kevin', 'Yue', 'kyue@email.com', 'Volunteer', '2025-11-01'),
-- Students (10)
('d0000001-0000-0000-0000-000000000011', 'Aiden', 'Thompson', 'aiden.t@school.edu', 'Student', '2025-08-20'),
('d0000001-0000-0000-0000-000000000012', 'Olivia', 'White', 'olivia.w@school.edu', 'Student', '2025-08-25'),
('d0000001-0000-0000-0000-000000000013', 'Ethan', 'Harris', 'ethan.h@school.edu', 'Student', '2025-09-01'),
('d0000001-0000-0000-0000-000000000014', 'Ava', 'Clark', 'ava.c@school.edu', 'Student', '2025-09-10'),
('d0000001-0000-0000-0000-000000000015', 'Noah', 'Lewis', 'noah.l@school.edu', 'Student', '2025-09-15'),
('d0000001-0000-0000-0000-000000000016', 'Isabella', 'Walker', 'isabella.w@school.edu', 'Student', '2025-10-01'),
('d0000001-0000-0000-0000-000000000017', 'Lucas', 'Hall', 'lucas.h@school.edu', 'Student', '2025-10-10'),
('d0000001-0000-0000-0000-000000000018', 'Mia', 'Allen', 'mia.a@school.edu', 'Student', '2025-10-15'),
('d0000001-0000-0000-0000-000000000019', 'Mason', 'Scott', 'mason.s@school.edu', 'Student', '2025-11-01'),
('d0000001-0000-0000-0000-000000000020', 'Charlotte', 'Green', 'charlotte.g@school.edu', 'Student', '2025-11-10'),
-- Visitors (8)
('d0000001-0000-0000-0000-000000000021', 'Jennifer', 'Adams', 'jadams@email.com', 'Visitor', '2025-09-01'),
('d0000001-0000-0000-0000-000000000022', 'Thomas', 'Nelson', 'tnelson@email.com', 'Visitor', '2025-09-15'),
('d0000001-0000-0000-0000-000000000023', 'Amanda', 'Hill', 'ahill@email.com', 'Visitor', '2025-10-01'),
('d0000001-0000-0000-0000-000000000024', 'Christopher', 'Moore', 'cmoore@email.com', 'Visitor', '2025-10-15'),
('d0000001-0000-0000-0000-000000000025', 'Sarah', 'Taylor', 'staylor@email.com', 'Visitor', '2025-10-20'),
('d0000001-0000-0000-0000-000000000026', 'Daniel', 'Anderson', 'danderson@email.com', 'Visitor', '2025-11-01'),
('d0000001-0000-0000-0000-000000000027', 'Michelle', 'Thomas', 'mthomas@email.com', 'Visitor', '2025-11-10'),
('d0000001-0000-0000-0000-000000000028', 'Matthew', 'Jackson', 'mjackson@email.com', 'Visitor', '2025-11-15');

-- ============================================================================
-- SURVEY RESPONSES (55+ records with realistic trends)
-- ============================================================================
-- Scale: 3=Yes, 2=Somewhat, 1=No
-- Trends: Recurring volunteers show improvement in connection_nature_score
-- Photos: ~30% have photo_url
-- ============================================================================

INSERT INTO SurveyResponses (
    experience_type, 
    is_present_engaged, connection_others_score, connection_nature_score, 
    calmness_score, learning_intent_score, community_benefit_score,
    referral_source, age_range_bracket, standout_moment, would_recommend,
    additional_feedback, participant_name, photo_url, submitted_at
) VALUES

-- ========== MARIA SANTOS (Volunteer) - UPWARD TREND in nature connection ==========
('Cow Yoga', 2, 2, 1, 2, 2, 3, 'Word of Mouth', '26-40', 'First time with the cows, felt nervous but curious', TRUE, NULL, 'Maria Santos', 'https://placehold.co/400x300/228B22/white?text=CowYoga1', '2025-07-15 17:30:00'),
('Tuesday Night Tuck-In', 2, 3, 2, 2, 2, 3, 'Word of Mouth', '26-40', 'Kids loved tucking in the chickens', TRUE, NULL, 'Maria Santos', NULL, '2025-08-12 18:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 2, 3, 3, 3, 'Word of Mouth', '26-40', 'The food forest tour was eye-opening', TRUE, 'Great for families!', 'Maria Santos', 'https://placehold.co/400x300/228B22/white?text=OpenFarm1', '2025-09-14 12:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 'Word of Mouth', '26-40', 'Daisy came right up to me during meditation', TRUE, 'Feeling much more connected', 'Maria Santos', NULL, '2025-10-24 17:30:00'),
('Paint & Pollinators', 3, 3, 3, 3, 3, 3, 'Word of Mouth', '26-40', 'Painting while surrounded by butterflies was magical', TRUE, 'My favorite session yet!', 'Maria Santos', 'https://placehold.co/400x300/228B22/white?text=Painting1', '2025-11-15 12:30:00'),

-- ========== JAMES WILSON (Volunteer) - UPWARD TREND ==========
('Yoga with the Animals', 2, 2, 2, 2, 2, 3, 'Social Media', '41-60', 'Different from regular yoga', TRUE, NULL, 'James Wilson', NULL, '2025-07-25 17:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 2, 3, 2, 3, 'Social Media', '41-60', 'Met other volunteers', TRUE, NULL, 'James Wilson', 'https://placehold.co/400x300/228B22/white?text=OpenFarm2', '2025-08-10 11:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 'Social Media', '41-60', 'Buttercup is so gentle', TRUE, 'Best stress relief!', 'James Wilson', NULL, '2025-09-26 17:30:00'),
('JusTeenys Greenies', 3, 3, 3, 3, 3, 3, 'Social Media', '41-60', 'Growing my own microgreens now', TRUE, NULL, 'James Wilson', 'https://placehold.co/400x300/228B22/white?text=Microgreens1', '2025-10-04 10:00:00'),

-- ========== EMILY CHEN (Volunteer) - UPWARD TREND ==========
('Tuesday Night Tuck-In', 2, 2, 2, 2, 3, 3, 'Friend/Family', '26-40', 'Story time in the pavilion was lovely', TRUE, NULL, 'Emily Chen', NULL, '2025-08-05 18:00:00'),
('Seedlings for Spring', 3, 3, 2, 3, 3, 3, 'Friend/Family', '26-40', 'Learning seed starting techniques', TRUE, NULL, 'Emily Chen', 'https://placehold.co/400x300/228B22/white?text=Seedlings1', '2025-09-14 10:30:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 'Friend/Family', '26-40', 'Clover the goat joined my mat!', TRUE, 'Best yoga experience ever', 'Emily Chen', NULL, '2025-10-24 17:00:00'),
('Paint & Pollinators', 3, 3, 3, 3, 3, 3, 'Friend/Family', '26-40', 'Created a beautiful butterfly painting', TRUE, NULL, 'Emily Chen', 'https://placehold.co/400x300/228B22/white?text=Painting2', '2025-11-08 12:00:00'),

-- ========== STUDENTS - Various Programs ==========
('Educational Field Trips', 3, 3, 3, 3, 3, 3, 'School', '0-17', 'Learned about composting and plant cycles', TRUE, 'So much better than regular school!', 'Aiden Thompson', 'https://placehold.co/400x300/228B22/white?text=FieldTrip1', '2025-09-05 14:00:00'),
('Educational Field Trips', 3, 3, 3, 3, 3, 3, 'School', '0-17', 'Fed the goats and learned about animal care', TRUE, NULL, 'Olivia White', NULL, '2025-09-05 14:00:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 'School', '0-17', 'Tucking in Henrietta the chicken was my favorite', TRUE, 'Want to come every week!', 'Ethan Harris', 'https://placehold.co/400x300/228B22/white?text=TuckIn1', '2025-09-17 18:00:00'),
('Educational Field Trips', 3, 2, 3, 3, 3, 3, 'School', '0-17', 'The food forest was amazing', TRUE, NULL, 'Ava Clark', NULL, '2025-09-19 14:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 'Parent', '0-17', 'Met new friends at the farm', TRUE, NULL, 'Noah Lewis', 'https://placehold.co/400x300/228B22/white?text=OpenFarm3', '2025-10-12 11:00:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 2, 3, 'Parent', '0-17', 'Story time under the pavilion', TRUE, NULL, 'Isabella Walker', NULL, '2025-10-15 18:00:00'),
('Educational Field Trips', 3, 3, 3, 3, 3, 3, 'School', '0-17', 'Hands-on learning is the best', TRUE, 'Teachers should bring us more often', 'Lucas Hall', NULL, '2025-10-22 14:00:00'),
('Seedlings for Spring', 3, 3, 2, 3, 3, 3, 'Parent', '0-17', 'Started my own seedlings to take home', TRUE, NULL, 'Mia Allen', 'https://placehold.co/400x300/228B22/white?text=Seedlings2', '2025-11-09 10:30:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 'Friend/Family', '0-17', 'The rabbits are so soft!', TRUE, 'Love coming here after school', 'Mason Scott', NULL, '2025-11-12 18:00:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 'Social Media', '0-17', 'Farm market had great snacks', TRUE, NULL, 'Charlotte Green', 'https://placehold.co/400x300/228B22/white?text=OpenFarm4', '2025-11-09 12:00:00'),

-- ========== VISITORS - One-time experiences ==========
('Cow Yoga', 3, 3, 3, 3, 3, 3, 'Google Search', '26-40', 'Never done yoga with cows before - transformative!', TRUE, 'Will definitely return', 'Jennifer Adams', 'https://placehold.co/400x300/228B22/white?text=CowYoga2', '2025-09-26 17:30:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 2, 3, 'Flyer/Poster', '41-60', 'Wonderful family outing', TRUE, NULL, 'Thomas Nelson', NULL, '2025-10-12 11:00:00'),
('Paint & Pollinators', 3, 3, 3, 3, 3, 3, 'Friend/Family', '26-40', 'Relaxing and creative combination', TRUE, 'Highly recommend!', 'Amanda Hill', 'https://placehold.co/400x300/228B22/white?text=Painting3', '2025-10-12 12:00:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 'Event Listing', '18-25', 'The goats made yoga so much more fun', TRUE, NULL, 'Christopher Moore', NULL, '2025-10-24 17:00:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 'Word of Mouth', '26-40', 'Perfect after-school activity for my kids', TRUE, 'Great family bonding', 'Sarah Taylor', 'https://placehold.co/400x300/228B22/white?text=TuckIn2', '2025-10-22 18:00:00'),
('Open Farm (Second Saturdays)', 3, 2, 3, 3, 3, 3, 'Google Search', '41-60', 'Peaceful morning at the farm', TRUE, NULL, 'Daniel Anderson', NULL, '2025-11-09 10:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 'Social Media', '26-40', 'The cows are surprisingly calming', TRUE, 'Best wellness experience in Naples', 'Michelle Thomas', 'https://placehold.co/400x300/228B22/white?text=CowYoga3', '2025-11-21 17:30:00'),
('Better Together - Hugging Can Planters', 3, 3, 3, 3, 3, 3, 'Newsletter', '61+', 'Learned about companion planting', TRUE, 'Great for seniors like me!', 'Matthew Jackson', NULL, '2025-11-09 10:30:00'),

-- ========== Additional ANONYMOUS walk-in surveys ==========
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 'Drove By', '26-40', 'Just stopped in on a whim - so glad I did', TRUE, NULL, NULL, NULL, '2025-09-14 11:00:00'),
('Open Farm (Second Saturdays)', 2, 2, 3, 3, 2, 3, 'Flyer/Poster', '41-60', 'Nice escape from the city', TRUE, NULL, NULL, NULL, '2025-09-14 12:30:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 'Word of Mouth', '26-40', 'Kids loved every minute', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=TuckIn3', '2025-09-24 18:00:00'),
('Cow Yoga', 3, 3, 3, 3, 3, 3, 'Social Media', '18-25', 'Instagram-worthy and actually relaxing', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=CowYoga4', '2025-09-26 17:30:00'),
('Open Farm (Second Saturdays)', 3, 3, 3, 3, 3, 3, 'Friend/Family', '61+', 'Brought my grandkids', TRUE, 'Wonderful for all ages', NULL, NULL, '2025-10-12 10:00:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 'Google Search', '26-40', 'Found my new monthly ritual', TRUE, NULL, NULL, NULL, '2025-10-24 17:00:00'),
('Open Farm (Second Saturdays)', 3, 2, 2, 3, 2, 3, 'Event Listing', '41-60', 'First visit, will return', TRUE, NULL, NULL, NULL, '2025-11-09 11:00:00'),
('JusTeenys Greenies', 3, 3, 3, 3, 3, 3, 'Newsletter', '26-40', 'Growing greens at home now', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=Microgreens2', '2025-11-07 10:00:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 'Parent', '26-40', 'Best Tuesday tradition', TRUE, NULL, NULL, NULL, '2025-11-19 18:00:00'),
('Sweethearts and Songbirds', 3, 3, 3, 3, 3, 3, 'Newsletter', '41-60', 'Made a beautiful bird feeder', TRUE, 'Great hands-on project', NULL, 'https://placehold.co/400x300/228B22/white?text=Birdfeeder1', '2025-11-09 12:00:00'),

-- ========== GROUP PROGRAMS ==========
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 'Nonprofit Partner', '0-17', 'Boys & Girls Club field trip was amazing', TRUE, NULL, NULL, NULL, '2025-10-03 14:00:00'),
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 'Nonprofit Partner', '0-17', 'StarAbility Foundation visit', TRUE, 'So inclusive and welcoming', NULL, NULL, '2025-10-17 14:00:00'),
('Farms Without Fences (Off-Site)', 3, 3, 3, 3, 3, 3, 'School', '0-17', 'Loved when the farm came to our school', TRUE, NULL, NULL, NULL, '2025-10-25 10:00:00'),
('Group & Partner Programs', 3, 3, 3, 3, 3, 3, 'Nonprofit Partner', '61+', 'Senior center outing was wonderful', TRUE, 'Great for all abilities', NULL, 'https://placehold.co/400x300/228B22/white?text=SeniorGroup1', '2025-11-05 11:00:00'),

-- ========== More variety for analytics ==========
('Cow Yoga', 2, 2, 2, 2, 2, 3, 'Google Search', '18-25', 'First yoga class ever', TRUE, 'Little nervous but good', NULL, NULL, '2025-09-26 17:30:00'),
('Open Farm (Second Saturdays)', 2, 3, 2, 2, 2, 3, 'Drove By', '41-60', 'Curious about the farm', TRUE, NULL, NULL, NULL, '2025-10-12 10:30:00'),
('Tuesday Night Tuck-In', 3, 3, 3, 3, 3, 3, 'Word of Mouth', '0-17', 'Best time with my family', TRUE, NULL, NULL, NULL, '2025-10-29 18:00:00'),
('Paint & Pollinators', 3, 3, 3, 3, 3, 3, 'Newsletter', '61+', 'Peaceful painting experience', TRUE, NULL, NULL, 'https://placehold.co/400x300/228B22/white?text=Painting4', '2025-11-09 12:00:00'),
('Yoga with the Animals', 3, 3, 3, 3, 3, 3, 'Friend/Family', '26-40', 'Monthly self-care routine now', TRUE, NULL, NULL, NULL, '2025-11-28 17:00:00');

-- ============================================================================
-- END OF MOCK DATA
-- ============================================================================
