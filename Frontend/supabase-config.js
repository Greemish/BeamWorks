// ============================================================
// Supabase Configuration — BeamWorks
// Credentials are loaded from env.js (gitignored).
// Copy env.example.js → env.js and fill in your values.
// ============================================================

if (typeof window.__ENV === 'undefined' || !window.__ENV.SUPABASE_URL) {
    console.error('BeamWorks: env.js is missing or incomplete. Copy env.example.js to env.js and fill in your Supabase credentials.');
}

// Store credentials globally
window.SUPABASE_URL = (window.__ENV && window.__ENV.SUPABASE_URL) || '';
window.SUPABASE_ANON_KEY = (window.__ENV && window.__ENV.SUPABASE_ANON_KEY) || '';

console.log('[Supabase Config] URL:', window.SUPABASE_URL);
console.log('[Supabase Config] Key loaded:', window.SUPABASE_ANON_KEY ? 'yes' : 'NO — check env.js');

// Wait for Supabase library to load, then initialize the client
if (window.supabase && window.supabase.createClient) {
    window.supabase_client = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
    console.log('[Supabase Config] Client initialized');
} else {
    // Library not ready yet, try again after a short delay
    setTimeout(() => {
        if (window.supabase && window.supabase.createClient) {
            window.supabase_client = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
            console.log('[Supabase Config] Client initialized (delayed)');
        } else {
            console.error('[Supabase Config] Supabase library did not load properly');
        }
    }, 100);
}

// Create global reference for easy access
if (window.supabase_client) {
    window.supabase = window.supabase_client;
}

