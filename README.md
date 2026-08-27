 dockerd

# 📱 Learning App — Workshop Pengembangan Android

Project Flutter yang dibangun dengan struktur arsitektur modular, state management terpusat, declarative routing, serta networking HTTP siap pakai.

---

## 🚀 Tech Stack & Libraries

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [`provider`](https://pub.dev/packages/provider)
- **Routing**: [`go_router`](https://pub.dev/packages/go_router)
- **HTTP Client**: [`dio`](https://pub.dev/packages/dio) (dengan request/response logging interceptor)
- **Local Storage**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **UI & Utilities**:
  - [`intl`](https://pub.dev/packages/intl) (Date, number & currency formatting)
  - [`flutter_svg`](https://pub.dev/packages/flutter_svg) (Vector graphics)
  - [`cached_network_image`](https://pub.dev/packages/cached_network_image) (Image caching)
  - [`logger`](https://pub.dev/packages/logger) (Pretty debugging logger)
  - [`equatable`](https://pub.dev/packages/equatable) (Value equality)

---

## 📂 Struktur Direktori

```text
lib/
├── main.dart                 # Entry point aplikasi
├── app.dart                  # Konfigurasi MaterialApp.router & AppTheme
├── core/
│   ├── constants/            # Konstanta global (API URL, timeout, storage keys)
│   ├── theme/                # Pengaturan tema Material 3 (Light & Dark mode)
│   └── utils/                # Helper functions (format tanggal, rupiah, validasi)
├── models/                   # Data transfer objects (DTO) & entities
├── providers/                # State management ChangeNotifier / Providers
├── routes/                   # Definisi rute navigasi aplikasi (GoRouter)
├── screens/                  # Halaman / screen aplikasi
│   └── home/                 # Contoh modul HomeScreen
├── services/                 # Layanan API (Dio HTTP client wrapper)
└── widgets/                  # Reusable UI widgets
```

---

## 🛠️ Memulai (Getting Started)

Bagi kolaborator / yang baru clone project ini:

### 1. Prasyarat (Prerequisites)

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.24.x ke atas)
- [Android Studio](https://developer.android.com/studio) dengan Android SDK Command-line Tools & Platform SDK
- VS Code / Android Studio dengan ekstensi Flutter & Dart

### 2. Instalasi Dependencies

Jalankan perintah ini di root direktori project untuk mengunduh semua package:

```bash
flutter pub get
```

### 3. Menjalankan Aplikasi (Run App)

#### Opsi A: Menggunakan HP Android Fisik (Direkomendasikan ⚡)

1. Aktifkan **Developer Options** & **USB Debugging** di HP Android kamu.
2. Hubungkan HP ke laptop/komputer via kabel data USB.
3. Jalankan:
   ```bash
   flutter run
   ```

#### Opsi B: Menggunakan Android Emulator

1. Buka emulator melalui Android Studio atau terminal:
   ```bash
   flutter emulators --launch flutter_emulator
   ```
2. Tunggu hingga layar emulator masuk ke Home Screen, lalu jalankan:
   ```bash
   flutter run
   ```

#### Opsi C: Menggunakan Browser (Chrome)

```bash
flutter run -d chrome
```

---

## ⌨️ Perintah Interaktif (Interactive Commands)

Saat aplikasi sedang berjalan via `flutter run`:

- **`r`** : Hot Reload (memperbarui perubahan UI secara instan)
- **`R`** : Hot Restart (mereset state aplikasi)
- **`h`** : Menampilkan daftar bantuan command
- **`q`** : Keluar / menghentikan aplikasi

---

## 🧪 Testing & Code Quality

Untuk memastikan tidak ada error sintaks atau issue linter:

```bash
# Static analysis
flutter analyze

# Unit & widget test
flutter test
```
