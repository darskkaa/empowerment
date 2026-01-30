# Empowerment Farm Digital Ecosystem 🌿

**Live Demo:** [https://empfarm.netlify.app/](https://empfarm.netlify.app/)  
**Admin:** [https://empfarm.netlify.app/dashboard.html](https://empfarm.netlify.app/dashboard.html)

A secure, mobile-optimized digital survey and analytics platform for Empowerment Farm. This application tracks therapeutic outcomes of farm-based activities without requiring diagnostic labels ("Labels Stop at the Gate").

---

## 🎯 Use Cases & Personas

### 1. The Walk-In Visitor (Anonymous)
- **Goal**: Quickly share feedback after an event (Cow Yoga, Open Farm) without creating an account.
- **Flow**: Scans QR code → Opens App → Selects Moods (Emoji-based) → Submits Photo → Done.
- **Key Features**: Offline capability (PWA), image compression, 30-second completion time.

### 2. The Farm Staff (Admin)
- **Goal**: Monitor program effectiveness and "Zen Factor" in real-time.
- **Flow**: Logs in via Magic Link → Views Dashboard → checks "Good Vibes" feed → Identifies popular programs.
- **Key Features**: Real-time charts, "Zen Factor" analysis, qualitative feedback feed.

### 3. The Grant Writer (Data Analyst)
- **Goal**: Prove community impact to secure funding.
- **Flow**: Exports data to CSV → Analyzes "High Fidelity" scores (1-5 scale) → Reports on demographics and outcome correlations.
- **Key Features**: CSV Export, rigorous data structure, connection metrics (Nature/Community/Self).

---

## 🌟 Key Features

### 📱 **PWA Survey App (`index.html`)**
- **Mobile-First Design**: Optimized for iPhone/Safari with safe areas and touch-friendly buttons.
- **"Apple-Tier" Aesthetics**: Glassmorphism, smooth animations, and premium UI.
- **Offline Capable**: "Add to Home Screen" functionality via `manifest.json`.
- **Smart Image Handling**: Client-side compression (<200KB) before upload to save bandwidth/storage.

### 📊 **Admin Dashboard (`dashboard.html`)**
- **Secure Login**: Magic Link authentication (Email-only, no passwords).
- **Deep Insights**:
  - **Zen Factor**: Correlates programs with calmness scores.
  - **Mission Match**: Visualizes alignment with core mission values.
  - **Growth Engine**: Tracks returning vs. new visitors.
- **Data Export**: One-click **Export to CSV**.

### 🔒 **Enterprise-Grade Security**
- **Row Level Security (RLS)**: Database policies strictly control access. `anon` users can ONLY insert.
- **Secure Proxy**: Netlify Functions (`get_config.js`) hide API keys from the public client.
- **PII Protection**: Names and emails are separated from survey data in the schema design.

---

## 🛠️ Setup Instructions

### 1. Database Setup (Supabase)
1. Create a new project at [database.new](https://database.new).
2. Go to **SQL Editor** and run the following scripts in order:
   - `schema.sql`: Creates tables, RLS policies, and views. (Nuclear option: drops existing tables).
   - `seed_data.sql`: Populates the DB with ~50 mock responses for testing.
3. Go to **Project Settings > API** to get your:
   - `Project URL` (e.g., `https://xyz.supabase.co`)
   - `anon public key` (starts with `eyJ...`)

### 2. Authentication Setup
1. Go to **Authentication > Providers** and ensure **Email** is enabled.
2. Go to **Authentication > Users** and "Invite" the admin email (e.g., your email) to access the dashboard.

### 3. Deploy to Netlify
1. Connect this repo to Netlify.
2. Go to **Site Settings > Environment Variables** and add **EXACTLY** these two:
   - `SUPABASE_URL`: Your Project URL
   - `ANON_KEY`: Your JWT `anon` key (starts with `eyJ...`)
   *Note: Do not use the `sb_publishable_` key format.*
3. Deploy! 🚀

---

## 📂 Project Structure

```text
/
├── index.html              # Main Survey App (Public, Mobile-First)
├── dashboard.html          # Admin Dashboard (Protected, Chart.js)
├── manifest.json           # PWA Configuration (Install to Home Screen)
├── logo.png                # App Icon
├── netlify.toml            # Netlify Build Config
│
├── netlify/
│   └── functions/
│       └── get_config.js   # Secure API Key Proxy (Hides credentials)
│
└── sql/                    # Database Scripts
    ├── schema.sql          # 🔥 MASTER SCHEMA (Run this to reset DB)
    ├── seed_data.sql       # Test data generator
    ├── queries.sql         # BI/Analytics queries for the dashboard
    ├── reset_surveys.sql   # Quick data wipe tool
    └── DATA_DICTIONARY.md  # Detailed column documentation
```

---

## 🛡️ Security Architecture

This project uses a **"Defense in Depth"** strategy:

1.  **Frontend**: The Dashboard is hidden behind an Email Magic Link login.
2.  **Middle Layer**: API keys are never hardcoded in the frontend source. They are fetched dynamically from secure Netlify Functions.
3.  **Database (RLS)**:
    *   **Implicit Deny**: All access is denied by default.
    *   **Public Access**: `anon` role can **only** `INSERT` into `surveyresponses`. They cannot `SELECT`, `UPDATE`, or `DELETE`.
    *   **Admin Access**: `authenticated` role can perform all actions.

---

## 🔧 Troubleshooting

**"New row violates Row Level Security policy" error:**
- **Cause**: The `anon` role lacks `INSERT` permission or the `GRANT` statement was missed.
- **Fix**: Run the latest `schema.sql` which includes:
  ```sql
  GRANT INSERT ON surveyresponses TO anon;
  ```

**401 Unauthorized Error:**
- **Cause**: Mismatched API keys or using the wrong key format (`sb_publishable_` vs `eyJ...`).
- **Fix**: Ensure Netlify `ANON_KEY` matches the **JWT** `anon` key from Supabase Dashboard.

---

**Built for Empowerment Farm** • *Labels stop at the gate.*