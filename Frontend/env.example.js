// ============================================================
// env.example.js — BeamWorks Environment Configuration Template
// Copy this file to env.js and fill in your real values.
// env.js is gitignored and should never be committed.
// ============================================================
// 1. Go to https://app.supabase.com → Your Project → Settings → API
// 2. Copy the Project URL and anon/public key
// 3. Go to Storage and note your bucket name
// 4. Paste them below and save as env.js
// ============================================================

window.__ENV = {
    SUPABASE_URL: 'YOUR_SUPABASE_PROJECT_URL',
    SUPABASE_ANON_KEY: 'YOUR_SUPABASE_ANON_PUBLIC_KEY',
    SUPABASE_STORAGE_BUCKET: 'YOUR_STORAGE_BUCKET_NAME',
    
    OWNER_WHATSAPP: 'YOUR_WHATSAPP_NUMBER_WITH_COUNTRY_CODE',
    CALLMEBOT_API_KEY: 'YOUR_CALLMEBOT_API_KEY'
};
