# API Documentation

## 1. Overview

Dokumen ini menjelaskan rancangan API untuk platform jasa pembuatan undangan digital.

API dirancang menggunakan pendekatan **modular monolith** dengan Next.js App Router. Operasi internal aplikasi dapat menggunakan Server Actions, sedangkan komunikasi dengan layanan eksternal dan endpoint publik menggunakan Route Handlers.

Teknologi utama:

- Next.js App Router
- TypeScript
- Supabase PostgreSQL
- Supabase Auth
- Supabase Storage
- Midtrans atau Xendit
- Vercel

> Seluruh endpoint dan format JSON dalam dokumen ini merupakan kontrak rancangan (proposed API contract), bukan endpoint yang sudah diimplementasikan.

---

## 2. API Architecture

### 2.1. Pembagian Server Actions dan Route Handlers

Tidak semua operasi harus dibuat sebagai REST API.

| Kebutuhan | Pendekatan |
|---|---|
| Membuat pesanan dari halaman checkout | Server Action |
| Mengubah profil customer | Server Action |
| Mengelola template dari dashboard admin | Server Action |
| Memproses revisi dari dashboard | Server Action |
| Membuat transaksi payment gateway | Server Action atau Route Handler |
| Menerima webhook payment gateway | Route Handler |
| Mengakses undangan berdasarkan slug | Server Component atau Route Handler |
| Mengirim RSVP dari halaman publik | Route Handler |
| Integrasi dengan layanan eksternal | Route Handler |

**Server Actions** digunakan untuk operasi internal yang dipicu oleh UI Next.js.

**Route Handlers** digunakan untuk komunikasi HTTP yang membutuhkan endpoint eksplisit, terutama webhook, RSVP, dan integrasi eksternal.

### 2.2. Base URL

Development:

```text
http://localhost:3000
```

Production:

```text
https://your-domain.com
```

Contoh endpoint:

```text
/api/v1/orders
/api/v1/payments
/api/v1/webhooks/midtrans
/api/v1/webhooks/xendit
/api/v1/public/invitations/{slug}
```

Prefix `/api/v1` digunakan untuk menjaga konsistensi dan mempermudah pengembangan versi API berikutnya.

---

## 3. Authentication & Authorization

### 3.1. Authentication

Authentication menggunakan Supabase Auth.

Metode autentikasi yang direncanakan:

- Email dan password.
- Email verification.
- Session berbasis cookie melalui integrasi Supabase SSR.
- Password reset.
- Logout.

Untuk request dari browser ke Route Handler, session harus divalidasi di sisi server.

Untuk webhook payment gateway, autentikasi menggunakan mekanisme verifikasi signature atau token resmi dari provider, bukan session customer.

### 3.2. Role Access

| Role | Hak akses |
|---|---|
| Visitor | Mengakses halaman publik dan katalog |
| Customer | Mengelola profil, pesanan, pembayaran, dan undangan miliknya |
| Admin | Mengelola pesanan, produksi, pembayaran, revisi, dan publikasi |
| Super Admin | Seluruh akses admin dan konfigurasi sistem |
| Guest | Melihat undangan dan mengirim RSVP sesuai validasi |

### 3.3. Authorization Rules

Setiap operasi sensitif harus melakukan pemeriksaan hak akses.

Contoh:

- Customer hanya dapat melihat pesanan miliknya.
- Customer tidak dapat mengubah harga pesanan.
- Customer tidak dapat mengubah status pembayaran menjadi `paid`.
- Admin dapat memproses pesanan sesuai kewenangannya.
- Hanya Super Admin yang dapat mengelola role admin.
- Guest hanya dapat mengirim RSVP untuk undangan yang valid.
- Undangan yang belum dipublikasikan tidak dapat diakses melalui halaman publik.

Pemeriksaan dilakukan di server dan diperkuat dengan Supabase Row Level Security (RLS).

**Penting:** Jangan pernah mempercayai `customer_id`, `role`, `price`, `total_amount`, atau `status` yang dikirim langsung oleh browser. Identitas pengguna harus berasal dari session yang tervalidasi, sedangkan harga dan status harus ditentukan oleh server.

---

## 4. Standard Response Format

### 4.1. Success Response

Format respons standar:

```json
{
  "success": true,
  "message": "Request berhasil diproses",
  "data": {
    "id": "uuid",
    "status": "success"
  },
  "meta": null
}
```

### 4.2. Error Response

```json
{
  "success": false,
  "message": "Terjadi kesalahan pada request",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "phone",
        "message": "Nomor telepon wajib diisi"
      }
    ]
  }
}
```

### 4.3. HTTP Status Codes

| Status | Keterangan |
|---|---|
| 200 | Request berhasil |
| 201 | Data berhasil dibuat |
| 204 | Request berhasil tanpa response body |
| 400 | Request tidak valid |
| 401 | Belum terautentikasi |
| 403 | Tidak memiliki izin |
| 404 | Data tidak ditemukan |
| 409 | Konflik data atau duplikasi |
| 422 | Validasi bisnis gagal |
| 429 | Terlalu banyak request |
| 500 | Kesalahan internal server |
| 502 | Gangguan komunikasi dengan provider |
| 503 | Layanan sementara tidak tersedia |

---

## 5. Pagination & Filtering

Endpoint yang mengembalikan daftar data menggunakan pagination.

### 5.1. Query Parameters

```text
?page=1&limit=10&sort=created_at&order=desc
```

Parameter:

| Parameter | Default | Keterangan |
|---|---|---|
| `page` | 1 | Nomor halaman |
| `limit` | 10 | Jumlah data |
| `sort` | created_at | Kolom pengurutan yang diizinkan |
| `order` | desc | asc atau desc |
| `search` | - | Pencarian |
| `status` | - | Filter status |

Server harus membatasi nilai maksimum `limit`, misalnya 100.

### 5.2. Pagination Response

```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 45,
    "total_pages": 5
  }
}
```

---

# 6. Endpoint Documentation

## 6.1. Public Catalog

Endpoint katalog dapat diakses tanpa login.

### GET `/api/v1/categories`

Mengambil seluruh kategori undangan aktif.

Access: Public

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "category-uuid",
      "name": "Wedding",
      "slug": "wedding",
      "description": "Undangan pernikahan",
      "thumbnail_url": "https://example.com/wedding.jpg"
    }
  ]
}
```

### GET `/api/v1/templates`

Mengambil daftar template aktif.

Access: Public

Query:

```text
?category=wedding&page=1&limit=10
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "template-uuid",
      "name": "Elegant Wedding",
      "slug": "elegant-wedding",
      "category": {
        "name": "Wedding",
        "slug": "wedding"
      },
      "thumbnail_url": "https://example.com/template.jpg",
      "demo_url": "https://example.com/demo",
      "starting_price": 150000
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "total_pages": 1
  }
}
```

### GET `/api/v1/templates/{slug}`

Mengambil detail template dan informasi demo.

Access: Public

Response:

```json
{
  "success": true,
  "data": {
    "id": "template-uuid",
    "name": "Elegant Wedding",
    "slug": "elegant-wedding",
    "description": "Template undangan minimalis",
    "category": "Wedding",
    "demo_url": "https://example.com/demo",
    "thumbnail_url": "https://example.com/template.jpg",
    "version": {
      "id": "version-uuid",
      "version_number": 1
    }
  }
}
```

### GET `/api/v1/packages`

Mengambil daftar paket layanan aktif.

Access: Public

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "package-uuid",
      "name": "Premium",
      "slug": "premium",
      "price": 250000,
      "currency": "IDR",
      "revision_limit": 3,
      "duration_days": 365,
      "features": [
        {
          "name": "Gallery",
          "value": "Unlimited",
          "is_included": true
        }
      ]
    }
  ]
}
```

---

## 6.2. Customer Orders

Seluruh endpoint pesanan customer membutuhkan authentication.

### POST `/api/v1/orders`

Membuat pesanan baru.

Access: Customer

Request:

```json
{
  "template_id": "template-uuid",
  "package_id": "package-uuid",
  "customer_notes": "Mohon desain menggunakan warna putih dan gold"
}
```

Server akan:

1. Mengambil customer dari session.
2. Memastikan template aktif.
3. Memastikan paket aktif.
4. Mengambil harga resmi dari database.
5. Menghitung subtotal dan total.
6. Membuat nomor pesanan.
7. Menyimpan snapshot template dan paket.
8. Membuat pesanan dengan status `pending_payment`.

Response:

```json
{
  "success": true,
  "message": "Pesanan berhasil dibuat",
  "data": {
    "id": "order-uuid",
    "order_number": "INV-2026-00001",
    "status": "pending_payment",
    "total_amount": 250000,
    "currency": "IDR"
  }
}
```

HTTP: `201 Created`

### GET `/api/v1/orders`

Mengambil daftar pesanan customer yang sedang login.

Access: Customer

Query:

```text
?page=1&limit=10&status=pending_payment
```

Response:

```json
{
  "success": true,
  "data": [
    {
      "id": "order-uuid",
      "order_number": "INV-2026-00001",
      "status": "pending_payment",
      "total_amount": 250000,
      "created_at": "2026-11-03T10:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "total_pages": 1
  }
}
```

### GET `/api/v1/orders/{orderId}`

Mengambil detail pesanan.

Access: Customer pemilik pesanan atau Admin.

Response:

```json
{
  "success": true,
  "data": {
    "id": "order-uuid",
    "order_number": "INV-2026-00001",
    "status": "paid",
    "subtotal": 250000,
    "discount_amount": 0,
    "total_amount": 250000,
    "currency": "IDR",
    "items": [],
    "payments": [],
    "created_at": "2026-11-03T10:00:00Z"
  }
}
```

### POST `/api/v1/orders/{orderId}/cancel`

Mengajukan pembatalan pesanan.

Access: Customer pemilik pesanan.

Aturan:

- Pesanan yang belum dibayar dapat dibatalkan jika masih memenuhi aturan bisnis.
- Pesanan yang sudah dibayar tidak otomatis dibatalkan melalui endpoint ini.
- Pengembalian dana harus melalui proses refund tersendiri.
- Pembatalan harus tercatat di riwayat status.

---

## 6.3. Payments

### POST `/api/v1/orders/{orderId}/payments`

Membuat percobaan pembayaran untuk pesanan.

Access: Customer pemilik pesanan.

Request manual transfer:

```json
{
  "payment_method": "bank_transfer"
}
```

Request payment gateway:

```json
{
  "payment_method": "gateway",
  "provider": "midtrans"
}
```

Response manual transfer:

```json
{
  "success": true,
  "data": {
    "payment_id": "payment-uuid",
    "payment_method": "bank_transfer",
    "status": "pending",
    "amount": 250000,
    "currency": "IDR"
  }
}
```

Response gateway:

```json
{
  "success": true,
  "data": {
    "payment_id": "payment-uuid",
    "payment_method": "gateway",
    "provider": "midtrans",
    "status": "pending",
    "payment_url": "https://payment-provider.example/checkout"
  }
}
```

Server harus memastikan pesanan masih dapat dibayar dan jumlah pembayaran berasal dari total pesanan di database.

### POST `/api/v1/payments/{paymentId}/proof`

Mengunggah bukti transfer manual.

Access: Customer pemilik pesanan.

Request: `multipart/form-data`

Field:

```text
proof: image file
```

Validasi:

- Hanya format file yang diizinkan, misalnya JPEG, PNG, atau WebP.
- Ukuran file dibatasi.
- File disimpan pada private bucket.
- Path penyimpanan dicatat di `payments.proof_storage_path`.
- Customer tidak dapat mengubah status pembayaran secara langsung.

Setelah bukti diunggah, status pembayaran menjadi:

```text
waiting_verification
```

### GET `/api/v1/payments/{paymentId}`

Mengambil status pembayaran.

Access: Customer pemilik pesanan atau Admin.

Response:

```json
{
  "success": true,
  "data": {
    "id": "payment-uuid",
    "order_id": "order-uuid",
    "payment_method": "bank_transfer",
    "status": "waiting_verification",
    "amount": 250000,
    "currency": "IDR",
    "created_at": "2026-11-03T10:00:00Z"
  }
}
```

### GET `/api/v1/admin/payments`

Mengambil daftar pembayaran untuk verifikasi admin.

Access: Admin, Super Admin.

Query:

```text
?status=waiting_verification&page=1&limit=10
```

### POST `/api/v1/admin/payments/{paymentId}/verify`

Menyetujui atau menolak pembayaran manual.

Access: Admin, Super Admin.

Request:

```json
{
  "decision": "approve",
  "notes": "Bukti transfer sesuai"
}
```

Untuk penolakan:

```json
{
  "decision": "reject",
  "notes": "Nominal transfer tidak sesuai"
}
```

Aturan:

- Verifikasi harus dilakukan oleh admin yang terautentikasi.
- Simpan `verified_by` dan `verified_at`.
- Jika disetujui, ubah status payment menjadi `paid` dan perbarui status order sesuai aturan.
- Jika ditolak, customer harus diberi kesempatan mengunggah bukti baru sesuai kebijakan.
- Semua keputusan dicatat dalam audit log.

---

## 6.4. Payment Gateway Webhooks

Webhook digunakan untuk menerima notifikasi pembayaran dari provider.

Endpoint:

```text
POST /api/v1/webhooks/midtrans
POST /api/v1/webhooks/xendit
```

Access: Payment provider melalui server-to-server.

Webhook bukan endpoint yang menggunakan session customer.

### Webhook Processing Flow

1. Provider mengirim notifikasi.
2. Server menerima payload.
3. Server memverifikasi signature atau token sesuai dokumentasi resmi provider.
4. Server mencari transaksi berdasarkan identifier provider.
5. Server mencocokkan nominal dan mata uang.
6. Server mengecek apakah event sudah pernah diproses.
7. Server menyimpan event ke `payment_events`.
8. Server memperbarui status payment dan order secara transaksional.
9. Server mengembalikan respons yang sesuai dengan protokol provider.

Contoh payload konseptual:

```json
{
  "transaction_id": "provider-transaction-123",
  "order_id": "INV-2026-00001",
  "transaction_status": "settlement",
  "gross_amount": "250000.00"
}
```

Payload aktual harus mengikuti format resmi provider yang digunakan.

### Idempotency

Webhook dapat dikirim berulang kali. Karena itu:

- Simpan ID event provider.
- Gunakan unique constraint yang sesuai, idealnya kombinasi provider dan event ID.
- Jangan memproses event yang sudah berhasil diproses.
- Gunakan transaksi database untuk perubahan status yang saling berkaitan.
- Catat kegagalan pemrosesan agar dapat ditinjau dan diproses ulang secara aman.

**Jangan pernah menganggap customer kembali ke halaman sukses sebagai bukti pembayaran.** Status pembayaran hanya boleh dikonfirmasi melalui webhook yang valid atau verifikasi manual oleh admin.

---

## 6.5. Invitation Content

### GET `/api/v1/orders/{orderId}/content`

Mengambil data konten undangan.

Access: Customer pemilik pesanan atau Admin.

Response:

```json
{
  "success": true,
  "data": {
    "id": "content-uuid",
    "order_id": "order-uuid",
    "submission_status": "draft",
    "content_json": {
      "event_title": "The Wedding of",
      "bride_name": "Bergas",
      "groom_name": "Nadia",
      "event_date": "2027-01-10"
    }
  }
}
```

### PUT `/api/v1/orders/{orderId}/content`

Menyimpan draft data undangan.

Access: Customer pemilik pesanan.

Request:

```json
{
  "content_json": {
    "event_title": "The Wedding of",
    "bride_name": "Bergas",
    "groom_name": "Nadia",
    "event_date": "2027-01-10",
    "location": {
      "name": "Gedung Acara",
      "address": "Jakarta",
      "latitude": -6.2,
      "longitude": 106.8
    }
  }
}
```

Validasi berdasarkan kategori undangan dan struktur form yang berlaku.

### POST `/api/v1/orders/{orderId}/content/submit`

Mengirim data undangan untuk ditinjau admin.

Access: Customer pemilik pesanan.

Aturan:

- Semua field wajib harus terpenuhi.
- Media yang dibutuhkan harus tersedia.
- Status submission berubah menjadi `submitted`.
- Simpan `submitted_at`.
- Customer tidak dapat mengubah data yang sedang diproses tanpa mekanisme perubahan atau revisi yang disediakan.

### POST `/api/v1/admin/orders/{orderId}/content/review`

Admin melakukan pemeriksaan data.

Access: Admin, Super Admin.

Request:

```json
{
  "decision": "incomplete",
  "notes": "Mohon lengkapi alamat dan foto pasangan"
}
```

Keputusan lain:

```json
{
  "decision": "approved",
  "notes": "Data sudah lengkap"
}
```

---

## 6.6. Media Upload

Media customer disimpan di Supabase Storage.

Bucket yang direncanakan:

| Bucket | Visibility | Kegunaan |
|---|---|---|
| `customer-uploads` | Private | Foto dan file yang diunggah customer |
| `payment-proofs` | Private | Bukti transfer |
| `public-assets` | Public | Asset undangan yang telah dipublikasikan |
| `template-assets` | Public atau terbatas sesuai kebutuhan | Asset template |

### POST `/api/v1/orders/{orderId}/media/upload-url`

Meminta URL upload atau informasi upload yang aman.

Access: Customer pemilik pesanan atau Admin sesuai kewenangan.

Request:

```json
{
  "file_name": "prewedding-01.jpg",
  "mime_type": "image/jpeg",
  "file_size": 2048000,
  "asset_type": "gallery"
}
```

Response konseptual:

```json
{
  "success": true,
  "data": {
    "upload_url": "signed-upload-url",
    "storage_path": "order-uuid/gallery/random-file.jpg",
    "expires_in": 300
  }
}
```

Implementasi dapat menggunakan signed upload URL Supabase atau upload melalui server sesuai kebutuhan.

### POST `/api/v1/orders/{orderId}/media/confirm`

Mencatat metadata file setelah upload selesai.

Request:

```json
{
  "storage_path": "order-uuid/gallery/random-file.jpg",
  "file_name": "prewedding-01.jpg",
  "mime_type": "image/jpeg",
  "file_size": 2048000,
  "asset_type": "gallery"
}
```

Server harus memverifikasi bahwa file benar-benar tersedia dan path tersebut termasuk dalam ruang akses customer yang bersangkutan.

Jangan mempercayai metadata file dari browser tanpa validasi.

---

## 6.7. Production Management

Endpoint berikut hanya dapat digunakan admin.

### GET `/api/v1/admin/production`

Mengambil daftar pekerjaan produksi.

Query:

```text
?status=in_progress&page=1&limit=10
```

### GET `/api/v1/admin/production/{orderId}`

Mengambil detail pekerjaan produksi.

### POST `/api/v1/admin/production/{orderId}/start`

Memulai proses produksi.

Request:

```json
{
  "notes": "Mulai pengerjaan desain undangan"
}
```

### PUT `/api/v1/admin/production/{orderId}/content`

Memperbarui konten produksi.

Request:

```json
{
  "production_json": {
    "selected_template_version_id": "version-uuid",
    "theme": {
      "primary_color": "#D4AF37",
      "secondary_color": "#FFFFFF"
    },
    "sections": [
      "hero",
      "couple",
      "event",
      "gallery",
      "rsvp"
    ]
  }
}
```

Data konfigurasi produksi tidak boleh otomatis dianggap sebagai konten publik sebelum lolos pemeriksaan.

### POST `/api/v1/admin/production/{orderId}/preview`

Membuat preview undangan untuk customer.

Response:

```json
{
  "success": true,
  "data": {
    "preview_id": "preview-uuid",
    "preview_url": "https://your-domain.com/preview/preview-uuid",
    "status": "preview_ready"
  }
}
```

Preview harus dilindungi dari akses publik yang tidak berwenang.

### POST `/api/v1/admin/production/{orderId}/qa`

Mencatat hasil quality assurance.

Request:

```json
{
  "checks": {
    "event_date": true,
    "event_location": true,
    "images": true,
    "gallery": true,
    "responsive": true,
    "no_placeholder": true
  },
  "notes": "Seluruh pemeriksaan selesai"
}
```

Server harus memastikan seluruh pemeriksaan wajib terpenuhi sebelum mengizinkan proses approval atau publikasi.

---

## 6.8. Customer Approval & Revisions

### POST `/api/v1/orders/{orderId}/approve`

Customer menyetujui hasil preview.

Access: Customer pemilik pesanan.

Request:

```json
{
  "approved": true,
  "notes": "Desain sudah sesuai"
}
```

Approval harus dicatat dengan waktu dan identitas customer.

### POST `/api/v1/orders/{orderId}/revisions`

Customer mengajukan revisi.

Access: Customer pemilik pesanan.

Request:

```json
{
  "description": "Mohon ubah warna utama menjadi sage green"
}
```

Server harus memeriksa:

- Pesanan memang berada pada tahap yang mengizinkan revisi.
- Batas revisi berdasarkan snapshot paket saat order dibuat.
- Apakah revisi termasuk cakupan layanan.
- Apakah diperlukan biaya tambahan.

### GET `/api/v1/orders/{orderId}/revisions`

Mengambil riwayat revisi pesanan.

Access: Customer pemilik pesanan atau Admin.

### POST `/api/v1/admin/revisions/{revisionId}/messages`

Admin mengirim pesan terkait revisi.

Request:

```json
{
  "message": "Perubahan warna sedang dikerjakan"
}
```

### PUT `/api/v1/admin/revisions/{revisionId}`

Admin memperbarui status revisi.

Request:

```json
{
  "status": "completed",
  "notes": "Revisi telah diterapkan"
}
```

Status revisi harus mengikuti state transition yang ditentukan sistem.

---

## 6.9. Invitation Publication

### POST `/api/v1/admin/publications`

Membuat draft publikasi undangan.

Access: Admin, Super Admin.

Request:

```json
{
  "order_id": "order-uuid",
  "slug": "bergas-nadia",
  "template_version_id": "version-uuid"
}
```

Validasi:

- Pesanan sudah memenuhi persyaratan publikasi.
- Customer telah menyetujui preview.
- Slug belum digunakan.
- Slug bukan reserved route.
- Template version valid dan sesuai dengan template pesanan.

### GET `/api/v1/admin/publications/{publicationId}`

Mengambil detail publikasi.

### PUT `/api/v1/admin/publications/{publicationId}`

Memperbarui konfigurasi draft publikasi.

### POST `/api/v1/admin/publications/{publicationId}/publish`

Mempublikasikan undangan.

Server akan:

1. Memvalidasi status pesanan.
2. Memvalidasi approval customer.
3. Memvalidasi konten dan template snapshot.
4. Memeriksa keunikan slug.
5. Menyimpan snapshot final konten dan konfigurasi template.
6. Mengubah status menjadi `published`.
7. Mencatat `published_at`.
8. Mengirim notifikasi kepada customer.

### POST `/api/v1/admin/publications/{publicationId}/unpublish`

Menonaktifkan undangan yang sudah dipublikasikan.

Access: Admin, Super Admin.

### GET `/api/v1/public/invitations/{slug}`

Mengambil undangan publik berdasarkan slug.

Access: Public, hanya jika publication berstatus `published` dan belum melewati masa berlaku.

Response:

```json
{
  "success": true,
  "data": {
    "slug": "bergas-nadia",
    "status": "published",
    "template": {
      "version": 1,
      "config": {}
    },
    "content": {
      "event_title": "The Wedding of",
      "bride_name": "Bergas",
      "groom_name": "Nadia",
      "event_date": "2027-01-10"
    }
  }
}
```

Endpoint publik hanya boleh mengembalikan data yang memang ditujukan untuk pengunjung. Jangan mengirim data internal produksi, data pembayaran, nomor telepon pribadi, atau informasi customer yang tidak relevan.

Untuk implementasi renderer Next.js, data ini juga dapat diambil langsung melalui server-side data access tanpa melewati HTTP internal.

---

## 6.10. Guest Management & RSVP

### GET `/api/v1/admin/publications/{publicationId}/guests`

Mengambil daftar tamu undangan.

Access: Admin, Super Admin.

### POST `/api/v1/admin/publications/{publicationId}/guests`

Menambahkan tamu.

Request:

```json
{
  "guest_name": "Andi",
  "phone": "081234567890",
  "invitation_group": "family"
}
```

Server membuat token undangan secara aman dan hanya menyimpan hash token di database.

### PUT `/api/v1/admin/guests/{guestId}`

Memperbarui informasi tamu.

### DELETE `/api/v1/admin/guests/{guestId}`

Menghapus atau menonaktifkan data tamu sesuai kebijakan retensi data.

### POST `/api/v1/public/rsvp`

Mengirim RSVP dari halaman undangan publik.

Access: Public, dengan validasi undangan dan rate limiting.

Request konseptual:

```json
{
  "slug": "bergas-nadia",
  "guest_token": "secure-guest-token",
  "attendance_status": "attending",
  "guest_count": 2,
  "message": "Selamat menempuh hidup baru!"
}
```

Nilai `attendance_status`:

- `attending`
- `not_attending`
- `maybe`

Response:

```json
{
  "success": true,
  "message": "RSVP berhasil dikirim",
  "data": {
    "attendance_status": "attending",
    "guest_count": 2
  }
}
```

Aturan keamanan:

- Validasi bahwa publikasi masih aktif.
- Validasi token tamu jika menggunakan undangan personal.
- Batasi jumlah tamu sesuai aturan.
- Sanitasi pesan.
- Terapkan rate limiting.
- Jangan mengembalikan token atau data tamu lain.
- Cegah RSVP ganda atau tentukan aturan pembaruan RSVP.

**Catatan model RSVP:** Skema awal menggunakan `guest_id` unik pada tabel `rsvps`. Dengan demikian, satu tamu hanya memiliki satu record RSVP aktif. Jika nantinya ingin mendukung RSVP tanpa daftar tamu sebelumnya, model database perlu diperluas.

---

## 6.11. Admin Order Management

### GET `/api/v1/admin/orders`

Mengambil seluruh pesanan untuk kebutuhan administrasi.

Query:

```text
?status=paid&search=INV-2026&page=1&limit=20
```

### GET `/api/v1/admin/orders/{orderId}`

Mengambil detail pesanan.

### PUT `/api/v1/admin/orders/{orderId}/status`

Memperbarui status pesanan sesuai transisi yang diizinkan.

Request:

```json
{
  "status": "processing",
  "notes": "Pesanan masuk antrean produksi"
}
```

Server harus memvalidasi transisi status dan mencatat perubahan pada `order_status_history`.

### GET `/api/v1/admin/analytics/overview`

Mengambil ringkasan statistik dashboard.

Response:

```json
{
  "success": true,
  "data": {
    "total_orders": 120,
    "pending_payment": 10,
    "processing": 15,
    "completed": 85,
    "total_revenue": 25000000
  }
}
```

Angka pendapatan harus dihitung dari pembayaran yang telah dikonfirmasi, bukan hanya total nilai pesanan.

---

# 7. Validation Rules

Semua input harus divalidasi di server.

Validasi utama:

| Data | Aturan |
|---|---|
| Email | Format email valid |
| Phone | Format nomor telepon yang diizinkan |
| Slug | Huruf kecil, angka, dan tanda hubung |
| Price | Integer/numeric positif dari database |
| Quantity | Integer positif |
| Image | MIME type dan ukuran dibatasi |
| Event date | Format tanggal valid |
| RSVP count | Integer sesuai batas |
| Revision | Tidak melebihi batas paket tanpa persetujuan tambahan |
| Payment | Nominal harus sama dengan tagihan |
| Role | Hanya dapat diubah oleh pihak berwenang |

Library validasi yang direkomendasikan:

- Zod untuk validasi TypeScript.
- Validasi tambahan di PostgreSQL melalui constraint.
- Supabase RLS untuk pembatasan akses data.

---

# 8. Security Requirements

## 8.1. Server-side Authorization

Jangan mengandalkan proteksi UI.

Setiap operasi harus memeriksa authentication dan authorization di server.

## 8.2. Row Level Security

RLS wajib aktif pada tabel yang menyimpan data customer dan transaksi.

Contoh kebijakan:

- Customer hanya dapat membaca pesanan miliknya.
- Customer hanya dapat mengubah data undangan miliknya sesuai status.
- Admin dapat mengakses data operasional sesuai role.
- Guest tidak mendapatkan akses langsung ke tabel internal.
- Data payment tidak boleh dapat diubah customer secara bebas.

## 8.3. Service Role Key

Supabase Service Role Key hanya boleh digunakan pada lingkungan server yang terpercaya.

Jangan pernah memasukkannya ke:

- Client Component.
- Browser bundle.
- Repository publik.
- Environment variable dengan prefix `NEXT_PUBLIC_`.

## 8.4. Webhook Security

- Verifikasi signature atau token provider.
- Gunakan idempotency.
- Validasi nominal dan identitas transaksi.
- Simpan event untuk audit.
- Hindari memproses payload yang tidak valid.

## 8.5. Rate Limiting

Endpoint yang perlu mendapat perlindungan khusus:

- Login dan reset password.
- RSVP.
- Upload media.
- Pembuatan pesanan.
- Endpoint publikasi publik.
- Endpoint yang mengirim notifikasi.

Rate limiting dapat diterapkan melalui layanan edge atau mekanisme penyimpanan counter yang sesuai.

## 8.6. Input Sanitization

Sanitasi konten yang berasal dari customer, khususnya:

- Nama.
- Deskripsi acara.
- Pesan RSVP.
- Pesan revisi.
- URL media.
- Konten HTML atau rich text.

Jangan merender HTML dari customer secara langsung tanpa sanitasi.

---

# 9. Database Mapping

Pemetaan endpoint ke tabel utama:

| Modul | Tabel |
|---|---|
| Authentication & Profile | `profiles`, Supabase Auth |
| Categories | `categories` |
| Templates | `templates`, `template_versions` |
| Packages | `packages`, `package_features` |
| Orders | `orders`, `order_items` |
| Payments | `payments`, `payment_events` |
| Invitation Content | `invitation_contents` |
| Media | `media_assets`, Supabase Storage |
| Production | `invitation_contents`, `invitation_publications` |
| Revisions | `revisions`, `revision_messages` |
| Publication | `invitation_publications` |
| Guests | `guests` |
| RSVP | `rsvps` |
| Status History | `order_status_history` |
| Audit | `admin_activity_logs` |

Endpoint notifikasi dapat menggunakan mekanisme integrasi atau layanan notifikasi terlebih dahulu. Tabel `notifications` belum termasuk dalam skema database awal dan perlu ditambahkan jika notifikasi persisten di dashboard menjadi kebutuhan MVP.

Begitu pula, endpoint produksi dalam rancangan ini menggunakan tabel yang sudah tersedia. Tabel khusus seperti `production_tasks` dapat dipertimbangkan kemudian jika alur produksi semakin kompleks.

---

# 10. Recommended Project Structure

```text
src/
├── app/
│   ├── (public)/
│   ├── (customer)/
│   ├── (admin)/
│   ├── [slug]/
│   └── api/
│       └── v1/
│           ├── categories/
│           ├── templates/
│           ├── packages/
│           ├── orders/
│           ├── payments/
│           ├── webhooks/
│           │   ├── midtrans/
│           │   └── xendit/
│           ├── public/
│           │   ├── invitations/
│           │   └── rsvp/
│           └── admin/
│
├── modules/
│   ├── auth/
│   ├── categories/
│   ├── templates/
│   ├── packages/
│   ├── orders/
│   ├── payments/
│   ├── invitations/
│   ├── production/
│   ├── revisions/
│   ├── guests/
│   └── publications/
│
├── lib/
│   ├── supabase/
│   ├── validations/
│   ├── permissions/
│   ├── payment-providers/
│   ├── storage/
│   └── utils/
│
└── types/
    ├── api.ts
    ├── database.ts
    └── domain.ts
```

Struktur ini merupakan rancangan awal. File dan folder dapat disesuaikan ketika implementasi dimulai.

---

# 11. API Development Priority

Urutan implementasi yang direkomendasikan:

| Tahap | Modul | Prioritas |
|---|---|---|
| 1 | Authentication & Profile | Critical |
| 2 | Categories, Templates, Packages | Critical |
| 3 | Orders | Critical |
| 4 | Payments | Critical |
| 5 | Invitation Content & Media | Critical |
| 6 | Admin Order Management | High |
| 7 | Production & Preview | High |
| 8 | Approval & Revisions | High |
| 9 | Publication & Public Renderer | High |
| 10 | Guests & RSVP | High |
| 11 | Analytics & Audit | Medium |
| 12 | Notifications | Medium |

---

# 12. API Design Principles

Prinsip yang harus dipertahankan selama pengembangan:

1. Server menjadi sumber kebenaran untuk harga, status, role, dan kepemilikan data.
2. Setiap operasi sensitif harus melalui authentication dan authorization.
3. Seluruh data customer dilindungi dengan RLS.
4. Pembayaran harus dapat diaudit dan diproses secara idempotent.
5. Publikasi undangan harus menggunakan snapshot konten dan versi template.
6. API publik hanya mengembalikan data yang memang aman untuk publik.
7. Validasi input dilakukan di server.
8. Kesalahan API menggunakan format respons yang konsisten.
9. Server Actions digunakan untuk operasi internal Next.js.
10. Route Handlers digunakan untuk integrasi HTTP dan layanan eksternal.

Dokumen ini menjadi acuan kontrak API ketika implementasi frontend, backend logic, database, dan integrasi pihak ketiga mulai dikembangkan.
