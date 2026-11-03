# Deployment Documentation

## 1. Overview

Dokumen ini menjelaskan strategi deployment dan infrastruktur untuk platform jasa pembuatan undangan digital.

Deployment dirancang menggunakan pendekatan managed infrastructure agar pengelolaan server lebih sederhana dan tim dapat berfokus pada pengembangan aplikasi.

### 1.1. Technology Stack

| Komponen | Teknologi | Fungsi |
|---|---|---|
| Frontend | Next.js App Router | Website dan dashboard |
| Programming Language | TypeScript | Pengembangan aplikasi |
| Styling | Tailwind CSS | Styling UI |
| UI Components | shadcn/ui | Komponen antarmuka |
| Database | Supabase PostgreSQL | Penyimpanan data |
| Authentication | Supabase Auth | Autentikasi |
| File Storage | Supabase Storage | Penyimpanan media |
| Application Hosting | Vercel | Hosting Next.js |
| DNS & CDN | Cloudflare | DNS, CDN, SSL, dan proteksi trafik |
| Payment | Midtrans / Xendit | Payment gateway |
| Monitoring | Sentry, Vercel Analytics | Monitoring aplikasi |

### 1.2. Deployment Architecture

```text
                     Users
                       |
                       v
                 Cloudflare DNS
                       |
                       v
                  Vercel CDN
                       |
                       v
                Next.js Application
                       |
          +------------+------------+
          |            |            |
          v            v            v
       Supabase     Payment      Monitoring
       Database     Gateway       Service
          |
          v
     Supabase Storage
```

Cloudflare digunakan untuk pengelolaan DNS dan fitur jaringan yang dibutuhkan. Vercel menangani hosting aplikasi Next.js.

---

## 2. Deployment Environments

Aplikasi menggunakan tiga environment.

| Environment | Tujuan | Branch |
|---|---|---|
| Development | Pengembangan lokal | `feature/*`, `develop` |
| Staging | Pengujian sebelum production | `develop` |
| Production | Aplikasi untuk customer | `main` |

### 2.1. Development

URL:

```text
http://localhost:3000
```

Karakteristik:

- Menjalankan aplikasi secara lokal.
- Menggunakan Supabase development.
- Menggunakan payment sandbox.
- Tidak menggunakan data customer production.
- Bebas melakukan perubahan schema selama migration tetap tercatat.

### 2.2. Staging

Contoh URL:

```text
https://staging.your-domain.com
```

Karakteristik:

- Digunakan untuk QA.
- Menguji integrasi payment gateway.
- Menguji authentication dan authorization.
- Menguji upload file.
- Menguji publikasi undangan.
- Menggunakan database terpisah dari production.

### 2.3. Production

Contoh URL:

```text
https://your-domain.com
```

Karakteristik:

- Digunakan oleh customer.
- Menggunakan database production.
- Menggunakan payment gateway production.
- Menggunakan secret production.
- Backup dan monitoring harus aktif.

**Penting:** Jangan menggunakan database production untuk pengujian lokal atau staging.

---

## 3. Repository & Git Strategy

Gunakan Git sebagai version control dan GitLab atau GitHub sebagai repository utama.

### 3.1. Branch Structure

```text
main
 |
 +---- develop
         |
         +---- feature/authentication
         |
         +---- feature/order-management
         |
         +---- feature/payment
         |
         +---- feature/invitation-renderer
         |
         +---- fix/payment-webhook
```

### 3.2. Branch Rules

| Branch | Fungsi |
|---|---|
| `main` | Kode production |
| `develop` | Integrasi fitur |
| `feature/*` | Pengembangan fitur |
| `fix/*` | Perbaikan bug |
| `hotfix/*` | Perbaikan production |

### 3.3. Development Workflow

1. Buat branch fitur dari `develop`.
2. Implementasikan fitur.
3. Jalankan lint dan test.
4. Jalankan build.
5. Push branch.
6. Buat Merge Request atau Pull Request.
7. Review perubahan.
8. Merge ke `develop`.
9. Deploy staging.
10. Setelah lolos QA, merge ke `main`.
11. Deploy production.

Contoh:

```bash
git switch develop
git pull origin develop

git switch -c feature/order-management

# Implementasi fitur

pnpm lint
pnpm test
pnpm build

git add .
git commit -m "feat: implement order management"
git push -u origin feature/order-management
```

---

## 4. Local Development Setup

### 4.1. Prerequisites

Perangkat yang diperlukan:

- Node.js versi LTS yang kompatibel dengan versi Next.js yang digunakan.
- pnpm.
- Git.
- Akun Supabase.
- Akun Vercel.
- Akun Cloudflare.
- IDE seperti Visual Studio Code.

### 4.2. Clone Repository

```bash
git clone <repository-url>

cd <project-directory>
```

### 4.3. Install Dependencies

```bash
pnpm install
```

### 4.4. Configure Environment

Buat file `.env.local`.

Contoh:

```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

SUPABASE_SERVICE_ROLE_KEY=

MIDTRANS_SERVER_KEY=
MIDTRANS_CLIENT_KEY=

SENTRY_DSN=
```

Gunakan credential development.

Jangan memasukkan secret production ke komputer development jika tidak diperlukan.

### 4.5. Run Development Server

```bash
pnpm dev
```

Aplikasi dapat diakses melalui:

```text
http://localhost:3000
```

### 4.6. Build Test

Sebelum melakukan push:

```bash
pnpm lint
pnpm test
pnpm build
```

Script yang belum tersedia harus ditambahkan pada `package.json` sesuai kebutuhan project.

---

## 5. Supabase Setup

### 5.1. Create Project

Buat project Supabase terpisah untuk:

- Development.
- Staging.
- Production.

Setiap project memiliki database, API key, dan Storage sendiri.

### 5.2. Database Migration

Gunakan Supabase CLI untuk mengelola schema database melalui migration.

Contoh struktur:

```text
supabase/
├── migrations/
│   ├── 202611030001_initial_schema.sql
│   ├── 202611030002_create_rls_policies.sql
│   └── 202611030003_create_storage_policies.sql
├── seed.sql
└── config.toml
```

Perintah dasar:

```bash
supabase init

supabase login

supabase link --project-ref <project-ref>

supabase migration list
```

Untuk menerapkan migration:

```bash
supabase db push
```

Jalankan perintah terhadap project yang benar. Sebelum migration production, lakukan pemeriksaan dan backup yang sesuai.

### 5.3. Storage Setup

Buat bucket:

```text
customer-uploads
payment-proofs
public-assets
template-assets
```

Konfigurasikan:

- Public/private access.
- File size limit.
- MIME type restrictions.
- Storage RLS policies.

Pastikan bucket `customer-uploads` dan `payment-proofs` bersifat private.

### 5.4. Authentication Setup

Konfigurasikan:

- Site URL.
- Redirect URLs.
- Email verification.
- Password reset redirect.
- Session settings.
- MFA untuk admin jika tersedia.

Contoh URL:

Development:

```text
http://localhost:3000
```

Staging:

```text
https://staging.your-domain.com
```

Production:

```text
https://your-domain.com
```

Redirect URL harus dibatasi pada domain yang memang digunakan.

---

## 6. Vercel Deployment

### 6.1. Connect Repository

1. Login ke Vercel.
2. Import repository Git.
3. Pilih repository aplikasi.
4. Pastikan framework Next.js terdeteksi.
5. Atur build command dan install command jika diperlukan.
6. Hubungkan environment variables.

### 6.2. Build Configuration

Konfigurasi dasar:

| Setting | Value |
|---|---|
| Framework | Next.js |
| Install Command | `pnpm install` |
| Build Command | `pnpm build` |
| Output Directory | Default Next.js |

Gunakan konfigurasi default kecuali ada kebutuhan khusus.

### 6.3. Environment Variables

Pisahkan environment variable berdasarkan target deployment.

| Variable | Development | Staging | Production |
|---|---|---|---|
| Supabase URL | Dev | Staging | Production |
| Supabase Anon Key | Dev | Staging | Production |
| Service Role Key | Dev | Staging | Production |
| Payment Secret | Sandbox | Sandbox | Live |
| Sentry DSN | Dev | Staging | Production |

Jangan menggunakan credential yang sama untuk seluruh environment.

### 6.4. Deployment Trigger

Contoh workflow:

| Event | Hasil |
|---|---|
| Push feature branch | Preview Deployment |
| Merge ke `develop` | Staging Deployment |
| Merge ke `main` | Production Deployment |

Pengaturan branch deployment perlu disesuaikan pada konfigurasi project Vercel.

---

## 7. Cloudflare Configuration

### 7.1. DNS Setup

Cloudflare digunakan sebagai pengelola DNS domain.

Contoh konfigurasi:

| Type | Name | Target |
|---|---|---|
| CNAME | `@` | Target domain Vercel |
| CNAME | `www` | Target domain Vercel |
| CNAME | `staging` | Target domain staging Vercel |

Nilai target sebenarnya harus mengikuti instruksi domain yang ditampilkan Vercel.

Jangan menyalin target contoh secara langsung tanpa memeriksa konfigurasi domain.

### 7.2. Domain Connection

Langkah:

1. Tambahkan domain ke Vercel.
2. Ikuti instruksi DNS yang diberikan Vercel.
3. Buat record DNS di Cloudflare.
4. Tunggu verifikasi domain.
5. Pastikan SSL/TLS aktif.
6. Uji domain utama dan subdomain.

### 7.3. SSL/TLS

Gunakan konfigurasi SSL/TLS yang sesuai dengan origin Vercel.

Pastikan:

- HTTPS aktif.
- HTTP diarahkan ke HTTPS.
- Sertifikat valid.
- Tidak ada mixed content.

### 7.4. CDN & Security

Fitur Cloudflare yang dapat dipertimbangkan:

- DNS.
- CDN.
- WAF sesuai paket.
- Rate limiting sesuai ketersediaan fitur.
- Bot protection.
- Security events monitoring.

Hindari mengaktifkan aturan cache agresif pada halaman dashboard, session, checkout, dan endpoint dinamis.

---

## 8. Payment Gateway Deployment

### 8.1. Sandbox Environment

Selama development dan staging, gunakan mode sandbox dari provider.

Contoh:

```text
Development -> Payment Sandbox
Staging     -> Payment Sandbox
Production  -> Payment Live
```

### 8.2. Webhook Configuration

Konfigurasikan URL webhook sesuai provider.

Contoh:

```text
https://your-domain.com/api/v1/webhooks/midtrans
```

Atau:

```text
https://your-domain.com/api/v1/webhooks/xendit
```

Pastikan:

- URL menggunakan HTTPS.
- Secret webhook tersimpan di server.
- Signature/token diverifikasi.
- Webhook event dicatat.
- Event duplikat tidak diproses ulang.
- Endpoint dapat menangani retry provider.

### 8.3. Production Checklist

Sebelum mengaktifkan pembayaran live:

- [ ] Credential live telah dipasang.
- [ ] Nominal transaksi tervalidasi.
- [ ] Signature verification berjalan.
- [ ] Idempotency sudah diuji.
- [ ] Status order dan payment konsisten.
- [ ] Refund workflow sudah ditentukan.
- [ ] Notifikasi pembayaran berfungsi.

---

## 9. CI/CD Pipeline

CI/CD digunakan untuk mengotomatisasi pemeriksaan kode dan deployment.

### 9.1. Pipeline Stages

```text
Developer Push
      |
      v
Install Dependencies
      |
      v
Lint & Type Check
      |
      v
Unit Tests
      |
      v
Build Application
      |
      v
Merge Request Review
      |
      v
Deploy Staging
      |
      v
QA & Acceptance Test
      |
      v
Merge to Main
      |
      v
Deploy Production
      |
      v
Post-deployment Verification
```

### 9.2. Recommended Scripts

Contoh `package.json`:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run"
  }
}
```

Sesuaikan script dengan versi Next.js, ESLint, dan test framework yang benar-benar digunakan.

### 9.3. Example GitHub Actions

Jika repository menggunakan GitHub, pipeline dasar dapat dibuat seperti berikut.

```yaml
name: CI

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop, main]

jobs:
  quality-check:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - name: Setup pnpm
        uses: pnpm/action-setup@v4
        with:
          version: 10

      - name: Install
        run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm lint

      - name: Type Check
        run: pnpm typecheck

      - name: Test
        run: pnpm test

      - name: Build
        run: pnpm build
```

Contoh ini merupakan template awal. Versi Node.js, pnpm, dan action harus disesuaikan dengan versi yang digunakan project. Pastikan seluruh environment variable yang dibutuhkan build tersedia sebagai CI secrets.

Untuk repository GitLab, gunakan `.gitlab-ci.yml` dengan tahapan pemeriksaan yang setara.

### 9.4. Deployment Responsibility

Untuk rancangan awal, deployment aplikasi dapat ditangani langsung oleh integrasi Git Vercel.

CI pipeline bertugas melakukan quality checks, sedangkan Vercel menangani deployment berdasarkan branch.

Dengan demikian, tidak perlu membuat proses deployment custom sebelum ada kebutuhan khusus.

---

## 10. Database Migration Deployment

Migration database harus diperlakukan sebagai bagian dari release aplikasi.

### 10.1. Migration Rules

- Semua perubahan schema harus masuk folder migration.
- Jangan mengubah schema production secara manual tanpa migration.
- Migration harus diuji pada development.
- Migration harus diterapkan ke staging terlebih dahulu.
- Perubahan yang berisiko harus memiliki rencana rollback atau forward-fix.
- Perubahan yang menghapus data harus mendapatkan pemeriksaan tambahan.

### 10.2. Safe Migration Strategy

Untuk perubahan besar:

1. Tambahkan kolom atau tabel baru.
2. Deploy aplikasi yang mendukung struktur baru.
3. Migrasikan data jika diperlukan.
4. Pastikan aplikasi berjalan normal.
5. Hapus struktur lama pada release berikutnya setelah tidak digunakan.

Strategi bertahap mengurangi risiko aplikasi tidak kompatibel dengan database selama deployment.

### 10.3. Migration Rollback

Tidak semua migration aman untuk di-rollback secara otomatis.

Untuk migration yang menghapus kolom atau mengubah struktur data, siapkan backup dan rencana pemulihan sebelum deployment.

Jangan mengandalkan rollback aplikasi saja jika schema database sudah berubah secara tidak kompatibel.

---

## 11. Domain & Routing

### 11.1. Public Website

```text
/
 /about
 /services
 /templates
 /pricing
 /faq
 /contact
```

### 11.2. Customer Portal

```text
/customer/dashboard
/customer/orders
/customer/profile
/customer/settings
```

### 11.3. Admin Dashboard

```text
/admin/dashboard
/admin/orders
/admin/production
/admin/templates
/admin/payments
/admin/settings
```

### 11.4. Public Invitation

```text
/{slug}
```

Contoh:

```text
/bergas-nadia
```

Pastikan route publik tidak mengambil alih reserved routes seperti:

```text
/admin
/customer
/api
/templates
/pricing
/login
/register
```

### 11.5. Preview Route

Preview internal harus menggunakan mekanisme akses terbatas dan tidak dapat dianggap sebagai publikasi.

Contoh:

```text
/preview/{previewId}
```

---

## 12. Post-deployment Verification

Setelah deployment selesai, lakukan pemeriksaan.

### 12.1. Application Health

- [ ] Landing page dapat diakses.
- [ ] Halaman katalog dapat dibuka.
- [ ] Customer login berfungsi.
- [ ] Customer dashboard dapat diakses.
- [ ] Admin dashboard terlindungi.
- [ ] Public invitation renderer berjalan.
- [ ] Tidak ada error build atau runtime kritis.

### 12.2. Database & Storage

- [ ] Database production terhubung.
- [ ] Migration berhasil diterapkan.
- [ ] RLS aktif.
- [ ] Storage dapat digunakan.
- [ ] Private bucket tidak dapat diakses publik.
- [ ] Upload dan download berjalan sesuai hak akses.

### 12.3. Payment

- [ ] Pembuatan transaksi berhasil.
- [ ] Webhook diterima.
- [ ] Signature validasi berjalan.
- [ ] Status pembayaran diperbarui.
- [ ] Webhook duplikat ditangani.

### 12.4. Domain & Network

- [ ] Domain utama aktif.
- [ ] HTTPS valid.
- [ ] Redirect HTTPS berjalan.
- [ ] Subdomain staging aktif.
- [ ] DNS sesuai konfigurasi.
- [ ] Tidak ada masalah mixed content.

### 12.5. Monitoring

- [ ] Error monitoring aktif.
- [ ] Log deployment dapat diperiksa.
- [ ] Vercel Analytics aktif jika digunakan.
- [ ] Supabase monitoring diperiksa.
- [ ] Alert untuk error penting dikonfigurasikan.

---

## 13. Rollback Strategy

Rollback diperlukan jika deployment menyebabkan gangguan production.

### 13.1. Application Rollback

Jika deployment aplikasi bermasalah:

1. Identifikasi deployment terakhir yang sehat.
2. Periksa perubahan yang menyebabkan masalah.
3. Gunakan fitur rollback atau redeploy deployment sebelumnya di Vercel.
4. Verifikasi aplikasi.
5. Catat insiden dan penyebabnya.

### 13.2. Database Rollback

Database rollback harus dilakukan dengan hati-hati.

- Jangan menghapus data hanya untuk menyesuaikan aplikasi lama.
- Periksa kompatibilitas schema.
- Pulihkan backup jika diperlukan.
- Gunakan forward-fix jika rollback berisiko.
- Catat seluruh tindakan pemulihan.

### 13.3. Incident Procedure

```text
Incident Detected
       |
       v
Assess Impact
       |
       v
Stop Further Deployment
       |
       v
Identify Root Cause
       |
       v
Rollback or Forward Fix
       |
       v
Verify Application
       |
       v
Document Incident
```

---

## 14. Backup & Disaster Recovery

### 14.1. Database

Gunakan backup Supabase sesuai paket dan kebutuhannya.

Pastikan:

- Jadwal backup diketahui.
- Retensi backup diketahui.
- Akses backup dibatasi.
- Prosedur restore terdokumentasi.
- Restore diuji secara berkala.

### 14.2. Storage

Buat strategi backup terpisah untuk file Storage.

Backup harus mencakup:

- Foto customer.
- Asset undangan.
- Template asset.
- Bukti pembayaran sesuai kebijakan retensi.

### 14.3. Recovery Documentation

Dokumentasikan:

- Project reference Supabase.
- Domain dan DNS.
- Environment variables.
- Credential provider yang tersimpan aman.
- Repository.
- Prosedur deploy.
- Prosedur restore database.
- Prosedur restore storage.

Jangan menyimpan secret secara langsung di dokumentasi repository.

---

## 15. Cost & Infrastructure Considerations

Biaya infrastruktur bergantung pada paket layanan, trafik, kapasitas database, storage, dan jumlah deployment.

Komponen yang perlu dipantau:

| Komponen | Faktor biaya |
|---|---|
| Vercel | Hosting, bandwidth, fungsi, dan penggunaan |
| Supabase | Database, storage, bandwidth, dan fitur paket |
| Cloudflare | Paket dan fitur tambahan yang digunakan |
| Payment Gateway | Biaya transaksi provider |
| Monitoring | Volume event dan retensi |
| Domain | Biaya registrasi dan perpanjangan |
| Email/WhatsApp | Volume pengiriman dan provider |

Untuk MVP, gunakan paket yang sesuai kebutuhan aktual dan pantau pemakaian sebelum meningkatkan kapasitas.

Jangan mengasumsikan semua layanan selalu tersedia gratis atau memiliki batas penggunaan yang tetap.

---

## 16. Deployment Checklist

### Initial Setup

- [ ] Repository dibuat.
- [ ] Branch strategy ditentukan.
- [ ] Project Supabase development dibuat.
- [ ] Project Supabase staging dibuat.
- [ ] Project Supabase production dibuat.
- [ ] Project Vercel dibuat.
- [ ] Domain ditambahkan.
- [ ] Cloudflare DNS dikonfigurasikan.

### Development

- [ ] Environment variables tersedia.
- [ ] Migration database berjalan.
- [ ] Storage bucket tersedia.
- [ ] Authentication dikonfigurasikan.
- [ ] RLS telah diuji.
- [ ] Build lokal berhasil.
- [ ] Automated test berjalan.

### Staging

- [ ] Deployment staging berhasil.
- [ ] Login dan register diuji.
- [ ] Order flow diuji.
- [ ] Manual payment diuji.
- [ ] Gateway sandbox diuji.
- [ ] Upload media diuji.
- [ ] Preview dan revision diuji.
- [ ] Publication dan RSVP diuji.

### Production

- [ ] Environment production diverifikasi.
- [ ] Payment live dikonfigurasikan.
- [ ] Webhook production dikonfigurasikan.
- [ ] Domain dan HTTPS aktif.
- [ ] Backup tersedia.
- [ ] Monitoring aktif.
- [ ] RLS dan authorization diuji.
- [ ] Smoke test selesai.

---

## 17. Deployment Principles

Prinsip yang harus dipertahankan:

1. Development, staging, dan production harus terpisah.
2. Seluruh perubahan kode menggunakan Git.
3. Production deployment harus melalui pemeriksaan.
4. Database schema dikelola menggunakan migration.
5. Secret tidak boleh masuk repository.
6. Payment sandbox dan production harus terpisah.
7. Backup harus tersedia sebelum perubahan database berisiko.
8. Setiap deployment harus diverifikasi.
9. Rollback harus memiliki prosedur yang terdokumentasi.
10. Monitoring harus aktif setelah aplikasi digunakan customer.

Dokumen ini menjadi acuan operasional deployment dan pengelolaan infrastruktur aplikasi dari tahap development hingga production.
