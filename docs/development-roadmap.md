# Development Roadmap

## 1. Overview

Dokumen ini menjelaskan roadmap pengembangan platform jasa pembuatan undangan digital.

Pengembangan dilakukan secara bertahap menggunakan pendekatan MVP (Minimum Viable Product). Fokus awal adalah membangun sistem yang dapat menjalankan proses bisnis utama:

1. Customer melihat katalog template dan paket.
2. Customer membuat pesanan.
3. Customer melakukan pembayaran.
4. Customer mengirim data dan media acara.
5. Admin memproses desain undangan.
6. Customer memeriksa preview dan meminta revisi.
7. Admin mempublikasikan undangan.
8. Tamu mengakses undangan dan mengirim RSVP.

### 1.1. Development Goals

Target MVP:

- Website profil dan katalog layanan.
- Authentication customer dan admin.
- Customer dashboard.
- Admin dashboard.
- Order management.
- Manual transfer dan payment gateway.
- Form pengumpulan data undangan.
- Media upload.
- Production management.
- Preview dan revision management.
- Public invitation renderer.
- RSVP dan guest management.
- Deployment production.

### 1.2. Development Approach

Gunakan pendekatan modular monolith.

Artinya, aplikasi dibangun sebagai satu project Next.js dengan modul-modul terpisah berdasarkan domain bisnis.

Keuntungannya:

- Lebih sederhana untuk dikelola.
- Tidak memerlukan banyak service terpisah.
- Mudah dikembangkan oleh tim kecil.
- Database dan authentication terintegrasi.
- Deployment lebih sederhana.

---

## 2. Technology Stack

| Area | Teknologi |
|---|---|
| Frontend | Next.js App Router |
| Language | TypeScript |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Database | Supabase PostgreSQL |
| Authentication | Supabase Auth |
| Storage | Supabase Storage |
| Validation | Zod |
| Form Management | React Hook Form |
| State Management | React state / Zustand jika diperlukan |
| Payment | Midtrans atau Xendit |
| Hosting | Vercel |
| DNS/CDN | Cloudflare |
| Monitoring | Sentry |
| Analytics | Vercel Analytics |
| Testing | Vitest dan Playwright |
| Package Manager | pnpm |

---

# 3. Development Phases

## Phase 0 — Project Preparation

<badge color="success">Foundation</badge>

Tujuan: mempersiapkan repository, struktur project, dan seluruh environment pengembangan.

### Tasks

- [ ] Membuat repository Git.
- [ ] Menentukan branch strategy.
- [ ] Membuat project Next.js.
- [ ] Mengaktifkan TypeScript.
- [ ] Mengatur Tailwind CSS.
- [ ] Mengintegrasikan shadcn/ui.
- [ ] Mengatur ESLint.
- [ ] Mengatur Prettier jika digunakan.
- [ ] Membuat struktur folder modular.
- [ ] Membuat `.env.example`.
- [ ] Menghubungkan Supabase development.
- [ ] Menyiapkan Vitest.
- [ ] Menyiapkan Playwright.
- [ ] Membuat CI pipeline awal.

### Deliverables

```text
Project initialized
Git repository ready
Development environment ready
Supabase connected
Basic CI pipeline ready
```

### Acceptance Criteria

- Project dapat dijalankan secara lokal.
- `pnpm dev` berhasil.
- `pnpm build` berhasil.
- TypeScript tidak menghasilkan error.
- Repository memiliki struktur yang jelas.
- Secret tidak tersimpan di repository.

---

## Phase 1 — Database & Authentication

<badge color="success">Critical</badge>

Tujuan: membangun fondasi database, autentikasi, dan hak akses pengguna.

### Tasks

**Database**

- [ ] Membuat schema database.
- [ ] Membuat migration awal.
- [ ] Membuat tabel `profiles`.
- [ ] Membuat tabel `categories`.
- [ ] Membuat tabel `templates`.
- [ ] Membuat tabel `template_versions`.
- [ ] Membuat tabel `packages`.
- [ ] Membuat tabel `package_features`.
- [ ] Membuat tabel `orders`.
- [ ] Membuat tabel `order_items`.
- [ ] Membuat tabel `payments`.
- [ ] Membuat tabel `payment_events`.
- [ ] Membuat tabel `invitation_contents`.
- [ ] Membuat tabel `media_assets`.
- [ ] Membuat tabel `revisions`.
- [ ] Membuat tabel `revision_messages`.
- [ ] Membuat tabel `invitation_publications`.
- [ ] Membuat tabel `guests`.
- [ ] Membuat tabel `rsvps`.
- [ ] Membuat tabel `order_status_history`.
- [ ] Membuat tabel `admin_activity_logs`.

**Authentication**

- [ ] Integrasi Supabase Auth.
- [ ] Register.
- [ ] Login.
- [ ] Logout.
- [ ] Email verification.
- [ ] Password reset.
- [ ] Session management.

**Authorization**

- [ ] Implementasi RBAC.
- [ ] Implementasi RLS.
- [ ] Customer ownership validation.
- [ ] Admin permission validation.
- [ ] Super Admin permission validation.

### Deliverables

- Database siap digunakan.
- Authentication berjalan.
- Role dan permission tersedia.
- RLS aktif dan sudah diuji.

### Acceptance Criteria

- Customer dapat register dan login.
- Customer tidak dapat mengakses data customer lain.
- Customer tidak dapat mengubah role.
- Halaman admin tidak dapat diakses customer.
- Migration dapat dijalankan pada database baru.

---

## Phase 2 — Public Website & Catalog

<badge color="success">High Priority</badge>

Tujuan: membangun halaman publik untuk memperkenalkan layanan dan mendapatkan customer.

### Tasks

**Landing Page**

- [ ] Hero section.
- [ ] Introduction layanan.
- [ ] Keunggulan layanan.
- [ ] Featured templates.
- [ ] Kategori undangan.
- [ ] Pricing preview.
- [ ] Testimonial jika tersedia.
- [ ] FAQ.
- [ ] Contact section.
- [ ] Footer.

**Catalog**

- [ ] Halaman kategori.
- [ ] Daftar template.
- [ ] Detail template.
- [ ] Demo template.
- [ ] Daftar paket.
- [ ] Perbandingan fitur paket.

**Other Pages**

- [ ] About.
- [ ] Services.
- [ ] Pricing.
- [ ] FAQ.
- [ ] Contact.

**Integration**

- [ ] Mengambil data kategori dari Supabase.
- [ ] Mengambil data template aktif.
- [ ] Mengambil data paket aktif.
- [ ] SEO metadata.
- [ ] Responsive design.

### Deliverables

Website publik yang dapat digunakan calon customer untuk mengenal layanan dan memilih template.

### Acceptance Criteria

- Semua halaman publik dapat diakses.
- Katalog menampilkan data dari database.
- Template memiliki detail dan demo.
- Paket menampilkan harga dan fitur.
- Website responsif pada desktop dan mobile.

---

## Phase 3 — Customer Portal & Order Management

<badge color="success">Critical</badge>

Tujuan: membangun proses pemesanan dari sisi customer.

### Tasks

**Customer Dashboard**

- [ ] Dashboard overview.
- [ ] Ringkasan pesanan.
- [ ] Status pembayaran.
- [ ] Aktivitas terbaru.
- [ ] Navigasi customer.

**Order Management**

- [ ] Memilih template.
- [ ] Memilih paket.
- [ ] Checkout.
- [ ] Membuat order number.
- [ ] Menyimpan order snapshot.
- [ ] Melihat daftar pesanan.
- [ ] Melihat detail pesanan.
- [ ] Pembatalan pesanan sesuai aturan.

**Profile**

- [ ] Melihat profil.
- [ ] Mengubah profil.
- [ ] Mengubah nomor telepon.
- [ ] Mengubah password melalui mekanisme Auth.

### Deliverables

Customer dapat melakukan pemesanan dan memantau status pesanan.

### Acceptance Criteria

- Customer dapat membuat pesanan.
- Harga dihitung oleh server.
- Snapshot harga dan paket tersimpan.
- Customer hanya dapat melihat pesanan miliknya.
- Status order ditampilkan dengan benar.

---

## Phase 4 — Payment Management

<badge color="success">Critical</badge>

Tujuan: membangun sistem pembayaran dan verifikasi transaksi.

### Tasks

**Manual Bank Transfer**

- [ ] Menampilkan instruksi pembayaran.
- [ ] Upload bukti transfer.
- [ ] Menampilkan status verifikasi.
- [ ] Admin melihat bukti transfer.
- [ ] Admin menyetujui pembayaran.
- [ ] Admin menolak pembayaran.
- [ ] Customer dapat mengunggah ulang bukti jika ditolak.

**Payment Gateway**

- [ ] Memilih provider.
- [ ] Integrasi API provider.
- [ ] Membuat transaksi.
- [ ] Menampilkan payment URL atau instruksi pembayaran.
- [ ] Membuat webhook handler.
- [ ] Verifikasi signature.
- [ ] Idempotency.
- [ ] Memperbarui status payment.
- [ ] Memperbarui status order.

**Admin Payment Dashboard**

- [ ] Daftar pembayaran.
- [ ] Filter status.
- [ ] Detail pembayaran.
- [ ] Verifikasi manual.
- [ ] Riwayat transaksi.

### Deliverables

Sistem pembayaran manual dan gateway berjalan.

### Acceptance Criteria

- Customer dapat memilih metode pembayaran.
- Bukti transfer disimpan secara privat.
- Admin dapat memverifikasi pembayaran.
- Webhook valid memperbarui status.
- Webhook duplikat tidak menghasilkan transaksi ganda.
- Redirect pembayaran tidak dianggap sebagai bukti pembayaran.

---

## Phase 5 — Invitation Data Collection & Media Upload

<badge color="success">Critical</badge>

Tujuan: menyediakan sarana bagi customer untuk mengirim informasi acara dan media yang dibutuhkan.

### Tasks

**Dynamic Invitation Forms**

- [ ] Menentukan struktur form per kategori.
- [ ] Form wedding.
- [ ] Form birthday.
- [ ] Form engagement.
- [ ] Form graduation.
- [ ] Form corporate.
- [ ] Menyimpan draft.
- [ ] Validasi field wajib.
- [ ] Submit data ke admin.

**Media Management**

- [ ] Setup Supabase Storage.
- [ ] Upload foto utama.
- [ ] Upload galeri.
- [ ] Upload asset pendukung.
- [ ] Validasi MIME type.
- [ ] Validasi ukuran file.
- [ ] Preview media.
- [ ] Hapus atau mengganti media sesuai aturan.
- [ ] Mengelola metadata file.

**Admin Data Review**

- [ ] Daftar submission.
- [ ] Melihat detail data.
- [ ] Menandai data belum lengkap.
- [ ] Mengirim catatan kepada customer.
- [ ] Menyetujui data.

### Deliverables

Customer dapat mengirim data acara dan media melalui dashboard.

### Acceptance Criteria

- Form menyesuaikan kategori undangan.
- Draft dapat disimpan.
- Validasi berjalan di client dan server.
- File tersimpan pada bucket yang benar.
- Admin dapat memeriksa data submission.

---

## Phase 6 — Admin Dashboard & Production Management

<badge color="success">Critical</badge>

Tujuan: membangun sistem operasional admin untuk memproses undangan.

### Tasks

**Admin Dashboard**

- [ ] Dashboard overview.
- [ ] Ringkasan pesanan.
- [ ] Pembayaran menunggu verifikasi.
- [ ] Data menunggu review.
- [ ] Produksi berjalan.
- [ ] Preview menunggu approval.
- [ ] Revisi aktif.
- [ ] Undangan telah dipublikasikan.

**Order Administration**

- [ ] Daftar seluruh order.
- [ ] Filter dan pencarian.
- [ ] Detail order.
- [ ] Riwayat status.
- [ ] Pengelolaan customer.

**Production**

- [ ] Antrean pekerjaan.
- [ ] Menetapkan template version.
- [ ] Mengelola konfigurasi undangan.
- [ ] Mengelola konten.
- [ ] Membuat preview.
- [ ] QA internal.
- [ ] Mengirim preview kepada customer.

**Template Management**

- [ ] Membuat template.
- [ ] Mengubah template.
- [ ] Mengelola kategori.
- [ ] Mengelola template version.
- [ ] Mengaktifkan dan menonaktifkan template.

### Deliverables

Admin dapat mengelola pesanan dan menyelesaikan proses produksi undangan.

### Acceptance Criteria

- Admin dapat memproses order yang sudah dibayar.
- Admin dapat melihat data customer sesuai kewenangan.
- Template version dapat dipilih.
- Preview dapat dihasilkan.
- QA dapat dicatat.
- Aktivitas admin masuk audit log.

---

## Phase 7 — Preview, Approval & Revision Management

<badge color="success">High Priority</badge>

Tujuan: menyediakan alur komunikasi dan persetujuan antara customer dan admin.

### Tasks

**Preview**

- [ ] Preview undangan.
- [ ] Akses preview terbatas.
- [ ] Preview desktop.
- [ ] Preview mobile.
- [ ] Status preview.

**Customer Approval**

- [ ] Melihat preview.
- [ ] Menyetujui hasil.
- [ ] Meminta revisi.
- [ ] Menyimpan waktu approval.
- [ ] Menampilkan riwayat approval.

**Revision**

- [ ] Membuat permintaan revisi.
- [ ] Menghitung jumlah revisi.
- [ ] Memeriksa batas paket.
- [ ] Mengelola biaya tambahan.
- [ ] Admin mengerjakan revisi.
- [ ] Admin mengirim hasil revisi.
- [ ] Customer memeriksa ulang.

### Deliverables

Customer dan admin dapat menyelesaikan proses review sampai desain disetujui.

### Acceptance Criteria

- Customer dapat mengakses preview secara aman.
- Approval tercatat.
- Revisi memiliki riwayat.
- Batas revisi sesuai snapshot paket.
- Revisi tidak dapat dilakukan tanpa status order yang sesuai.

---

## Phase 8 — Publication & Public Invitation Renderer

<badge color="success">Critical</badge>

Tujuan: membuat undangan yang telah disetujui dapat diakses secara publik.

### Tasks

**Publication Management**

- [ ] Membuat draft publication.
- [ ] Menentukan slug.
- [ ] Validasi slug.
- [ ] Memeriksa reserved route.
- [ ] Menyimpan content snapshot.
- [ ] Menyimpan template config snapshot.
- [ ] Mempublikasikan undangan.
- [ ] Unpublish undangan.
- [ ] Mengelola masa berlaku.

**Public Renderer**

- [ ] Resolusi slug.
- [ ] Mengambil publication aktif.
- [ ] Merender template.
- [ ] Menampilkan konten acara.
- [ ] Menampilkan galeri.
- [ ] Menampilkan lokasi.
- [ ] Menampilkan navigasi acara.
- [ ] Responsive design.
- [ ] SEO metadata.

**Performance**

- [ ] Optimasi gambar.
- [ ] Caching halaman publik.
- [ ] Optimasi font.
- [ ] Optimasi rendering.
- [ ] Monitoring performa.

### Deliverables

Undangan yang sudah disetujui dapat dipublikasikan menggunakan URL berbasis slug.

Contoh:

```text
https://your-domain.com/bergas-nadia
```

### Acceptance Criteria

- Slug unik.
- Draft tidak dapat diakses publik.
- Unpublished tidak dapat diakses publik.
- Template version tidak berubah secara tidak sengaja.
- Snapshot konten digunakan pada renderer.
- Undangan tampil baik pada perangkat mobile.

---

## Phase 9 — Guest Management & RSVP

<badge color="success">High Priority</badge>

Tujuan: memungkinkan customer dan admin mengelola daftar tamu serta menerima konfirmasi kehadiran.

### Tasks

**Guest Management**

- [ ] Menambahkan tamu.
- [ ] Mengubah data tamu.
- [ ] Menghapus atau menonaktifkan tamu.
- [ ] Mengelompokkan tamu.
- [ ] Menghasilkan guest token.
- [ ] Mengelola akses undangan personal.

**RSVP**

- [ ] Form RSVP publik.
- [ ] Status kehadiran.
- [ ] Jumlah tamu.
- [ ] Pesan atau ucapan.
- [ ] Validasi token.
- [ ] Pencegahan duplikasi.
- [ ] Rate limiting.

**RSVP Dashboard**

- [ ] Daftar RSVP.
- [ ] Filter status.
- [ ] Total hadir.
- [ ] Total tidak hadir.
- [ ] Total belum memberikan konfirmasi.
- [ ] Export data tamu jika diperlukan.

### Deliverables

Customer dan admin dapat melihat data tamu dan konfirmasi kehadiran.

### Acceptance Criteria

- RSVP hanya diterima untuk undangan valid.
- Data tamu tidak terekspos sembarangan.
- RSVP dapat dikelola.
- Rate limiting aktif.
- Ringkasan RSVP sesuai data database.

---

## Phase 10 — Notifications, Analytics & Finalization

<badge color="info">Enhancement</badge>

Tujuan: menyempurnakan pengalaman operasional dan mempersiapkan aplikasi untuk penggunaan lebih luas.

### Tasks

**Notifications**

- [ ] Order created.
- [ ] Payment confirmed.
- [ ] Payment rejected.
- [ ] Data submission received.
- [ ] Data incomplete.
- [ ] Production started.
- [ ] Preview ready.
- [ ] Revision requested.
- [ ] Revision completed.
- [ ] Invitation published.
- [ ] Invitation expiring.

**Analytics**

- [ ] Total order.
- [ ] Total revenue.
- [ ] Order by status.
- [ ] Template popularity.
- [ ] Package popularity.
- [ ] RSVP analytics.

**Finalization**

- [ ] Error monitoring.
- [ ] SEO.
- [ ] Performance optimization.
- [ ] Accessibility review.
- [ ] Security review.
- [ ] Backup configuration.
- [ ] Production deployment.
- [ ] User acceptance testing.

### Deliverables

Aplikasi siap digunakan dalam operasional bisnis.

---

# 4. MVP Scope

Fokus MVP adalah menyelesaikan proses bisnis dari pemesanan sampai publikasi undangan.

## 4.1. Must Have

| Fitur | Prioritas |
|---|---|
| Public website | Must Have |
| Template catalog | Must Have |
| Authentication | Must Have |
| Customer dashboard | Must Have |
| Admin dashboard | Must Have |
| Order management | Must Have |
| Manual bank transfer | Must Have |
| Payment gateway | Must Have |
| Invitation data form | Must Have |
| Media upload | Must Have |
| Production management | Must Have |
| Preview | Must Have |
| Revision | Must Have |
| Publication | Must Have |
| Public invitation renderer | Must Have |
| Basic RSVP | Must Have |
| RLS and RBAC | Must Have |

## 4.2. Should Have

- Email notifications.
- Guest management.
- RSVP analytics.
- Template version management.
- Admin activity logs.
- Export data.
- Advanced dashboard filtering.

## 4.3. Could Have

- WhatsApp automation.
- Advanced analytics.
- Custom music library.
- Invitation visitor analytics.
- Multiple languages.
- Advanced guest segmentation.
- Scheduled publication.
- Additional payment methods.

## 4.4. Won't Have for Initial MVP

- Drag-and-drop editor seperti Canva.
- Microservices architecture.
- Native mobile application.
- Multi-tenant SaaS builder.
- Custom domain untuk setiap customer.
- AI-powered invitation editor.
- Complex workflow automation.

Fitur tersebut dapat dipertimbangkan setelah sistem utama stabil.

---

# 5. Dependency Map

Urutan pengembangan harus memperhatikan ketergantungan antar-modul.

```text
Project Setup
     |
     v
Database & Authentication
     |
     +----------------------+
     |                      |
     v                      v
Public Catalog        Admin Foundation
     |                      |
     v                      |
Order Management <----------+
     |
     v
Payment Management
     |
     v
Invitation Data Collection
     |
     v
Media Upload
     |
     v
Production Management
     |
     v
Preview & Approval
     |
     v
Revision Management
     |
     v
Publication
     |
     v
Public Invitation Renderer
     |
     v
Guest & RSVP
     |
     v
Final QA & Production
```

Beberapa fase dapat dikerjakan secara paralel jika fondasi modul dan database sudah tersedia.

---

# 6. Testing Strategy

Pengujian dilakukan pada setiap fase, bukan hanya menjelang deployment.

## 6.1. Unit Testing

Gunakan Vitest untuk menguji:

- Price calculation.
- Order status transition.
- Payment status transition.
- Slug validation.
- Revision limit.
- RSVP validation.
- Permission helper.
- Content validation.

## 6.2. Integration Testing

Uji interaksi antar-modul:

- Authentication dan profile.
- Order dan payment.
- Payment dan order status.
- Invitation content dan media.
- Production dan preview.
- Revision dan approval.
- Publication dan renderer.
- Guest dan RSVP.

## 6.3. End-to-End Testing

Gunakan Playwright untuk menguji alur bisnis.

Contoh skenario:

**Scenario 1 — Customer Order**

1. Customer register.
2. Customer login.
3. Customer memilih template.
4. Customer memilih paket.
5. Customer checkout.
6. Order berhasil dibuat.

**Scenario 2 — Payment**

1. Customer membuka detail order.
2. Customer memilih metode pembayaran.
3. Customer melakukan pembayaran.
4. Sistem menerima webhook atau bukti transfer.
5. Admin memverifikasi pembayaran jika manual.
6. Status order diperbarui.

**Scenario 3 — Invitation Production**

1. Customer mengirim data.
2. Admin memeriksa data.
3. Admin memulai produksi.
4. Admin mengirim preview.
5. Customer menyetujui atau meminta revisi.
6. Admin menyelesaikan revisi.

**Scenario 4 — Publication**

1. Admin membuat publication.
2. Admin menentukan slug.
3. Admin mempublikasikan undangan.
4. Pengunjung membuka URL undangan.
5. Pengunjung mengirim RSVP.
6. Customer atau admin melihat hasil RSVP.

## 6.4. Security Testing

- [ ] Uji RLS.
- [ ] Uji customer ownership.
- [ ] Uji role escalation.
- [ ] Uji webhook signature.
- [ ] Uji webhook idempotency.
- [ ] Uji private Storage.
- [ ] Uji upload file berbahaya.
- [ ] Uji slug collision.
- [ ] Uji akses preview.
- [ ] Uji RSVP abuse.

---

# 7. Milestone & Timeline

Estimasi berikut merupakan target perencanaan, bukan janji durasi. Waktu aktual bergantung pada jumlah developer, kompleksitas desain, kesiapan template, dan proses integrasi.

| Milestone | Cakupan | Estimasi |
|---|---|---:|
| M1 | Project setup dan database | 1–2 minggu |
| M2 | Authentication dan public catalog | 1–2 minggu |
| M3 | Customer portal dan orders | 1–2 minggu |
| M4 | Payment dan data collection | 2–3 minggu |
| M5 | Admin dan production | 2–3 minggu |
| M6 | Preview, approval, dan revisions | 1–2 minggu |
| M7 | Publication, renderer, dan RSVP | 2–3 minggu |
| M8 | QA, security, dan deployment | 1–2 minggu |

Estimasi total: sekitar **11–19 minggu** untuk cakupan yang direncanakan.

Untuk tim kecil atau pengembangan individual, waktu dapat lebih panjang. Sebaiknya setiap milestone dinyatakan selesai berdasarkan acceptance criteria, bukan hanya jumlah minggu.

---

# 8. Development Workflow

Setiap fitur mengikuti alur berikut:

```text
Requirement
    |
    v
Technical Design
    |
    v
Database / Schema Review
    |
    v
Implementation
    |
    v
Unit Testing
    |
    v
Integration Testing
    |
    v
Code Review
    |
    v
Staging Deployment
    |
    v
QA
    |
    v
Production Release
```

### Definition of Done

Sebuah fitur dianggap selesai jika:

- Implementasi sesuai kebutuhan.
- TypeScript tidak menghasilkan error.
- Validasi server tersedia.
- Authorization tersedia.
- RLS telah diperiksa jika menyentuh database.
- Unit test tersedia untuk logika penting.
- Tidak ada error kritis.
- UI responsif.
- Dokumentasi diperbarui jika kontrak berubah.
- Build berhasil.

---

# 9. Project Management & Task Tracking

Gunakan GitHub Projects, GitLab Issues, atau tools sejenis.

Contoh label:

| Label | Fungsi |
|---|---|
| `feature` | Fitur baru |
| `bug` | Perbaikan masalah |
| `security` | Pekerjaan keamanan |
| `database` | Perubahan database |
| `frontend` | Pekerjaan frontend |
| `backend` | Pekerjaan server |
| `testing` | Pengujian |
| `documentation` | Dokumentasi |
| `priority-critical` | Prioritas kritis |
| `priority-high` | Prioritas tinggi |

Contoh task:

```text
[FEATURE] Implement Customer Authentication

Description:
Membuat sistem register, login, logout,
dan session management menggunakan Supabase Auth.

Acceptance Criteria:
- Customer dapat register.
- Customer dapat login.
- Customer dapat logout.
- Session dapat divalidasi di server.
- Halaman customer terlindungi.
- Unit dan integration test tersedia.
```

---

# 10. Post-MVP Roadmap

Setelah MVP digunakan dan alur bisnis stabil, pengembangan dapat dilanjutkan.

## Version 1.1 — Operational Improvement

- Notifikasi email.
- WhatsApp notification.
- Export RSVP.
- Dashboard analytics.
- Template duplication.
- Pengelolaan asset lebih lengkap.

## Version 1.2 — Customer Experience

- Guest invitation link.
- Personalized invitation.
- QR code.
- Advanced RSVP.
- Custom music.
- Visitor analytics.

## Version 1.3 — Business Expansion

- Multi-admin workflow.
- Admin assignment.
- Advanced revision management.
- Promo code.
- Referral system.
- More payment methods.
- Automated reminders.

## Version 2.0 — Advanced Platform

- Advanced template customization.
- Visual editor.
- Custom domain.
- Multi-language invitation.
- Advanced automation.
- AI-assisted content generation.

---

# 11. Final Development Priorities

Urutan fokus yang harus dipertahankan:

1. Fondasi project dan database.
2. Authentication, RBAC, dan RLS.
3. Katalog dan pemesanan.
4. Pembayaran.
5. Pengumpulan data undangan.
6. Dashboard admin dan produksi.
7. Preview dan revisi.
8. Publikasi dan renderer.
9. Guest dan RSVP.
10. Security testing, monitoring, dan deployment.

**Prinsip utama:** Jangan membangun fitur kompleks sebelum alur bisnis inti berhasil dijalankan dari awal sampai akhir. Prioritaskan sistem yang benar-benar dapat menerima pesanan, memproses pembayaran, menghasilkan undangan, dan mempublikasikannya.
