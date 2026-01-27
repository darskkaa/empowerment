# Empowerment Farm Digital Ecosystem 🌿

**Live Demo:** [https://empfarm.netlify.app/](https://empfarm.netlify.app/)  
**Admin:** [https://empfarm.netlify.app/dashboard.html](https://empfarm.netlify.app/dashboard.html)

A secure, mobile-optimized digital survey and analytics platform for Empowerment Farm.

## 🌟 Features

### 📱 **PWA Survey App (`index.html`)**
- **Mobile-First Design**: Optimized for iPhone/Safari with safe areas and touch-friendly buttons.
- **Offline Capable**: "Add to Home Screen" functionality via `manifest.json`.
- **Image Compression**: Automatically resizes user photos to <200KB before upload.
- **Secure**: Uses Netlify Functions to hide API keys.

### 📊 **Admin Dashboard (`dashboard.html`)**
- **Secure Login**: Magic Link authentication (Email-only, no passwords).
- **Real-Time Analytics**:
  - Net Promoter Score (NPS) & Satisfaction Donut Charts.
  - Interactive "Responses by Program" bar chart.
  - Recent response table with color-coded sentiment.
- **Data Export**: One-click **Export to CSV** for grant reporting.

### 🔒 **Enterprise-Grade Security**
- **Row Level Security (RLS)**: Database policies reduce attack surface.
- **PII Protection**: Names and emails are hidden from public view.
- **Audit Logging**: Immutable logs of all database changes.

---

## 🛠️ Setup Instructions

### 1. Database Setup (Supabase)
1. Create a new project at [database.new](https://database.new).
3. Go to **SQL Editor** and run:
   - `schema.sql` (Creates tables, views, and security policies)
3. Go to **Project Settings > API** to get your `URL` and `ANON_KEY`.

### 2. Authentication Setup
1. Go to **Authentication > Providers** and enable **Email**.
2. Go to **Authentication > Users** and "Invite" the admin email (e.g., Tiffany's email).

### 3. Deploy to Netlify
1. Connect this repo to Netlify.
2. Go to **Site Settings > Environment Variables** and add:
   - `SUPABASE_URL`: Your Supabase URL
   - `ANON_KEY`: Your Supabase Anon Key
3. Deploy! 🚀

---

## 📂 Project Structure

```text
/
├── index.html              # Main Survey App (Public)
├── dashboard.html          # Admin Dashboard (Protected)
├── manifest.json           # PWA Configuration
├── logo.png                # App Icon
├── netlify.toml            # Netlify Build Config
│
├── netlify/
│   └── functions/
│       └── get_config.js   # Secure API Key Proxy
│
└── sql/                    # Database Scripts
    ├── schema.sql          # Main Schema + Security (Run this first!)
    ├── seed_data.sql       # Optional: Sample data
    ├── queries.sql         # Helpful analytics queries
    └── DATA_DICTIONARY.md  # Documentation
```

## 🛡️ Security Details

This project uses a "Defense in Depth" strategy:
1. **Frontend**: The Dashboard is hidden behind an Email Magic Link login.
2. **Backend (API)**: API keys are never exposed to the client; they are fetched via secure serverless functions.
3. **Database (RLS)**: Even with a key, a hacker cannot read data.
   - `anon` role: Can ONLY insert new surveys.
   - `authenticated` role: Can read/edit data (Admin only).

---

**Built for Empowerment Farm** • *Labels stop at the gate.*