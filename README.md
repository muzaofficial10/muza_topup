# Muza Top-Up

A production-ready Flutter app for selling **PUBG Mobile UC** and **eFootball Coins**, backed by Supabase (Postgres + Auth + Storage). Dark gaming UI with neon blue + gold accents.

---

## 1. What's included

```
muza_topup/
├── lib/
│   ├── core/            # theme, constants, Supabase client bootstrap
│   ├── models/           # OrderModel, PackageModel
│   ├── services/         # AuthService, OrderService, StorageService, ProductService
│   ├── screens/
│   │   ├── auth/          # login, signup
│   │   ├── home/          # home dashboard (hero, top-up entries, reviews, FAQ, support)
│   │   ├── topup/          # PUBG UC + eFootball Coins order forms
│   │   ├── orders/         # order history (real-time)
│   │   ├── support/        # FAQ
│   │   ├── legal/          # Terms, Privacy
│   │   └── admin/          # admin login, dashboard, orders, products, reports
│   └── widgets/           # reusable UI (buttons, package cards, status badges, uploader)
├── supabase/
│   └── schema.sql        # full Postgres schema + RLS policies + storage setup
├── pubspec.yaml
└── .env.example
```

## 2. Prerequisites

- Flutter SDK 3.3+ (`flutter --version`)
- A free [Supabase](https://supabase.com) project
- Xcode (iOS) / Android Studio (Android) for building

## 3. Supabase setup

1. Create a new project at supabase.com.
2. Open **SQL Editor** → paste the contents of `supabase/schema.sql` → **Run**.
   This creates all tables (`profiles`, `packages`, `orders`, `payments`, `announcements`),
   enables Row Level Security, creates the `payment-screenshots` private storage
   bucket, and seeds the default packages from the spec.
3. Go to **Project Settings → API** and copy your **Project URL** and **anon public key**.
4. Copy `.env.example` to `.env` and fill in those two values:
   ```
   SUPABASE_URL=https://xxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOi...
   ```
   `.env` is already listed under `flutter.assets` in `pubspec.yaml` so it ships with the app — **never commit your real `.env`** (add it to `.gitignore`).
5. **Enable Email auth**: Authentication → Providers → Email → enabled by default.
6. **Create your first admin**: sign up a normal user through the app, then in the SQL Editor run:
   ```sql
   update public.profiles set is_admin = true where email = 'you@example.com';
   ```
   That account can now log in via the **Admin Login** screen.

## 4. Run the app

```bash
flutter pub get
flutter run
```

Build release binaries:

```bash
# Android
flutter build apk --release
flutter build appbundle --release   # for Play Store

# iOS (on macOS with Xcode installed)
flutter build ios --release
```

## 5. Admin Dashboard

The admin dashboard is **built into the same Flutter app** (not a separate web project), gated behind:

- `/admin/login` — requires a Supabase account with `profiles.is_admin = true`
- Every admin screen also relies on **RLS policies** as the real security boundary — even if someone bypassed the UI gate, the database itself rejects reads/writes to admin-only data for non-admin accounts.

If you'd prefer a **separate web-based admin panel**, the same Flutter codebase compiles to web:

```bash
flutter build web --release
```
Deploy the `build/web` output (e.g. to Vercel, Netlify, or Supabase's own static hosting) as a standalone admin portal, or reuse the mobile app on desktop browsers.

## 6. Push notifications (optional)

`firebase_messaging` is included in `pubspec.yaml`. To enable:
1. Create a Firebase project, add Android/iOS apps, download `google-services.json` / `GoogleService-Info.plist`.
2. Run `flutterfire configure`.
3. Trigger notifications from a Supabase **Database Webhook** on `orders` status changes → a small Edge Function → Firebase Cloud Messaging.

This wiring is infrastructure-specific to your Firebase project, so it isn't pre-filled — the client-side listener plumbing is ready to receive messages once configured.

## 7. Important security notes

- **eFootball passwords are stored in plaintext** in `orders.efootball_password`, per the spec, and are restricted by RLS to the order's owner and admins only. For real-world production use, strongly consider:
  - Encrypting the column with [Supabase Vault](https://supabase.com/docs/guides/database/vault) or `pgsodium`, decrypting only in an admin-side Edge Function.
  - Purging the password automatically once an order reaches `completed` (a scheduled Postgres function / `pg_cron` job can null it out after N days).
- The **service_role key** must never be embedded in the Flutter app — only the anon key ships client-side. Admin-only actions are enforced by RLS, not by trusting the client.
- Payment screenshots are stored in a **private** bucket; the app requests short-lived signed URLs to display them, so links aren't durable/public.
- All user-supplied text (UID, email) should still be validated server-side if you later add Edge Functions — client-side validation alone is a UX aid, not a security boundary.

## 8. Where to customize

| What | Where |
|---|---|
| Packages & prices | `packages` table (edit live via Admin → Products) or `supabase/schema.sql` seed |
| Payment number / methods | `lib/core/constants.dart` → `AppConstants` |
| WhatsApp support number | `lib/core/constants.dart` → `whatsappNumber` / `whatsappCountryCode` |
| Colors / branding | `lib/core/theme.dart` → `AppColors` |
| FAQ content | `lib/core/constants.dart` → `AppConstants.faqs` |
| Terms / Privacy copy | `lib/screens/legal/*.dart` |

## 9. Suggested next steps for going fully live

- Add server-side webhook/Edge Function to auto-deliver UC/Coins via a reseller API once an order is marked `completed` (currently fulfillment after "Completed" is manual/admin-driven, matching the spec's manual-verification flow).
- Add rate limiting on order submission to prevent spam/abuse.
- Add a Somali/English language toggle if serving a bilingual user base (payment number formatting already assumes a Somalia-region WhatsApp number — adjust `whatsappCountryCode` if targeting other regions).
- Set up Supabase automated backups and enable Point-in-Time Recovery on the Postgres database.
