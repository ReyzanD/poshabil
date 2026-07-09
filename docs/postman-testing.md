# Tutorial Postman — POS API Testing

Panduan lengkap untuk menguji REST API aplikasi POS menggunakan Postman.

---

## 1. Persiapan

### 1.1 Jalankan Backend

Pastikan backend Laravel sudah berjalan:

```bash
cd laravel-api
php artisan serve
```

Backend akan berjalan di `http://localhost:8000`.

### 1.2 Jalankan Seeder (Data Awal)

```bash
php artisan db:seed
```

Data yang dibuat:

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@pos.test` | `password` |
| Kasir | `cashier@pos.test` | `password` |

3 kategori, 9 produk, dan 2 customer sudah tersedia.

---

## 2. Import Collection ke Postman

1. Buka **Postman**
2. Klik tombol **Import** (pojok kiri atas)
3. Pilih file `pos-api.postman_collection.json`
4. Klik **Import**

Collection akan muncul dengan nama **POS API**.

---

## 3. Set Variable (Environment)

Collection sudah memiliki 2 variable bawaan:

| Variable | Default Value | Keterangan |
|----------|---------------|------------|
| `base_url` | `http://localhost:8000` | URL backend |
| `token` | *(kosong)* | JWT token, terisi otomatis setelah login |

Jika port atau host berbeda, edit variable dengan cara:

1. Klik kanan collection **POS API**
2. Pilih **Edit** → tab **Variables**
3. Ubah nilai `base_url` sesuai kebutuhan
4. Klik **Save**
5. Pilih **POS API** sebagai environment aktif

---

## 4. Alur Testing

Ikuti urutan berikut untuk testing yang benar:

### Langkah 1: Login (dapatkan JWT Token)

1. Buka folder **Auth** → pilih **Login**
2. Body sudah diisi dengan akun admin:
   ```json
   {
     "email": "admin@pos.test",
     "password": "password"
   }
   ```
3. Klik **Send**
4. Token akan **tersimpan otomatis** ke variable `{{token}}`

> Jika ingin login sebagai kasir, ubah email menjadi `cashier@pos.test`.

### Langkah 2: Coba Endpoint Publik (Akses Tanpa Token)

Coba akses endpoint yang membutuhkan autentikasi **tanpa mengirim token** untuk melihat error 401:

1. Hapus header `Authorization` di tab **Headers**
2. Kirim request ke endpoint manapun
3. Response yang diharapkan:
   ```json
   {
     "message": "Unauthenticated."
   }
   ```

### Langkah 3: Cek User Saat Ini

1. Buka **Auth** → **Get Current User**
2. Klik **Send**
3. Response akan menampilkan data user yang sedang login:
   ```json
   {
     "id": 1,
     "name": "Admin",
     "email": "admin@pos.test",
     "role": "admin",
     ...
   }
   ```

### Langkah 4: Eksplorasi Endpoint Lain

Setelah login berhasil, semua endpoint sudah bisa diakses. Token akan otomatis terkirim melalui header `Authorization: Bearer {{token}}`.

---

## 5. Struktur Endpoint

### 5.1 Auth (Autentikasi)

| Endpoint | Method | Akses | Deskripsi |
|-----------|-------|------|-----------|
| `/api/auth/login` | POST | Publik | Login |
| `/api/auth/register` | POST | Admin | Registrasi user baru |
| `/api/auth/me` | GET | Login | Lihat user saat ini |
| `/api/auth/refresh` | POST | Login | Perbarui token JWT |
| `/api/auth/logout` | POST | Login | Logout |

Contoh body Register (Admin only):
```json
{
  "name": "Kasir Baru",
  "email": "kasir@pos.test",
  "password": "password123",
  "password_confirmation": "password123"
}
```

### 5.2 Dashboard (Statistik Toko)

| Endpoint | Method | Akses | Deskripsi |
|-----------|-------|------|-----------|
| `/api/dashboard/stats` | GET | Login | Statistik toko |

Response:
```json
{
  "total_products": 9,
  "total_categories": 3,
  "total_customers": 2,
  "total_transactions": 0,
  "today_revenue": 0,
  "monthly_revenue": 0,
  "recent_transactions": []
}
```

### 5.3 Categories (Kategori Produk)

| Endpoint | Method | Akses | Deskripsi |
|----------|-------|------|-----------|
| `/api/categories` | GET | Login | Daftar kategori + search |
| `/api/categories/{id}` | GET | Login | Detail kategori |
| `/api/categories` | POST | Admin | Tambah kategori |
| `/api/categories/{id}` | PUT | Admin | Ubah kategori |
| `/api/categories/{id}` | DELETE | Admin | Hapus kategori |

**GET Categories dengan search:**
```
GET /api/categories?search=Makanan
```

**Create Category:**
```json
{
  "name": "Kategori Baru",
  "description": "Deskripsi kategori"
}
```

### 5.4 Products (Produk)

| Endpoint | Method | Akses | Deskripsi |
|----------|-------|------|-----------|
| `/api/products` | GET | Login | Daftar produk + filter |
| `/api/products/{id}` | GET | Login | Detail produk |
| `/api/products` | POST | Admin | Tambah produk |
| `/api/products/{id}` | PUT | Admin | Ubah produk |
| `/api/products/{id}` | DELETE | Admin | Hapus produk |

**GET Products dengan filter:**
```
GET /api/products?search=Nasi&category_id=2&per_page=20
```

Parameter query:
- `search` — cari berdasarkan nama atau SKU
- `category_id` — filter berdasarkan kategori
- `per_page` — jumlah per halaman (default 20, maks 100)

**Create Product:**
```json
{
  "category_id": 1,
  "name": "Es Campur",
  "sku": "DRINK-005",
  "description": "Es campur spesial",
  "price": 15000,
  "stock": 50
}
```

Field `sku` harus **unik** — jika duplikat akan error 422.

### 5.5 Customers (Pelanggan)

| Endpoint | Method | Akses | Deskripsi |
|----------|-------|------|-----------|
| `/api/customers` | GET | Login | Daftar pelanggan + search |
| `/api/customers/{id}` | GET | Login | Detail pelanggan + transaksinya |
| `/api/customers` | POST | Admin | Tambah pelanggan |
| `/api/customers/{id}` | PUT | Admin | Ubah pelanggan |
| `/api/customers/{id}` | DELETE | Admin | Hapus pelanggan |

**GET Customers dengan search:**
```
GET /api/customers?search=Budi&per_page=20
```

Parameter query:
- `search` — cari berdasarkan nama, email, atau no. HP
- `per_page` — jumlah per halaman (aks 20, maks 100)

**Create Customer:**
```json
{
  "name": "Ahmad Rizki",
  "email": "ahmad@example.com",
  "phone": "081234567891",
  "address": "Jl. Diponegoro No. 5, Surabaya"
}
```

### 5.6 Transactions (Transaksi)

| Endpoint | Method | Akses | Deskripsi |
|----------|-------|------|-----------|
| `/api/transactions` | GET | Login | Daftar transaksi + filter |
| `/api/transactions` | POST | Login | Buat transaksi baru |
| `/api/transactions/{id}` | GET | Login | Detail transaksi |

**GET Transaksi dengan filter:**
```
GET /api/transactions?payment_method=cash&payment_status=paid&date_from=2025-01-01&date_to=2025-12-31&per_page=20
```

Parameter query:
- `payment_method` — filter: `cash`, `card`, `qris`
- `payment_status` — filter: `paid`, `pending`
- `date_from` — tanggal awal (format: `Y-m-d`)
- `date_to` — tanggal akhir (format: `Y-m-d`)
- `per_page` — jumlah per halaman

**Create Transaction:**
```json
{
  "customer_id": null,
  "payment_method": "cash",
  "items": [
    {
      "product_id": 4,
      "quantity": 2
    },
    {
      "product_id": 7,
      "quantity": 1
    }
  ]
}
```

> `customer_id` bisa diisi `null` (tanpa pelanggan). Saat membuat transaksi, stok produk akan **berkurang otomatis`. Jika stok tidak cukup, akan muncul error.

---

## 6. Role Authorization

| Role | Akses |
|------|-------|
| **Publik** | Login |
| **Login** | Semua GET, POST transaction, POST/DELETE/PUT logout/refresh/me |
| **Admin** | POST/PUT/DELETE categories, products, customers + registrasi user |

Cara test role authorization di Postman:

### Test Akses Kasir ke Endpoint Admin (harus 403 Forbidden)

1. Login sebagai **cashier** (ubah email di body Login menjadi `cashier@pos.test`)
2. Kirim request **Create Category** (POST `/api/categories`)
3. Response yang diharapkan: status **403**
   ```json
   {
     "message": "Access denied. Required role: admin"
   }
   ```

### Test Akses Endpoint Publik (Tidak Perlu Token)

1. Kirim **Login** dengan email dan password benar
2. Response akan selalu `200` dengan JWT token

### Test Akses tanpa Token (harus 401 Unauthorized)

1. Hapus header `Authorization` dari request
2. Kirim endpoint apapun yang membutuhkan autentikasi
3. Response yang diharapkan: **401**
   ```json
   {
     "message": "Unauthenticated."
   }
   ```

---

## 7. Validasi Error (422)

Contoh skenario validasi:

**Request tanpa field `name` (Create Category):**
POST `/api/categories` dengan body:
```json
{}
```

Response (422):
```json
{
  "name": ["The name field is required."]
}
```

**Product dengan SKU duplikat (422):**
```json
{
  "sku": ["The sku has already been taken."]
}
```

**Email tidak valid (422):**
```json
{
  "email": ["The email must be a valid email address."]
}
```

---

## 8. Skenario Testing Lengkap

Berikut urutan testing yang disarankan untuk memverifikasi semua fungsi:

### Sesi 1: Autentikasi
1. Login dengan akun admin → expect 200 + token
2. Me (cek user) → expect 200 + data admin
3. Refresh token → expect 200 + token baru
4. Register user baru → expect 201 + token
5. Logout → expect 200

### Sesi 2: Kategori
1. List kategori → expect 200 + array
2. List dengan search → expect 200 + filtered
3. Buat kategori baru → expect 201
4. Detail kategori → expect 200
5. Update kategori → expect 200
6. Hapus kategori → expect 200

### Sesi 3: Produk
1. List produk → expect 200 + pagination
2. List dengan filter → expect 200 + filtered
3. Buat produk baru → expect 201
4. Detail produk → expect 200 + category relation
5. Update produk → expect 200
6. Hapus produk → expect 200

### Sesi 4: Customer
1. List customer → expect 200 + pagination
2. List dengan search → expect 200 + filtered
3. Buat customer → expect 201
4. Detail customer → expect 200 + transactions
5. Update → expect 200
6. Hapus → expect 200

### Sesi 5: Transaksi
1. List transaksi → expect 200 (mungkin kosong)
2. Buat transaksi dengan stok cukup → expect 201
3. Detail transaksi → expect 200 + items
4. Coba buat transaksi dengan stok tidak cukup → expect 400

### Sesi 6: Role Authorization
1. Login sebagai kasir (`cashier@pos.test` / `password`)
2. Coba akses POST category → expect 403
3. Coba akses POST product → expect 403
4. Coba akses POST customer → expect 403

---

## 8. Tips & Troubleshooting

| Masalah | Solusi |
|---------|--------|
| **Error 401** | Token tidak valid, belum login, atau sudah expired. Login ulang. |
| **Error 403** | Akun tidak punya akses (role admin diperlukan). |
| **Error 404** | ID tidak ditemukan. Cek apakah data dengan ID tersebut ada. |
| **Error 422** | Validasi gagal. Cek response body untuk field yang salah. |
| **Error 500** | Error server. Cek terminal Laravel untuk detail. |
| **Token expired** | Panggil **Refresh Token** atau login ulang. Default expiry 60 menit. |
| **Stok tidak cukup** | Cek stok produk saat membuat transaksi. |

### Reset Data

Untuk mereset database ke data awal:

```bash
php artisan migrate:fresh --seed
```