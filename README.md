# Aplikasi POS (Point of Sale)

Aplikasi **POS (Point of Sale)** berbasis Laravel API + Flutter. Cocok untuk mengelola transaksi, produk, kategori, dan pelanggan.

## 📁 Struktur Project

```
pos1/
├── laravel-api/        # Backend REST API (Laravel 13)
└── pos/                # Frontend Mobile (Flutter)
```

## 🛠️ Prasyarat

Sebelum memulai, pastikan sudah terinstall:

| Tools | Minimal Versi |
|-------|---------------|
| PHP | ^8.3 |
| Composer | 2.x |
| MySQL / MariaDB | 5.7+ |
| Flutter | ^3.11 |
| Dart | ^3.11 |
| Node.js & NPM | 18+ / 9+ |

## 🚀 Cara Install & Menjalankan

### 1. Clone Repository

```bash
git clone <url-repo> pos1
cd pos1
```

### 2. Setup Backend (Laravel API)

```bash
cd laravel-api

# Copy file environment
cp .env.example .env

# Install dependency PHP
composer install

# Generate APP_KEY
php artisan key:generate

# Generate JWT secret
php artisan jwt:secret
```

**Konfigurasi Database**

Edit file `.env` dan sesuaikan dengan kredensial lokal kamu:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=pos
DB_USERNAME=root
DB_PASSWORD=
```

Lalu jalankan:

```bash
# Buat database-nya dulu di PHPMyAdmin / MySQL CLI
mysql -u root -e "CREATE DATABASE pos;"

# Jalankan migrasi
php artisan migrate

# Isi data awal (seeder)
php artisan db:seed
```

**Jalankan server backend:**

```bash
php artisan serve
```

Backend akan berjalan di `http://localhost:8000`.

### 3. Setup Frontend (Flutter)

Buka terminal baru, lalu:

```bash
cd pos

# Install dependency Flutter
flutter pub get

# Jalankan aplikasi
flutter run
```

> **Catatan untuk Android Emulator:** Secara otomatis akan mengarah ke `10.0.2.2:8000` (localhost dari sisi emulator).
>
> **Untuk device fisik / custom:** Edit URL API di `pos/lib/core/constants/api_constants.dart`.

## 👤 Akun Default (Seeded)

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@pos.test` | `password` |
| Cashier | `cashier@pos.test` | `password` |

## 🔐 Hak Akses

- **Admin** — bisa CRUD kategori, produk, pelanggan, dan melihat transaksi
- **Cashier** — hanya bisa melihat data dan membuat transaksi

## 📦 Fitur

- ✅ Autentikasi JWT (login/logout/register)
- ✅ Dashboard dengan statistik
- ✅ Manajemen Kategori
- ✅ Manajemen Produk
- ✅ Manajemen Pelanggan
- ✅ Manajemen Transaksi
- ✅ UI dengan animasi glassmorphism
- ✅ Role-based access control

## 🧪 Menjalankan Test

```bash
# Backend
cd laravel-api
php artisan test

# Flutter
cd pos
flutter test
```
