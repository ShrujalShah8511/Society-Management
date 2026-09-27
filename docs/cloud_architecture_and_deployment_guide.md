# Cloud Architecture & Production Deployment Runbook

## Architecture Topology
```
[ End Users (Mobile/Web) ]
         ↓
[ Cloudflare Edge ] — DNS/DDoS Shield · Universal SSL/TLS + HSTS · Pages (Global CDN)
         ├── Static Assets & WASM/CanvasKit
         ├── REST & Realtime APIs → [ Supabase ] — Auth (JWT) · PostgreSQL + RLS · Storage (society-assets)
         └── Push & Telemetry → [ Firebase ] — FCM (Web/Mobile) · Analytics
```

## 1. Cloudflare Pages Deployment

### Option A: Git-Integrated (Recommended)
1. Cloudflare Dashboard → **Compute > Workers & Pages > Create application > Pages > Connect to Git**.
2. Select repo: `ShrujalShah8511/Society-Management`.
3. Build settings:
   - **Framework preset**: None
   - **Build command**:
     ```bash
     flutter/bin/flutter build web --release \
       --dart-define=SUPABASE_URL="$SUPABASE_URL" \
       --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
       --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
       --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
       --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
       --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
       --dart-define=FIREBASE_VAPID_KEY="$FIREBASE_VAPID_KEY"
     ```
   - **Output directory**: `build/web`
4. Add Supabase + Firebase env vars → **Save and Deploy** → deploys to `*.pages.dev`.

**SPA Routing**: `web/_redirects` (deep links → `index.html` 200). **Security**: `web/_headers` (CSP, X-Frame-Options, X-Content-Type-Options, immutable cache for WASM/JS).

## 2. Supabase: PostgreSQL · Auth · Storage

### Setup
1. [supabase.com](https://supabase.com) → **New Project** → Name: `Society-Management` · Region: `ap-south-1` (Mumbai).
2. Copy from **Project Settings > API**: `Project URL` + `Anon Public Key`.

### Schema & Migrations
1. SQL Editor → paste `supabase/migrations/20260926000000_init_schema.sql` → **Run**.
   - Creates: `societies`, `users`, `towers`, `floors`, `flats`, `audit_logs`.
   - RLS for strict tenant isolation. Triggers: sync `auth.users` → `public.users` on signup.
2. SQL Editor → paste `supabase/seed.sql` → **Run** (loads Shyam Heights seed data).

### Storage
SQL Editor → run `supabase/storage_setup.sql` → creates public bucket **`society-assets`** with read/write RLS policies.

### Auth
Dashboard → **Authentication > Providers > Email** → Enable Email provider. Toggle **Confirm email** OFF for dev, ON for prod.

## 3. Firebase: Push Notifications & Analytics

### Project Setup
1. [Firebase Console](https://console.firebase.google.com/) → **Add project** → Name: `society-management-prod` → Enable Google Analytics.
2. Add Web app (`</>`) → Name: `Society Management Web` → copy: `apiKey`, `projectId`, `messagingSenderId`, `appId`.

### Web Push (FCM VAPID Key)
1. **Project Settings > Cloud Messaging > Web configuration > Web Push certificates** → **Generate key pair**.
2. Copy the VAPID key → replace placeholders in `web/firebase-messaging-sw.js`.

## 4. DNS & SSL (Cloudflare)

### Custom Domain
Dashboard → **Workers & Pages > society-management > Custom domains** → **Set up custom domain** → enter `society.yourdomain.com` → Cloudflare auto-generates CNAME → `*.pages.dev`.

### SSL/TLS
| Setting | Value |
|---|---|
| Encryption mode | Full (strict) |
| Always Use HTTPS | ON |
| HSTS Max-Age | 31536000 s (1 year) + include subdomains + preload |
| Min TLS Version | TLS 1.2 (or 1.3) |
| Opportunistic Encryption | ON |
| Automatic HTTPS Rewrites | ON |

## 5. Local Production Build
```powershell
flutter build web --release `
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="YOUR_ANON_KEY" `
  --dart-define=FIREBASE_API_KEY="YOUR_FIREBASE_API_KEY" `
  --dart-define=FIREBASE_PROJECT_ID="YOUR_PROJECT_ID" `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="YOUR_SENDER_ID" `
  --dart-define=FIREBASE_APP_ID="YOUR_APP_ID" `
  --dart-define=FIREBASE_VAPID_KEY="YOUR_VAPID_KEY"
```
Output: `build/web/` — ready for direct deployment.
