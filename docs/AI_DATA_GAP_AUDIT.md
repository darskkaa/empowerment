# Data Assistant – What’s in the DB vs What the AI Sees

The dashboard loads **only** `surveyresponses` (and `custom_questions` for the UI). The AI gets a **summarized** context from `prepareDataContext()` in `dashboard.html`. Below is what exists in the database but the AI does **not** have access to (or has only partial access).

---

## 1. Survey response columns the AI does NOT get (or gets only partly)

| Column | In DB | Sent to AI? | Gap |
|--------|-------|-------------|-----|
| **learning_intent_score** | ✅ 1–3 | ❌ No | No average, no breakdown. Cannot answer “How do people rate learning intent?” or compare by program. |
| **community_benefit_score** | ✅ 1–3 | ❌ No | Same as above for community benefit. |
| **mood_before_raw** / **mood_after_raw** | ✅ 1–5 | ❌ No | No “Did mood improve?” or before/after comparison. |
| **nature_connection_raw** | ✅ 1–5 | ❌ No | Raw nature connection scale not in context. |
| **skills_learned_score** | ✅ 0–100 | ❌ No | No average or trend for skills learned. |
| **device_type** | ✅ | ❌ No | Cannot answer “What devices do people use?”. |
| **Per-program mission scores** | ✅ | ❌ No | Only **overall** averages for present_engaged, connection, nature, calmness. No per-program averages, so the AI cannot say “Yoga has higher calmness than Open Farm” from numbers. |
| **impact_score** | View only | ❌ No | `vw_survey_with_programs` has impact_score = (present + connection + nature + calmness)/4. Dashboard reads the **table** `surveyresponses`, which has no impact_score column. Context uses calmness as a fallback, not the real composite. |
| **return_intent_pct** | Derived | ⚠️ From DOM | Context uses `document.getElementById('returnIntentScore')?.textContent` instead of recalculating from data; can be stale or wrong. |

---

## 2. Tables the dashboard never loads → AI has zero access

| Table | Contents | Example questions the AI cannot answer |
|-------|----------|--------------------------------------|
| **programcatalog** | program_name, description, schedule_notes, cost_notes, program_category | “When is Yoga?” “What does Group Program include?” “How much does it cost?” |
| **farmzones** | zone_name, zone_type, description | “What areas does the farm have?” “Where is the Yoga Pasture?” |
| **animals** | animal_name, species, breed, temperament, is_therapy_animal | “Which animals are there?” “Which are therapy animals?” |
| **experiences** | experience_date, start_time, facilitator_name, attendance_status, program_id, zone_id | “Who facilitated last Tuesday?” “How many no-shows this month?” “Attendance by program?” |
| **constituents** | first_name, last_name, email, role_type (Volunteer, Student, Visitor, Staff, Partner) | Any question about volunteers/students/staff (and correctly excluded for privacy). |
| **constituentprofiles** | date_of_birth, referral_source, notes | Same; privacy-sensitive. |
| **audit_log** | table_name, record_id, action, changed_at | “What was changed recently?” |

---

## 3. What the AI *does* get (for reference)

- **From surveyresponses (aggregated):** total_responses, program_counts, reviews_by_program (date, standout, additional, impact fallback), overall averages (present_engaged, connection_others_score, connection_nature_score, calmness_score), percent_recommending, percent_returning, counts (will_return_yes, returning_visitors, would_recommend_yes), demographics (age counts), referrals, donations, peak_times, monthly_trends, willing_to_review_pct, additional_feedback_samples, recent_feedback_samples_anonymous (with program tag).
- **Custom questions:** Per-question text, emoji, average score (1–3), response count. Not: distribution (e.g. how many 1 vs 2 vs 3) or per-program breakdown.

---

## 4. Recommended next steps (if you want the AI to use more data)

1. **Add to `prepareDataContext()` (no new API):**  
   - Averages for `learning_intent_score`, `community_benefit_score`, `skills_learned_score`.  
   - Optional: mood_before_raw / mood_after_raw averages (and count with both) so the AI can say “mood improved on average.”  
   - **Per-program averages** for the four main mission scores (and optionally learning_intent, community_benefit) so the AI can compare programs.  
   - Compute **return_intent_pct** from `allResponses` instead of reading from the DOM.

2. **Computed impact_score:**  
   - Either fetch from `vw_survey_with_programs` (e.g. in a separate call or when loading the table) and add `impact_score` to each row, then include it in `reviews_by_program` and/or a small summary, or  
   - Compute the same formula in the front end: (present_engaged + connection_others_score + connection_nature_score + calmness_score) / 4 per response and send averages or per-program averages.

3. **Reference data (read-only, no PII):**  
   - Load `programcatalog` (e.g. program_name, description, schedule_notes, cost_notes) once and add a short “program_info” object to context so the AI can answer “When is Yoga?” and “What programs do you offer?”.  
   - Optionally add `farmzones` and/or `animals` (names/species only) if you want the AI to describe the farm and who lives there.

4. **Do not expose to the AI:**  
   - constituents, constituentprofiles, audit_log, and any PII (participant_name, participant_email, etc.); these remain out of context by design.
