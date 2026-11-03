# Security Documentation

## 1. Overview

Dokumen ini menjelaskan standar keamanan untuk platform jasa pembuatan undangan digital.

Sistem harus melindungi:

- Data pribadi customer.
- Informasi pesanan dan transaksi.
- Bukti pembayaran.
- Foto dan media yang diunggah customer.
- Data tamu dan RSVP.
- Akun Admin dan Super Admin.
- Konten undangan sebelum dipublikasikan.
- Infrastruktur dan layanan pihak ketiga.

Keamanan diterapkan pada seluruh lapisan aplikasi, mulai dari frontend, server, database, storage, hingga integrasi eksternal.

## 2. Security Architecture

### 2.1. Security Layers

Arsitektur keamanan dibagi menjadi beberapa lapisan.

| Layer | Teknologi | Tanggung jawab |
|---|---|---|
| Frontend | Next.js | Proteksi tampilan dan validasi awal |
| Application | Server Actions, Route Handlers | Authentication, authorization, validasi |
| Authentication | Supabase Auth | Identitas dan session |
| Database | Supabase PostgreSQL | RLS, constraint, transaksi |
| Storage | Supabase Storage | Proteksi file dan akses media |
| Network | Cloudflare | DNS, CDN, proteksi trafik |
| Deployment | Vercel | Environment dan deployment |
| Monitoring | Sentry | Error dan exception monitoring |

Frontend bukan lapisan keamanan utama. Seluruh validasi dan pemeriksaan hak akses wajib dilakukan di server.

### 2.2. Security Principles

Prinsip keamanan yang digunakan:

1. Least Privilege: pengguna hanya memperoleh akses minimum yang dibutuhkan.
2. Defense in Depth: keamanan diterapkan di beberapa lapisan.
3. Server-side Validation: input selalu divalidasi di server.
4. Secure by Default: data bersifat privat kecuali memang harus dipublikasikan.
5. Zero Trust: setiap request harus divalidasi, meskipun berasal dari aplikasi sendiri.
6. Auditability: aktivitas penting harus dapat ditelusuri.
7. Fail Secure: jika validasi gagal, akses harus ditolak.

---

## 3. Authentication Security

### 3.1. Authentication Provider

Menggunakan Supabase Auth sebagai sistem autentikasi utama.

Fitur:

- Email dan password.
- Email verification.
- Password reset.
- Session management.
- Logout.
- Proteksi session kedaluwarsa.

### 3.2. Password Policy

Rekomendasi kebijakan password:

- Minimal 12 karakter.
- Mendukung kombinasi huruf, angka, dan simbol.
- Menolak password yang umum atau mudah ditebak jika mekanisme pemeriksaan tersedia.
- Tidak menyimpan password secara manual di database aplikasi.
- Tidak mencatat password ke log.
- Tidak mengirim password melalui email atau pesan.

Penyimpanan dan hashing password ditangani Supabase Auth.

### 3.3. Session Security

Untuk aplikasi Next.js:

- Gunakan integrasi Supabase SSR.
- Simpan session melalui mekanisme cookie yang aman.
- Aktifkan atribut `HttpOnly`, `Secure`, dan `SameSite` sesuai konfigurasi autentikasi.
- Validasi session di server.
- Jangan mengandalkan data user dari client state sebagai bukti autentikasi.
- Logout harus mengakhiri session.
- Halaman sensitif harus memeriksa session terbaru.

### 3.4. Admin Authentication

Akun admin memiliki akses lebih besar sehingga membutuhkan perlindungan tambahan.

Rekomendasi:

- Wajib menggunakan email terverifikasi.
- Aktifkan MFA jika tersedia.
- Gunakan password yang kuat dan unik.
- Batasi pembuatan akun admin.
- Audit aktivitas admin.
- Nonaktifkan akun yang tidak lagi digunakan.

Super Admin menjadi satu-satunya role yang dapat mengelola role pengguna admin.

---

## 4. Role-Based Access Control (RBAC)

### 4.1. Role Definition

| Role | Access |
|---|---|
| Visitor | Halaman publik dan katalog |
| Customer | Data pesanan dan undangan miliknya |
| Admin | Operasional pesanan dan produksi |
| Super Admin | Seluruh fungsi administrasi |
| Guest | Undangan publik dan RSVP yang diizinkan |

### 4.2. Permission Matrix

| Fitur | Visitor | Customer | Admin | Super Admin | Guest |
|---|---:|---:|---:|---:|---:|
| Melihat katalog | Ya | Ya | Ya | Ya | Ya |
| Membuat pesanan | Tidak | Ya | Ya* | Ya* | Tidak |
| Melihat pesanan sendiri | Tidak | Ya | Ya* | Ya* | Tidak |
| Mengelola pembayaran | Tidak | Terbatas | Ya | Ya | Tidak |
| Mengelola template | Tidak | Tidak | Ya | Ya | Tidak |
| Mengelola produksi | Tidak | Tidak | Ya | Ya | Tidak |
| Mempublikasikan undangan | Tidak | Tidak | Ya | Ya | Tidak |
| Mengelola akun admin | Tidak | Tidak | Tidak | Ya | Tidak |
| Melihat undangan publik | Ya | Ya | Ya | Ya | Ya |
| Mengirim RSVP | Tidak | Tidak | Tidak | Tidak | Ya** |

Keterangan:

- `*` Admin dapat melakukan operasi atas nama customer hanya jika memang diperlukan dan tercatat.
- `**` RSVP harus melewati validasi undangan dan aturan token atau guest record.

### 4.3. Role Storage

Role disimpan pada tabel `profiles`.

Contoh:

```text
profiles
├── id
├── full_name
├── email
├── role
└── is_active
```

Nilai role:

```text
visitor
customer
admin
super_admin
```

Visitor dan Guest tidak harus memiliki record role pada tabel `profiles`, karena keduanya dapat diidentifikasi berdasarkan konteks akses.

### 4.4. Preventing Role Escalation

Customer tidak boleh dapat mengubah role miliknya melalui update profil.

Contoh request yang harus ditolak:

```json
{
  "full_name": "Customer",
  "role": "super_admin"
}
```

Implementasi:

- Batasi kolom yang dapat diubah customer.
- Buat RLS policy yang tidak mengizinkan perubahan kolom role.
- Lakukan perubahan role hanya melalui operasi server khusus.
- Catat perubahan role pada audit log.

Jangan menggunakan nilai role yang dikirim oleh browser sebagai dasar pemberian akses.

---

## 5. Supabase Row Level Security (RLS)

RLS merupakan salah satu komponen keamanan paling penting dalam sistem.

RLS harus aktif pada seluruh tabel yang berisi data customer, transaksi, produksi, dan data operasional.

### 5.1. General Policy

Prinsip kebijakan:

- Customer hanya dapat mengakses pesanan miliknya.
- Customer tidak dapat membaca data customer lain.
- Customer tidak dapat mengubah status pembayaran.
- Guest tidak memperoleh akses langsung ke tabel internal.
- Admin hanya dapat mengakses data sesuai kewenangan.
- Operasi publik dibatasi pada data yang memang boleh dipublikasikan.

### 5.2. Example: Orders Policy

Customer hanya dapat melihat pesanan miliknya.

```sql
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customer can view own orders"
ON public.orders
FOR SELECT
TO authenticated
USING (
  customer_id = auth.uid()
);
```

### 5.3. Example: Profiles Policy

```sql
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  id = auth.uid()
);
```

Update profil harus dibatasi agar customer hanya dapat mengubah kolom yang diizinkan. RLS saja tidak cukup untuk membatasi kolom secara granular; gunakan privilege database, trigger, atau fungsi server yang dirancang aman.

### 5.4. Admin Authorization

Untuk memeriksa role admin, gunakan helper function yang aman.

Contoh konseptual:

```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = (SELECT auth.uid())
      AND role IN ('admin', 'super_admin')
      AND is_active = true
  );
$$;
```

Perhatikan:

- Batasi hak eksekusi function.
- Pastikan owner function memiliki hak minimum yang diperlukan.
- Gunakan schema-qualified object.
- Jangan membuat helper yang dapat dimanfaatkan untuk membaca data profil pengguna lain.
- Hindari recursive RLS policy.
- Uji helper dengan role dan kondisi session yang berbeda.

Function tersebut merupakan contoh rancangan dan perlu ditinjau sebelum digunakan di production.

### 5.5. Service Role Restrictions

Supabase Service Role dapat melewati RLS.

Karena itu:

- Hanya boleh digunakan pada server.
- Tidak boleh diekspos melalui `NEXT_PUBLIC_`.
- Tidak boleh dikirim ke browser.
- Setiap operasi menggunakan service role harus memiliki pemeriksaan authorization tersendiri.
- Gunakan Supabase client berbasis session pengguna jika operasi dapat dilakukan dengan hak akses pengguna biasa.

---

## 6. Database Security

### 6.1. Database Constraints

Gunakan constraint untuk menjaga integritas data.

Contoh:

- Foreign key.
- Unique constraint.
- Check constraint.
- Not null.
- Validasi nilai status.
- Validasi nominal pembayaran.

Contoh:

```sql
ALTER TABLE public.orders
ADD CONSTRAINT orders_total_non_negative
CHECK (total_amount >= 0);
```

Untuk status pembayaran:

```sql
ALTER TABLE public.payments
ADD CONSTRAINT payments_status_valid
CHECK (
  status IN (
    'pending',
    'waiting_verification',
    'paid',
    'failed',
    'expired',
    'refunded'
  )
);
```

### 6.2. Transaction Integrity

Operasi yang mengubah beberapa tabel terkait harus dilakukan secara transaksional.

Contoh pembayaran berhasil:

1. Memverifikasi event.
2. Memperbarui payment.
3. Memperbarui order.
4. Menambahkan order status history.
5. Menandai event telah diproses.

Jika salah satu langkah gagal, perubahan harus dapat di-rollback atau dipulihkan dengan mekanisme yang aman.

Gunakan database function atau mekanisme transaksi yang sesuai, bukan beberapa request terpisah yang berpotensi meninggalkan data tidak konsisten.

### 6.3. Sensitive Data

Data berikut harus mendapatkan perlindungan khusus:

- Email dan nomor telepon customer.
- Bukti transfer.
- Token undangan personal.
- Informasi tamu.
- Pesan pribadi.
- Informasi autentikasi.

Jangan menyimpan secret atau password dalam tabel aplikasi biasa.

---

## 7. Storage Security

### 7.1. Bucket Structure

| Bucket | Access | Isi |
|---|---|---|
| `customer-uploads` | Private | Foto customer |
| `payment-proofs` | Private | Bukti pembayaran |
| `public-assets` | Public | Asset undangan terbit |
| `template-assets` | Public atau terbatas | Asset template |

### 7.2. Upload Validation

Semua upload harus diperiksa:

- MIME type.
- Ukuran file.
- Ekstensi.
- Nama file.
- Kepemilikan order.
- Path penyimpanan.
- Kesesuaian jenis file dengan kebutuhan.

Jangan hanya memeriksa ekstensi. Validasi tipe file berdasarkan konten atau mekanisme pemeriksaan yang sesuai.

### 7.3. File Size Limits

Contoh batas awal yang dapat digunakan:

| Jenis file | Batas awal |
|---|---:|
| Foto profil | 2 MB |
| Foto galeri | 5 MB |
| Foto utama | 5 MB |
| Bukti transfer | 3 MB |
| Audio | 10 MB |

Angka ini merupakan rekomendasi awal dan dapat disesuaikan dengan kebutuhan layanan.

### 7.4. Signed URL

Untuk file privat:

- Gunakan signed URL dengan masa berlaku terbatas.
- Jangan membuat bucket privat menjadi publik hanya untuk mempermudah tampilan.
- Pastikan URL hanya diberikan kepada pengguna yang berhak.
- Hindari menyimpan signed URL permanen di database.

### 7.5. File Ownership

Contoh struktur path:

```text
customer-uploads/
└── {order_id}/
    ├── profile/
    ├── gallery/
    └── event/
```

Server harus memeriksa kepemilikan order sebelum memberikan akses upload atau download.

### 7.6. Malicious File Protection

Untuk pengembangan lanjutan, pertimbangkan:

- Malware scanning.
- Image re-encoding.
- Penghapusan metadata EXIF jika tidak diperlukan.
- Pembatasan jenis file aktif.
- Perlindungan dari file dengan ukuran hasil ekstraksi yang berlebihan.

Jangan mengizinkan file HTML, JavaScript, atau executable diunggah lalu disajikan sebagai konten aktif dari domain aplikasi.

---

## 8. Payment Security

Pembayaran merupakan bagian yang sangat sensitif.

### 8.1. Price Integrity

Harga harus diambil dari database.

Browser hanya mengirim:

```json
{
  "template_id": "template-uuid",
  "package_id": "package-uuid"
}
```

Browser tidak boleh menjadi sumber kebenaran untuk:

```json
{
  "price": 1000,
  "total_amount": 1000,
  "status": "paid"
}
```

Server menghitung total berdasarkan harga resmi dan menyimpan snapshot harga pada saat pesanan dibuat.

### 8.2. Manual Transfer Security

Untuk pembayaran manual:

- Bukti transfer disimpan pada private bucket.
- Hanya customer pemilik order dan admin berwenang yang dapat mengaksesnya.
- Verifikasi dilakukan oleh admin.
- Catat identitas admin dan waktu verifikasi.
- Tolak pembayaran jika nominal atau bukti tidak sesuai.
- Jangan mengizinkan customer mengubah status pembayaran.

### 8.3. Payment Gateway Security

Untuk Midtrans atau Xendit:

- Secret key disimpan pada environment server.
- Verifikasi signature atau token sesuai dokumentasi resmi provider.
- Validasi order ID.
- Validasi transaction ID.
- Validasi nominal.
- Validasi status transaksi.
- Terapkan idempotency.
- Simpan riwayat webhook.

### 8.4. Webhook Replay Protection

Webhook dapat dikirim berulang kali.

Sistem harus:

1. Memeriksa signature.
2. Mengidentifikasi event atau transaksi.
3. Mengecek apakah event sudah diproses.
4. Memastikan perubahan status masih valid.
5. Menyimpan hasil pemrosesan.

Gunakan unique constraint pada kombinasi provider dan event identifier jika provider menyediakan event ID yang stabil.

Jika tidak tersedia, gunakan identitas transaksi dan status/event yang sesuai untuk membangun mekanisme deduplikasi.

---

## 9. Public Invitation Security

Undangan dapat diakses melalui URL:

```text
https://your-domain.com/bergas-nadia
```

Karena bersifat publik, renderer harus membatasi data yang dikeluarkan.

### 9.1. Public Data

Data yang boleh ditampilkan:

- Nama pasangan atau pemilik acara.
- Tanggal dan waktu acara.
- Lokasi acara.
- Galeri foto yang telah disetujui.
- Informasi acara.
- Informasi RSVP.
- Pesan yang memang ditujukan untuk pengunjung.

Data yang tidak boleh ditampilkan:

- Email akun customer.
- Nomor telepon pribadi yang tidak ditujukan untuk publik.
- Bukti pembayaran.
- Catatan internal admin.
- Data konfigurasi produksi internal.
- Informasi transaksi.
- Token autentikasi atau token guest dalam bentuk hash.

### 9.2. Slug Protection

Slug harus:

- Unik.
- Menggunakan karakter yang diizinkan.
- Tidak menggunakan reserved route.
- Tidak dapat mengambil alih slug milik publikasi lain.

Contoh reserved slug:

```text
admin
customer
api
templates
pricing
services
about
contact
login
register
```

### 9.3. Publication Snapshot

Undangan yang dipublikasikan harus menggunakan snapshot:

- Konten final.
- Konfigurasi template.
- Versi template.

Perubahan template pada masa depan tidak boleh merusak undangan yang sudah terbit.

### 9.4. Expiration

Jika undangan telah melewati masa berlaku:

- Renderer harus menolak atau menampilkan halaman kedaluwarsa.
- RSVP tidak boleh menerima submission baru jika kebijakan publikasi melarangnya.
- Data historis tetap disimpan sesuai kebijakan retensi.

---

## 10. Guest & RSVP Security

### 10.1. Guest Token

Jika undangan menggunakan daftar tamu personal, token harus dibuat menggunakan generator acak yang aman.

Ketentuan:

- Token tidak boleh mudah ditebak.
- Database hanya menyimpan hash token.
- Token mentah hanya diberikan melalui mekanisme distribusi yang aman.
- Token tidak boleh dicatat di application log.
- Token dapat dicabut atau diperbarui jika diperlukan.

### 10.2. RSVP Validation

Setiap RSVP harus memeriksa:

- Slug publikasi.
- Status publikasi.
- Masa berlaku.
- Token guest jika diwajibkan.
- Status RSVP sebelumnya.
- Batas jumlah tamu.
- Validitas pesan.

### 10.3. Spam Protection

Terapkan:

- Rate limiting.
- Validasi input.
- Pembatasan ukuran pesan.
- CAPTCHA jika diperlukan.
- Pencegahan submission berulang.

Jangan menjadikan endpoint RSVP sebagai akses publik langsung ke tabel `rsvps`.

---

## 11. Application Security

### 11.1. XSS Protection

Konten dari customer dan guest harus diperlakukan sebagai input tidak tepercaya.

Pencegahan:

- Gunakan escaping bawaan React.
- Hindari `dangerouslySetInnerHTML`.
- Jika rich text diperlukan, gunakan sanitizer berbasis allowlist.
- Validasi URL gambar dan tautan.
- Batasi atribut HTML yang diizinkan.

### 11.2. CSRF Protection

Untuk operasi yang menggunakan cookie session:

- Gunakan mekanisme proteksi CSRF yang sesuai.
- Validasi origin untuk request yang sensitif.
- Gunakan cookie `SameSite` yang tepat.
- Jangan menganggap CORS sebagai proteksi CSRF.

### 11.3. SQL Injection

Gunakan Supabase client dan parameterized query.

Hindari membuat query SQL dengan menggabungkan input pengguna secara langsung.

Jika menggunakan SQL function, pastikan input diperlakukan sebagai parameter dan hak eksekusinya dibatasi.

### 11.4. Open Redirect

URL redirect setelah login, checkout, atau pembayaran harus divalidasi.

Jangan mengizinkan redirect bebas ke domain eksternal dari parameter browser.

### 11.5. Rate Limiting

Endpoint yang perlu dibatasi:

| Endpoint | Risiko |
|---|---|
| Login | Brute force |
| Password reset | Abuse |
| Orders | Spam order |
| Payments | Transaksi berulang |
| Media upload | Penyalahgunaan storage |
| RSVP | Spam submission |
| Public invitation | Traffic abuse |

Batas rate harus disesuaikan dengan karakteristik trafik dan dapat menggunakan Cloudflare atau layanan rate limiting yang sesuai.

---

## 12. Environment & Secret Management

### 12.1. Environment Variables

Contoh environment variable:

```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

SUPABASE_SERVICE_ROLE_KEY=

MIDTRANS_SERVER_KEY=
MIDTRANS_CLIENT_KEY=

XENDIT_SECRET_KEY=
XENDIT_WEBHOOK_TOKEN=

SENTRY_DSN=
```

Daftar tersebut merupakan contoh; gunakan hanya variabel provider yang benar-benar dipilih.

### 12.2. Secret Rules

- Secret hanya disimpan di environment server.
- Jangan menggunakan prefix `NEXT_PUBLIC_` untuk secret.
- Jangan commit file `.env` ke Git.
- Sediakan `.env.example` tanpa nilai rahasia.
- Pisahkan secret development, staging, dan production.
- Rotasi secret jika terindikasi bocor.
- Batasi akses dashboard Vercel dan Supabase.

### 12.3. Git Security

Sebelum melakukan commit:

- Periksa file yang akan di-commit.
- Pastikan `.env` tidak ikut masuk.
- Jangan menyimpan credential di source code.
- Gunakan secret scanning jika tersedia.
- Review dependency dan perubahan konfigurasi.

Contoh `.gitignore`:

```gitignore
.env
.env.local
.env.*.local
.env.production
```

Jangan mengabaikan `.env.example` karena file tersebut berguna sebagai dokumentasi konfigurasi.

---

## 13. Logging & Audit Trail

### 13.1. Application Logging

Log dapat digunakan untuk:

- Error aplikasi.
- Kegagalan pembayaran.
- Kegagalan webhook.
- Upload gagal.
- Kegagalan autentikasi.
- Kesalahan integrasi.

Jangan mencatat:

- Password.
- Access token.
- Refresh token.
- Secret key.
- Token guest mentah.
- Data kartu pembayaran.
- Isi bukti transfer jika tidak diperlukan.

### 13.2. Admin Activity Logs

Gunakan tabel `admin_activity_logs`.

Aktivitas yang wajib dicatat:

- Perubahan status order.
- Verifikasi pembayaran.
- Perubahan role.
- Perubahan template.
- Perubahan paket.
- Pengelolaan publikasi.
- Unpublish undangan.
- Pengelolaan data tamu.
- Perubahan konfigurasi sistem.

Contoh:

```json
{
  "actor_id": "admin-uuid",
  "action": "payment_verified",
  "entity_type": "payment",
  "entity_id": "payment-uuid",
  "metadata": {
    "decision": "approve"
  }
}
```

Log harus ditulis oleh server dan tidak dapat dimodifikasi customer.

### 13.3. Monitoring

Rekomendasi:

- Sentry untuk error tracking.
- Vercel Analytics untuk performa dan penggunaan.
- Supabase Dashboard untuk database dan storage.
- Cloudflare Analytics untuk trafik dan keamanan jaringan.

---

## 14. Backup & Recovery

### 14.1. Database Backup

Lakukan backup database secara berkala.

Rekomendasi:

- Manfaatkan backup yang disediakan oleh paket Supabase yang digunakan.
- Evaluasi kebutuhan backup tambahan.
- Simpan backup penting pada lokasi terpisah.
- Batasi akses ke file backup.
- Dokumentasikan prosedur restore.

### 14.2. Storage Backup

Database backup tidak otomatis menjamin seluruh file Storage dapat dipulihkan.

Karena itu:

- Buat strategi backup file customer.
- Simpan metadata file secara konsisten.
- Verifikasi keberadaan file.
- Uji proses pemulihan file.
- Terapkan retensi berdasarkan kebutuhan bisnis.

### 14.3. Recovery Testing

Lakukan simulasi:

1. Pemulihan database.
2. Pemulihan media.
3. Pemulihan konfigurasi environment.
4. Pemulihan domain dan DNS.
5. Pemulihan integrasi payment gateway.

Target RPO dan RTO perlu ditentukan berdasarkan tingkat layanan yang ingin diberikan.

---

## 15. Dependency & Infrastructure Security

### 15.1. Dependency Management

- Gunakan versi dependency yang terpelihara.
- Periksa vulnerability dependency.
- Hindari package yang tidak dikenal atau tidak terawat.
- Review perubahan major version.
- Lakukan pengujian setelah update.

Tools yang dapat digunakan:

- `pnpm audit`
- Dependabot
- GitHub atau GitLab dependency scanning
- Snyk (opsional)

### 15.2. HTTPS

Seluruh komunikasi production harus menggunakan HTTPS.

Pastikan:

- Domain menggunakan SSL/TLS.
- Tidak ada mixed content.
- Redirect HTTP ke HTTPS.
- Webhook menggunakan endpoint HTTPS.
- Cookie session aman.

### 15.3. Cloudflare

Cloudflare dapat digunakan untuk:

- DNS management.
- CDN.
- SSL/TLS.
- WAF sesuai paket dan konfigurasi.
- Rate limiting sesuai ketersediaan fitur.
- Proteksi trafik mencurigakan.

Jangan menganggap Cloudflare menggantikan authorization dan RLS pada aplikasi.

---

## 16. Security Testing Checklist

### Authentication

- [ ] User tidak dapat mengakses dashboard tanpa login.
- [ ] Session kedaluwarsa ditangani dengan benar.
- [ ] Password reset berjalan aman.
- [ ] Customer tidak dapat mengubah role sendiri.
- [ ] Akun admin memiliki perlindungan tambahan.

### Authorization & RLS

- [ ] Customer A tidak dapat membaca pesanan Customer B.
- [ ] Customer tidak dapat mengubah harga.
- [ ] Customer tidak dapat mengubah status pembayaran.
- [ ] Customer tidak dapat mengakses bukti transfer orang lain.
- [ ] Guest tidak dapat mengakses tabel internal.
- [ ] Admin tidak dapat mengelola role Super Admin tanpa izin.

### Payments

- [ ] Webhook dengan signature tidak valid ditolak.
- [ ] Webhook duplikat tidak memproses pembayaran dua kali.
- [ ] Nominal transaksi harus sesuai.
- [ ] Redirect sukses tidak otomatis mengubah payment menjadi paid.
- [ ] Pembayaran manual membutuhkan verifikasi admin.

### Storage

- [ ] Customer hanya dapat mengunggah file ke order miliknya.
- [ ] File dengan tipe tidak diizinkan ditolak.
- [ ] Ukuran file dibatasi.
- [ ] Bukti transfer tidak dapat diakses publik.
- [ ] Signed URL memiliki masa berlaku.

### Public Invitation

- [ ] Undangan draft tidak dapat diakses publik.
- [ ] Undangan unpublished tidak dapat diakses publik.
- [ ] Slug reserved ditolak.
- [ ] Data internal tidak dikirim ke browser.
- [ ] Undangan expired mengikuti kebijakan kedaluwarsa.

### RSVP

- [ ] RSVP hanya diterima untuk publikasi valid.
- [ ] Token guest divalidasi jika diwajibkan.
- [ ] Jumlah tamu divalidasi.
- [ ] Spam submission dibatasi.
- [ ] Token tidak muncul di log.

### Infrastructure

- [ ] Secret tidak masuk repository.
- [ ] HTTPS aktif.
- [ ] Backup database tersedia.
- [ ] Backup media tersedia sesuai kebijakan.
- [ ] Error monitoring aktif.
- [ ] Dependency diperiksa secara berkala.

---

## 17. Security Implementation Priority

| Tahap | Kontrol | Prioritas |
|---|---|---|
| 1 | Supabase Auth dan session | Critical |
| 2 | RBAC | Critical |
| 3 | RLS seluruh tabel sensitif | Critical |
| 4 | Server-side validation | Critical |
| 5 | Payment webhook security | Critical |
| 6 | Private Storage dan signed URL | Critical |
| 7 | Customer ownership checks | Critical |
| 8 | Public invitation data filtering | High |
| 9 | RSVP rate limiting | High |
| 10 | Admin audit logs | High |
| 11 | Error monitoring | Medium |
| 12 | Malware scanning | Medium |
| 13 | Backup dan recovery testing | High |
| 14 | Dependency scanning | Medium |

---

## 18. Security Policy

Hal-hal yang tidak boleh dilanggar selama pengembangan:

1. Tidak boleh mempercayai role dari browser.
2. Tidak boleh mempercayai nominal pembayaran dari browser.
3. Tidak boleh membiarkan customer mengakses data customer lain.
4. Tidak boleh menggunakan Service Role Key di client.
5. Tidak boleh membuka bukti pembayaran secara publik.
6. Tidak boleh mengubah status pembayaran hanya berdasarkan redirect.
7. Tidak boleh mempublikasikan undangan tanpa validasi.
8. Tidak boleh mengirim data internal ke public invitation renderer.
9. Tidak boleh menyimpan secret di Git.
10. Tidak boleh menganggap proteksi UI sebagai pengganti RLS dan authorization server-side.

Dokumen ini menjadi acuan keamanan untuk proses development, code review, pengujian, dan deployment production.
