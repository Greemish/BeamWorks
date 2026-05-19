// ============================================================
// build-env.js — Generate env.js from environment variables
// Used during Vercel build process
// ============================================================

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const envContent = `// ============================================================
// env.js — BeamWorks Environment Configuration
// Auto-generated during build.
// This file is listed in .gitignore.
// ============================================================

window.__ENV = {
    SUPABASE_URL: '${process.env.SUPABASE_URL || ''}',
    SUPABASE_ANON_KEY: '${process.env.SUPABASE_ANON_KEY || ''}',
    SUPABASE_STORAGE_BUCKET: '${process.env.SUPABASE_STORAGE_BUCKET || ''}',
    
    OWNER_WHATSAPP: '${process.env.OWNER_WHATSAPP || ''}',
    CALLMEBOT_API_KEY: '${process.env.CALLMEBOT_API_KEY || ''}'
};
`;

const outputPath = path.join(__dirname, 'Frontend', 'env.js');

try {
  fs.writeFileSync(outputPath, envContent);
  console.log('✓ env.js generated successfully from environment variables');
  process.exit(0);
} catch (error) {
  console.error('✗ Error generating env.js:', error);
  process.exit(1);
}
