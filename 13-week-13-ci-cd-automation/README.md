# Week 13 - CI/CD & Automation

## Tujuan

- Memahami konsep dasar CI/CD (Continuous Integration & Continuous Delivery) dalam pengembangan aplikasi Flutter
- Menyusun alur kerja otomatisasi (workflow pipeline) menggunakan GitHub Actions
- Mengonfigurasi quality gate otomatis: verifikasi format kode (`dart format`), analisis linter ketat (`flutter analyze --fatal-infos`), dan pengujian otomatis dengan cakupan kode (`flutter test --coverage`)
- Membangun artefak rilis Android secara otomatis: APK (`.apk`) untuk pengujian internal dan App Bundle (`.aab`) untuk distribusi Google Play
- Mengunggah dan menyimpan artefak rilis menggunakan `actions/upload-artifact@v4` dengan retensi 7 hari
- Memahami strategi versioning (Semantic Versioning) dan pengelolaan rahasia (*secrets*) serta risiko keamanan

---

## Fitur Utama Pipeline CI/CD

- Multi-Event Trigger yang otomatis menjalankan pada setiap `push` dan `pull_request` ke branch `main`, serta mendukung eksekusi manual via `workflow_dispatch`.
- Menggunakan `cancel-in-progress: true` untuk membatalkan proses build lama secara otomatis saat commit baru didorong ke branch yang sama.
- Strict Quality Assurance:
  1. `dart format --output=none --set-exit-if-changed .`: Memastikan seluruh berkas Dart konsisten dengan konvensi resmi.
  2. `flutter analyze --fatal-infos`: Mencegah merge jika terdapat peringatan atau kesalahan kode.
  3. `flutter test --coverage`: Menjalankan suite pengujian unit & widget dan menghasilkan laporan LCOV.
- Automated Android Release Build:
  1. `flutter build apk --release` -> Menghasilkan `app-release.apk`.
  2. `flutter build appbundle --release` -> Menghasilkan `app-release.aab`.
- Artifact Archiving: Artefak hasil build diarsipkan otomatis di GitHub Actions Artifacts (`android-builds`).

---

## Hasil yang Dicapai

### 1. File Konfigurasi Workflow (`.github/workflows/flutter-ci.yml`)

```yaml
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Java JDK
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Verify code formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Static code analysis
        run: flutter analyze --fatal-infos

      - name: Run unit & widget test suite with coverage
        run: flutter test --coverage

      - name: Build Android APK (Release)
        run: flutter build apk --release

      - name: Build Android App Bundle (Release)
        run: flutter build appbundle --release

      - name: Upload Android Release Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-builds
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
          if-no-files-found: error
          retention-days: 7
```

---

### 2. Verifikasi Tahapan Pipeline Secara Lokal

Sebelum mendorong perubahan ke remote repository, seluruh tahapan pemeriksaan dieksekusi secara lokal untuk menjamin pipeline tidak mengalami kegagalan:

#### A. Verifikasi Format Dart
```bash
$ dart format --output=none --set-exit-if-changed .
Formatted 32 files (0 changed) in 0.11 seconds.
```

#### B. Analisis Kode Linter Ketat
```bash
$ flutter analyze --fatal-infos
Analyzing week5_offline_notes...
No issues found! (ran in 3.3s)
```

#### C. Pengujian Otomatis & Coverage
```bash
$ flutter test --coverage
00:04 +28: All tests passed!
```

---

## Strategi Versioning & Manajemen Rahasia

### 1. Semantic Versioning (`pubspec.yaml`)
Penomoran versi mengikuti kaidah `MAJOR.MINOR.PATCH+BUILD_NUMBER`:
- Versi saat ini: `1.0.0+1`
- Versi rilis berikutnya: `1.1.0+2` (menandai penambahan fitur pengujian otomatis dan pipeline CI/CD).
- Git Tagging: Menggunakan tag Git seperti `v1.0.0` pada commit branch utama yang telah lolos verifikasi pipeline untuk menghubungkan source code dengan artefak rilis.

### 2. Praktik Keamanan & Manajemen Secrets
- Hindari hardcoded secrets seperti API Key privat (Gemini API key, Firebase service account, Google Play upload keystore) disimpan di dalam kode sumber maupun file yaml workflow.
- Variabel sensitif wajib disimpan di menu repository *Settings -> Secrets and variables -> Actions*.
- Keystore produksi dan password signing hanya boleh diinjeksikan pada workflow rilis khusus, bukan pada workflow pull request umum yang dapat dieksploitasi oleh kontributor eksternal.
