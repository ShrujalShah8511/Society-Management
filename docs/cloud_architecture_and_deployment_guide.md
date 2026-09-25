# Cloud Architecture & Production Deployment Runbook

This guide provides end-to-end architecture instructions for hosting the **Society Management Application** across **Cloudflare Pages**, **Supabase PostgreSQL & Auth**, and **Firebase (Cloud Messaging & Analytics)**.

---

## Architecture Topology Overview

```text
[ End Users (Mobile / Web) ]
             │
             ▼
    [ Cloudflare Edge ]
    ├── DNS & DDoS Shield
    ├── Universal SSL / TLS (Full Strict) + HSTS
    └── Cloudflare Pages (Global CDN hosting build/web)
             │
             ├── Static Assets & WASM / CanvasKit
             │
             ├── Backend REST & Realtime APIs ──► [ Supabase Engine ]
             │                                    ├── Supabase Auth (JWT / Sessions)
             │                                    ├── Supabase PostgreSQL + RLS
             │                                    └── Supabase Storage (society-assets)
             │
             └── Push Notifications & Telemetry ──► [ Google Firebase ]
                                                  ├── Firebase Cloud Messaging (FCM Web/Mobile)
                                                  └── Firebase Analytics
```

---

## 1. Stop Localhost (Completed)
* The local debug web daemon on `http://0.0.0.0:8080` has been stopped.
* Port 8080 is released.

---

## 2. Website Hosting on Cloudflare Pages

### Option A: Automated Git-Integrated Deployment (Recommended)
1. Log into your [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. Navigate to **Compute (Workers) > Workers & Pages** and click **Create application > Pages > Connect to Git**.
3. Select your GitHub repository: `ShrujalShah8511/Society-Management`.
4. Configure Build Settings:
   * **Framework preset**: None
   * **Build command**:
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
   * **Build output directory**: `build/web`
5. Under **Environment variables**, supply your Supabase and Firebase keys (detailed below).
6. Click **Save and Deploy**. Cloudflare Pages will build and deploy your app to a global `*.pages.dev` URL.

### SPA Routing & Security Headers
* [`web/_redirects`](file:///c:/Users/shahs/.gemini/antigravity-ide/scratch/Projects/Society-Management/web/_redirects) ensures deep links resolve to `index.html` (200 status) for Flutter Web without 404s.
* [`web/_headers`](file:///c:/Users/shahs/.gemini/antigravity-ide/scratch/Projects/Society-Management/web/_headers) sets strict Content Security Policy, X-Frame-Options, X-Content-Type-Options, and immutable cache rules for static WASM/JS assets.

---

## 3, 4, 5, 6. Supabase: PostgreSQL, Auth, Storage & API

### 3.1 Create Supabase Project
1. Go to [Supabase](https://supabase.com/) and click **New Project**.
2. Set Project Name to `Society-Management` and pick a region close to your primary users (e.g. `ap-south-1` Mumbai).
3. Copy your project credentials from **Project Settings > API**:
   * **Project URL**: `https://<project-ref>.supabase.co`
   * **Anon Public Key**: `eyJhbGciOi...`

### 3.2 Apply Database Schema & Migrations
1. In the Supabase Dashboard, open the **SQL Editor**.
2. Open [`supabase/migrations/20260926000000_init_schema.sql`](file:///c:/Users/shahs/.gemini/antigravity-ide/scratch/Projects/Society-Management/supabase/migrations/20260926000000_init_schema.sql), copy the contents, paste into the SQL editor, and click **Run**.
   * Creates relational tables: `societies`, `users`, `towers`, `floors`, `flats`, `audit_logs`.
   * Enforces Row-Level Security (RLS) ensuring strict tenant isolation across societies.
   * Creates triggers to synchronize `auth.users` with `public.users` on signup.
3. Open [`supabase/seed.sql`](file:///c:/Users/shahs/.gemini/antigravity-ide/scratch/Projects/Society-Management/supabase/seed.sql), paste into the SQL Editor, and click **Run** to load Shyam Heights seed data.

### 3.3 Configure Storage Bucket
1. Open the SQL Editor and run [`supabase/storage_setup.sql`](file:///c:/Users/shahs/.gemini/antigravity-ide/scratch/Projects/Society-Management/supabase/storage_setup.sql).
2. This creates the public bucket **`society-assets`** with read/write access policies for society logos and documents.

### 3.4 Supabase Auth Setup
1. In Supabase Dashboard, navigate to **Authentication > Providers > Email**.
2. Ensure **Enable Email provider** is turned ON.
3. (Optional) For rapid onboarding, toggle **Confirm email** OFF for development testing, or leave ON for production.

---

## 7 & 8. Firebase: Push Notifications & Analytics

### 7.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/) and click **Add project**.
2. Name it `society-management-prod`.
3. Enable **Google Analytics for this project** (covers Requirement #8).

### 7.2 Register Web Application
1. Click the **Web (</>)** icon to add a web app.
2. Name it `Society Management Web`.
3. Copy the configuration object:
   * `apiKey`
   * `projectId`
   * `messagingSenderId`
   * `appId`

### 7.3 Web Push (FCM VAPID Key)
1. In Firebase Console, open **Project Settings > Cloud Messaging > Web configuration**.
2. Under **Web Push certificates**, click **Generate key pair**.
3. Copy the generated Key (this is your `FIREBASE_VAPID_KEY`).
4. Replace the placeholders in [`web/firebase-messaging-sw.js`](file:///c:/Users/shahs/.gemini/antigravity-ide/scratch/Projects/Society-Management/web/firebase-messaging-sw.js) with your Firebase config values.

---

## 9. DNS & SSL on Cloudflare

### 9.1 Custom Domain Mapping
1. In the **Cloudflare Dashboard**, navigate to **Compute (Workers) > Workers & Pages > society-management > Custom domains**.
2. Click **Set up a custom domain**.
3. Enter your domain or subdomain (e.g. `society.yourdomain.com`).
4. Cloudflare automatically generates the CNAME DNS record pointing to your `*.pages.dev` deployment.

### 9.2 SSL / TLS Encryption Mode
1. In Cloudflare Dashboard, open **SSL/TLS > Overview**.
2. Select **Full (strict)** encryption mode.
   * Ensures secure end-to-end HTTPS from client $\rightarrow$ Cloudflare Edge $\rightarrow$ origin.

### 9.3 Edge Certificates & HTTPS Enforcements
In **SSL/TLS > Edge Certificates**:
1. **Always Use HTTPS**: Turn **ON** (automatically redirects all `http://` requests to `https://`).
2. **HTTP Strict Transport Security (HSTS)**:
   * Click **Enable HSTS**.
   * Max-Age: `1 year (31536000 seconds)`.
   * Include subdomains: **Enabled**.
   * Preload: **Enabled**.
3. **Minimum TLS Version**: Set to **TLS 1.2** or **TLS 1.3**.
4. **Opportunistic Encryption**: Turn **ON**.
5. **Automatic HTTPS Rewrites**: Turn **ON**.

---

## 10. Local Production Build Command
To build and test a release bundle locally before pushing:
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
The output directory will be in `build/web/`, ready for direct deployment.
