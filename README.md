# Digital Invitation Platform

Platform layanan pembuatan undangan digital berbasis website yang memungkinkan customer memilih template, melakukan pemesanan, mengirimkan data acara, dan memantau proses produksi hingga undangan dipublikasikan.

Platform menggunakan model layanan **hybrid**: customer mengirimkan kebutuhan dan materi undangan, sedangkan admin bertanggung jawab atas proses desain, konfigurasi, quality assurance, dan publikasi.

---

## 1. Project Overview

### Tujuan Project

Membangun platform pengelolaan jasa undangan digital yang mencakup:

- Website profil dan katalog layanan.
- Pemilihan template dan paket.
- Customer authentication dan dashboard.
- Order dan payment management.
- Pengumpulan data acara.
- Upload dan pengelolaan media.
- Admin dashboard.
- Invitation production management.
- Preview dan revision management.
- Public invitation.
- Guest management dan RSVP.

### Business Model

Platform ini bukan self-service invitation builder seperti Canva.

Proses bisnis utamanya:

```text
Customer
   |
   v
Select Template & Package
   |
   v
Create Order
   |
   v
Payment
   |
   v
Submit Event Data
   |
   v
Admin Production
   |
   v
Preview & Revision
   |
   v
Customer Approval
   |
   v
Publish Invitation
   |
   v
Guest Access & RSVP
```

---

## 2. Technology Stack

| Category | Technology |
|---|---|
| Framework | Next.js App Router |
| Language | TypeScript |
| Styling | Tailwind CSS |
| UI Components | shadcn/ui |
| Database | Supabase PostgreSQL |
| Authentication | Supabase Auth |
| File Storage | Supabase Storage |
| Validation | Zod |
| Form Management | React Hook Form |
| Payment Gateway | Midtrans / Xendit |
| Hosting | Vercel |
| DNS & CDN | Cloudflare |
| Monitoring | Sentry |
| Analytics | Vercel Analytics |
| Unit Testing | Vitest |
| E2E Testing | Playwright |
| Package Manager | pnpm |

---

## 3. System Architecture

Aplikasi menggunakan pendekatan **Modular Monolith**.

```text
                  Internet
                     |
                     v
              Cloudflare DNS
                     |
                     v
                  Vercel
                     |
               Next.js App
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
  Public Website  Customer      Admin
                  Portal       Dashboard
       |             |             |
       +-------------+-------------+
                     |
                     v
                Server Layer
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
   Supabase      Payment        External
   Database      Gateway        Services
   Auth/Storage  Webhooks       Maps/Email
```

### Application Areas

1. **Public Website** — informasi layanan, katalog, dan pricing.
2. **Customer Portal** — pemesanan dan pemantauan proses undangan.
3. **Admin Dashboard** — pengelolaan operasional dan produksi.
4. **Public Invitation Renderer** — halaman undangan yang dapat diakses tamu.

---

## 4. Documentation

Dokumentasi teknis project disimpan pada folder `docs/`.

| Document | Description |
|---|---|
| `system-doc.md` | Arsitektur sistem, modul, struktur aplikasi, dan keputusan teknis. |
| `database-schema.md` | Struktur database, relasi tabel, migration, index, dan RLS. |
| `user-flow.md` | Alur visitor, customer, admin, super admin, dan guest. |
| `api-documentation.md` | Kontrak API, endpoint, request, response, dan integrasi. |
| `security.md` | Authentication, authorization, RLS, Storage, dan keamanan aplikasi. |
| `deployment.md` | Setup environment, CI/CD, Supabase, Vercel, Cloudflare, dan deployment. |
| `development-roadmap.md` | Tahapan pengembangan, milestone, prioritas, dan testing strategy. |

---

## 5. Project Structure

Contoh struktur direktori yang direncanakan:

```text
digital-invitation/
│
├── docs/
│   ├── system-doc.md
│   ├── database-schema.md
│   ├── user-flow.md
│   ├── api-documentation.md
│   ├── security.md
│   ├── deployment.md
│   └── development-roadmap.md
│
├── public/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── src/
│   ├── app/
│   │   ├── (public)/
│   │   ├── (auth)/
│   │   ├── customer/
│   │   ├── admin/
│   │   ├── api/
│   │   └── [slug]/
│   │
│   ├── components/
│   │   ├── ui/
│   │   ├── layout/
│   │   └── shared/
│   │
│   ├── modules/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── categories/
│   │   ├── templates/
│   │   ├── packages/
│   │   ├── orders/
│   │   ├── payments/
│   │   ├── invitations/
│   │   ├── production/
│   │   ├── revisions/
│   │   ├── publication/
│   │   └── guests/
│   │
│   ├── lib/
│   │   ├── supabase/
│   │   ├── validations/
│   │   ├── constants/
│   │   ├── utils/
│   │   └── helpers/
│   │
│   ├── hooks/
│   ├── types/
│   └── config/
│
├── supabase/
│   ├── migrations/
│   ├── seed.sql
│   └── config.toml
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env.example
├── .gitignore
├── components.json
├── eslint.config.mjs
├── next.config.ts
├── package.json
├── pnpm-lock.yaml
├── tsconfig.json
└── README.md
```

Struktur di atas merupakan rancangan awal. Penyesuaian dapat dilakukan selama pemisahan tanggung jawab antarmodul tetap terjaga.

---

## 6. Prerequisites

Pastikan perangkat development memiliki:

- Node.js versi LTS yang kompatibel dengan versi Next.js yang digunakan.
- pnpm.
- Git.
- Akun Supabase.
- Akun Vercel.
- Akun Cloudflare.
- Code editor seperti Visual Studio Code.

Opsional:

- Docker untuk local development tertentu.
- Supabase CLI.
- Akun Midtrans atau Xendit.
- Akun Sentry.

Periksa instalasi:

```bash
node -v
pnpm -v
git --version
```

---

## 7. Installation

### 7.1. Clone Repository

```bash
git clone <repository-url>
cd <project-directory>
```

Ganti placeholder dengan URL repository dan nama direktori yang sebenarnya.

### 7.2. Install Dependencies

```bash
pnpm install
```

### 7.3. Setup Environment Variables

Buat file `.env.local` berdasarkan `.env.example`.

```bash
cp .env.example .env.local
```

Pada Windows PowerShell:

```powershell
Copy-Item .env.example .env.local
```

Isi environment variables sesuai project Supabase dan layanan eksternal yang digunakan.

### 7.4. Run Development Server

```bash
pnpm dev
```

Buka:

```text
http://localhost:3000
```

---

## 8. Environment Variables

Contoh `.env.example`:

```env
# Application
NEXT_PUBLIC_APP_URL=http://localhost:3000
NODE_ENV=development

# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Payment Gateway
PAYMENT_PROVIDER=
MIDTRANS_SERVER_KEY=
MIDTRANS_CLIENT_KEY=
XENDIT_SECRET_KEY=
XENDIT_WEBHOOK_TOKEN=

# Maps
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=

# Email
EMAIL_PROVIDER=
EMAIL_API_KEY=
EMAIL_FROM=

# Monitoring
SENTRY_DSN=
```

Catatan keamanan:

- Jangan commit `.env.local`.
- Jangan mengekspos `SUPABASE_SERVICE_ROLE_KEY` ke browser.
- Secret payment gateway hanya boleh digunakan di server.
- API key yang memang bersifat publik tetap harus dibatasi berdasarkan kebutuhan dan domain.
- Isi environment variable sesuai provider yang benar-benar dipilih. Jangan mengisi semua provider jika tidak digunakan.

---

## 9. Available Scripts

Contoh script yang disarankan dalam `package.json`:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test"
  }
}
```

Perintah utama:

| Command | Description |
|---|---|
| `pnpm dev` | Menjalankan development server. |
| `pnpm build` | Membuat production build. |
| `pnpm start` | Menjalankan production server lokal. |
| `pnpm lint` | Memeriksa kualitas kode. |
| `pnpm typecheck` | Memeriksa TypeScript. |
| `pnpm test` | Menjalankan unit test. |
| `pnpm test:watch` | Menjalankan test dalam watch mode. |
| `pnpm test:e2e` | Menjalankan end-to-end test. |

Script perlu disesuaikan dengan dependency dan konfigurasi aktual repository.

---

## 10. Database Setup

Database menggunakan Supabase PostgreSQL.

### 10.1. Initialize Supabase

```bash
pnpm dlx supabase init
```

Jika Supabase CLI sudah terpasang:

```bash
supabase init
```

### 10.2. Link Project

```bash
supabase login
supabase link --project-ref <project-ref>
```

### 10.3. Run Migrations

```bash
supabase db push
```

### 10.4. Generate TypeScript Types

```bash
supabase gen types typescript \
  --project-id <project-ref> \
  --schema public \
  > src/types/database.types.ts
```

### 10.5. Database Documentation

Referensi struktur database:

```text
docs/database-schema.md
```

Seluruh perubahan schema harus dikelola melalui migration agar perubahan dapat dilacak dan direproduksi.

---

## 11. Development Workflow

Gunakan branch strategy berikut:

| Branch | Purpose |
|---|---|
| `main` | Production |
| `develop` | Development integration |
| `feature/*` | Fitur baru |
| `fix/*` | Bug fixing |
| `hotfix/*` | Perbaikan production |

Contoh:

```bash
git switch develop
git pull origin develop

git switch -c feature/customer-dashboard
```

Setelah implementasi:

```bash
git add .
git commit -m "feat: implement customer dashboard"
git push -u origin feature/customer-dashboard
```

Buat Pull Request atau Merge Request menuju `develop`.

Sebelum melakukan merge, pastikan:

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

---

## 12. Coding Guidelines

### General

- Gunakan TypeScript.
- Hindari penggunaan `any` tanpa alasan kuat.
- Pisahkan business logic dari komponen UI.
- Gunakan Zod untuk validasi input.
- Validasi data penting di server.
- Gunakan reusable components.
- Gunakan naming convention yang konsisten.

### Database

- Semua perubahan schema melalui migration.
- Gunakan foreign key dan constraint.
- Buat index berdasarkan kebutuhan query.
- Terapkan RLS untuk tabel yang terekspos melalui Supabase API.
- Jangan mengandalkan validasi frontend untuk keamanan database.

### Authentication & Authorization

- Validasi session pada server.
- Jangan mempercayai role yang dikirim dari browser.
- Gunakan RBAC dan RLS.
- Lindungi seluruh halaman customer dan admin.

### Payment

- Harga dihitung di server.
- Verifikasi pembayaran melalui webhook atau verifikasi manual.
- Terapkan idempotency.
- Jangan menganggap redirect browser sebagai bukti pembayaran.

### Invitation

- Gunakan template version yang jelas.
- Simpan snapshot konten saat publikasi.
- Validasi slug.
- Lindungi data privat customer dan tamu.

---

## 13. Deployment

Deployment production menggunakan:

| Service | Purpose |
|---|---|
| Vercel | Next.js hosting |
| Supabase | Database, Auth, Storage |
| Cloudflare | DNS, CDN, SSL |
| Payment Provider | Transaksi pembayaran |
| Sentry | Error monitoring |

Lingkungan:

1. Development.
2. Staging.
3. Production.

Detail konfigurasi dan deployment:

```text
docs/deployment.md
```

---

## 14. Security

Keamanan merupakan bagian dari proses development, bukan pekerjaan tambahan setelah aplikasi selesai.

Checklist:

- [ ] Supabase RLS aktif.
- [ ] Role dan permission tervalidasi di server.
- [ ] Service role key tidak terekspos.
- [ ] Private Storage menggunakan signed URL.
- [ ] Upload file divalidasi.
- [ ] Webhook diverifikasi.
- [ ] Webhook idempotent.
- [ ] Input pengguna disanitasi sesuai konteks.
- [ ] Rate limiting diterapkan.
- [ ] Admin activity dicatat.
- [ ] Backup database tersedia.
- [ ] Dependency diperiksa secara berkala.

Dokumentasi lengkap:

```text
docs/security.md
```

---

## 15. Development Roadmap

Roadmap pengembangan dibagi menjadi beberapa milestone:

1. Project setup.
2. Database dan authentication.
3. Public website dan catalog.
4. Customer portal dan order management.
5. Payment management.
6. Invitation data collection.
7. Admin dashboard dan production.
8. Preview dan revision.
9. Publication dan renderer.
10. Guest management dan RSVP.
11. Testing dan production release.

Dokumentasi lengkap:

```text
docs/development-roadmap.md
```

---

## 16. Current Project Status

Status awal repository:

| Area | Status |
|---|---|
| System architecture | Documented |
| Database design | Documented |
| User flow | Documented |
| API contract | Documented |
| Security plan | Documented |
| Deployment plan | Documented |
| Development roadmap | Documented |
| Project scaffold | Not started |
| Database implementation | Not started |
| Application implementation | Not started |
| Production deployment | Not started |

Status harus diperbarui berdasarkan implementasi aktual, bukan hanya karena dokumentasi telah dibuat.

---

## 17. Important Notes

- Nama project dan domain belum ditentukan.
- Midtrans dan Xendit masih merupakan alternatif.
- MVP dapat dimulai dengan satu kategori dan beberapa template, meskipun arsitektur mendukung banyak kategori.
- Admin tetap menjadi pihak yang mengerjakan produksi desain dan publikasi.
- Dokumentasi API merupakan kontrak rancangan sampai endpoint benar-benar diimplementasikan.
- Database migration harus menjadi sumber perubahan schema.
- Perubahan besar pada arsitektur harus diperbarui di dokumentasi terkait.

---

## 18. License

Lisensi project belum ditentukan.

Tambahkan file `LICENSE` setelah keputusan mengenai kepemilikan dan distribusi source code dibuat.

---

**End of README**
