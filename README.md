# 💧 AquaReminder - Water Drinking Reminder App

<div align="center">
  <img src="assets/images/logo.png" alt="AquaReminder Logo" width="120" height="120">
  
  **Jaga Hidrasi, Jaga Kesehatan**
  
  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![GitHub issues](https://img.shields.io/github/issues/SiNopaal/Aplikasi-AquaReminder)](https://github.com/aquareminder-team/aquareminder/issues)
  [![GitHub stars](https://img.shields.io/github/stars/SiNopaal/Aplikasi-AquaReminder)](https://github.com/aquareminder-team/aquareminder/stargazers)
</div>

---

## 📖 Tentang AquaReminder

**AquaReminder** adalah aplikasi mobile yang membantu Anda menjaga pola konsumsi air harian dengan sistem pengingat cerdas dan tracking yang akurat. Aplikasi ini dikembangkan menggunakan Flutter untuk memberikan pengalaman pengguna yang optimal di platform Android dan iOS.

### 🎯 Mengapa AquaReminder?

- **🚫 Problem:** Banyak orang lupa minum air yang cukup setiap hari
- **💡 Solution:** Pengingat cerdas dengan tracking konsumsi yang mudah dan akurat
- **🎯 Goal:** Membantu pengguna membentuk kebiasaan hidrasi yang sehat

---

## ✨ Fitur Utama

### 🔐 **Sistem Autentikasi Lengkap**
- ✅ Registrasi dengan validasi profil lengkap
- ✅ Login aman dengan session management
- ✅ Reset password dengan kode verifikasi
- ✅ Logout dengan konfirmasi keamanan

### 💧 **Manajemen Konsumsi Air**
- ✅ **Target Otomatis:** Perhitungan berdasarkan berat badan & tingkat aktivitas
- ✅ **Input Fleksibel:** Quick selection (100ml, 200ml, 250ml, 300ml, 500ml) atau input manual
- ✅ **Real-time Tracking:** Update progress secara langsung
- ✅ **Reset Progress:** Fitur reset manual untuk memulai dari awal

### 📊 **Monitoring & Analytics**
- ✅ **Progress Harian:** Visual progress dengan circular indicator
- ✅ **Grafik Mingguan:** Trend analysis konsumsi 7 hari terakhir
- ✅ **Riwayat Lengkap:** History konsumsi dengan timestamp detail
- ✅ **Achievement System:** Notifikasi ketika target tercapai

### 🔔 **Sistem Pengingat Cerdas**
- ✅ **Notifikasi Berkala:** Interval dapat disesuaikan (1-6 jam)
- ✅ **Local Notifications:** Bekerja tanpa koneksi internet
- ✅ **Pesan Motivasi:** Encouraging messages untuk konsistensi
- ✅ **Customizable:** Pengaturan reminder sesuai kebutuhan

### 👤 **Manajemen Profil**
- ✅ **Edit Profil:** Update berat badan dan tingkat aktivitas
- ✅ **Target Dinamis:** Recalculation otomatis berdasarkan perubahan profil
- ✅ **Data Validation:** Input validation untuk keamanan data

---


## 🚀 Instalasi & Setup

### Prerequisites

Pastikan Anda telah menginstall:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.0 atau lebih baru)
- [Dart SDK](https://dart.dev/get-dart) (versi 2.17 atau lebih baru)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- Android SDK dan emulator atau device fisik

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/aquareminder-team/aquareminder.git
   cd aquareminder
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

4. **Build APK (Opsional)**
   ```bash
   flutter build apk --release
   ```

### Konfigurasi Tambahan

#### Android Permissions
Aplikasi memerlukan permission berikut (sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

#### Notification Setup
Untuk notifikasi lokal, pastikan:
- Target SDK minimal Android 5.0 (API level 21)
- Notification permission granted (otomatis diminta saat pertama kali)

---
### Database Schema

#### Tabel `tb_user`
```sql
CREATE TABLE tb_user (
  id_user INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  nama TEXT NOT NULL,
  berat_badan INTEGER NOT NULL,
  aktivitas INTEGER NOT NULL,        -- 1: Ringan, 2: Sedang, 3: Berat
  target_harian INTEGER NOT NULL,
  created_at TEXT NOT NULL
);
```

#### Tabel `tb_konsumsi`
```sql
CREATE TABLE tb_konsumsi (
  id_log INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  waktu TEXT NOT NULL,              -- Format: HH:mm:ss
  volume INTEGER NOT NULL,          -- Volume dalam ml
  tanggal TEXT NOT NULL,            -- Format: yyyy-MM-dd
  FOREIGN KEY (user_id) REFERENCES tb_user (id_user)
);
```

#### Tabel `tb_pengingat`
```sql
CREATE TABLE tb_pengingat (
  id_reminder INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  interval_jam INTEGER NOT NULL,    -- Interval dalam jam (1-6)
  is_active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (user_id) REFERENCES tb_user (id_user)
);
```

---

## 🧮 Smart Calculation Algorithm

### Formula Perhitungan Target Harian
```dart
Target = Berat Badan (kg) × 35ml × Faktor Aktivitas

Faktor Aktivitas:
- Ringan (1.0x): Aktivitas sehari-hari biasa
- Sedang (1.2x): Olahraga 3-4x seminggu  
- Berat (1.5x): Olahraga intensif setiap hari
```

### Contoh Perhitungan
```dart
// User: Berat 70kg, Aktivitas Sedang
int targetHarian = 70 * 35 * 1.2; // = 2,940ml/hari

// Progress calculation
double progress = (totalKonsumsi / targetHarian) * 100;
```

---

## 🎯 Cara Penggunaan

### 1. **Registrasi Akun Baru**
- Buka aplikasi dan pilih "Daftar di sini"
- Isi form registrasi dengan data lengkap:
  - Nama lengkap
  - Email (harus valid dan unik)
  - Password (minimal 6 karakter)
  - Berat badan (30-200 kg)
  - Tingkat aktivitas (Ringan/Sedang/Berat)
- Target harian akan dihitung otomatis
- Klik "Daftar" untuk membuat akun

### 2. **Login ke Aplikasi**
- Masukkan email dan password yang sudah terdaftar
- Klik "Masuk" untuk mengakses dashboard
- Gunakan "Lupa Password?" jika lupa kredensial

### 3. **Mencatat Konsumsi Air**
- Di dashboard, klik tombol "+" atau "Catat Minum"
- Pilih volume dari quick selection atau input manual
- Klik "Simpan" untuk mencatat konsumsi
- Progress akan terupdate secara real-time

### 4. **Mengatur Pengingat**
- Masuk ke menu "Settings"
- Atur interval pengingat (1-6 jam)
- Pengingat akan aktif otomatis
- Notifikasi akan muncul sesuai interval yang dipilih

### 5. **Melihat Analytics**
- Dashboard menampilkan progress harian
- Settings menampilkan grafik mingguan
- Riwayat konsumsi tersedia di dashboard
- Data dapat di-reset manual jika diperlukan

---

## 🛠️ Teknologi yang Digunakan

| Kategori | Teknologi | Versi | Deskripsi |
|----------|-----------|-------|-----------|
| **Framework** | Flutter | 3.0+ | Cross-platform mobile development |
| **Language** | Dart | 2.17+ | Programming language untuk Flutter |
| **Database** | SQLite | Latest | Local database storage |
| **State Management** | StatefulWidget | Built-in | Flutter's built-in state management |
| **UI Framework** | Material Design 3 | Latest | Modern UI design system |
| **Charts** | FL Chart | ^0.66.2 | Beautiful charts untuk analytics |
| **Notifications** | Flutter Local Notifications | ^16.3.2 | Local push notifications |
| **Storage** | Shared Preferences | ^2.2.2 | Simple key-value storage |
| **Permissions** | Permission Handler | ^11.2.0 | Handle app permissions |
| **Date/Time** | Intl | ^0.19.0 | Internationalization dan date formatting |

---

## 🧪 Testing

### Menjalankan Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
```

### Test Structure
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/
│   └── screens/
└── integration/
    └── app_test.dart
```

---

## 📦 Dependencies

### Production Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  sqflite: ^2.3.0              # SQLite database
  path: ^1.8.3                 # Path manipulation
  flutter_local_notifications: ^16.3.2  # Local notifications
  permission_handler: ^11.2.0  # Permission management
  fl_chart: ^0.66.2            # Charts dan graphs
  shared_preferences: ^2.2.2   # Simple storage
  intl: ^0.19.0                # Date formatting
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0        # Linting rules
  integration_test:
    sdk: flutter
```

---

## 🚀 Roadmap

### 📅 **Phase 1 - Current (Q1 2025)**
- ✅ Basic authentication system
- ✅ Water intake tracking
- ✅ Local notifications
- ✅ Weekly analytics
- ✅ Manual progress reset

### 📅 **Phase 2 - Q2 2025**
- 🔄 Cloud synchronization dengan Firebase
- 🔄 Social features (challenges, leaderboard)
- 🔄 Advanced analytics dengan Machine Learning
- 🔄 Integration dengan health apps (Google Fit, Apple Health)
- 🔄 Dark mode support

### 📅 **Phase 3 - Q3 2025**
- 🔄 Wearable device integration (smartwatch)
- 🔄 Voice commands dan voice notifications
- 🔄 Personalized recommendations
- 🔄 Premium features subscription
- 🔄 Export data (PDF, CSV)

### 📅 **Phase 4 - Q4 2025**
- 🔄 Multi-language support (English, Indonesian, etc.)
- 🔄 Telemedicine integration
- 🔄 Corporate wellness programs
- 🔄 AI-powered insights dan predictions
- 🔄 Widget untuk home screen

---

## 🤝 Contributing

Kami menyambut kontribusi dari komunitas! Berikut cara berkontribusi:

### Langkah Kontribusi
1. **Fork** repository ini
2. **Create** branch baru (`git checkout -b feature/AmazingFeature`)
3. **Commit** perubahan (`git commit -m 'Add some AmazingFeature'`)
4. **Push** ke branch (`git push origin feature/AmazingFeature`)
5. **Open** Pull Request

### Guidelines
- Ikuti [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Tulis tests untuk fitur baru
- Update dokumentasi jika diperlukan
- Pastikan semua tests pass sebelum submit PR

### Code of Conduct
- Bersikap profesional dan respectful
- Fokus pada improvement, bukan kritik personal
- Bantu newcomers dan jawab pertanyaan dengan sabar

---
## 📄 License

Proyek ini dilisensikan di bawah [MIT License](LICENSE) - lihat file LICENSE untuk detail lengkap.

```
MIT License

Copyright (c) 2025 AquaReminder Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
<div align="center">

### 💧 **AquaReminder**
### *Jaga Hidrasi, Jaga Kesehatan*

**"Setiap tetes air yang kamu minum hari ini adalah investasi untuk kesehatan masa depanmu"**

---

⭐ **Jika aplikasi ini bermanfaat, jangan lupa berikan star!** ⭐

[⬆ Kembali ke atas](#-aquareminder---water-drinking-reminder-app)

</div>
