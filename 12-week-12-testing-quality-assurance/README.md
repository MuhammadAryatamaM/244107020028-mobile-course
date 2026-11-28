# Week 12 - Testing & Quality Assurance

## Tujuan

- Memahami piramida pengujian (unit, widget, integration) dan trade-off kecepatan vs keandalan
- Merancang strategi pengujian untuk fitur nyata dengan memisahkan logika bisnis dari UI
- Menguji kasus sukses, kasus tepi (edge cases), dan penanganan error/kegagalan
- Menguji kode asinkron dan mengganti dependensi eksternal (database/jaringan) menggunakan Fake Repository
- Menguji rendering UI, masukan tidak valid, dan interaksi pengguna dengan pengujian widget
- Menulis dan menjalankan pengujian integrasi (end-to-end) menggunakan package `integration_test`
- Menghasilkan laporan cakupan kode (`flutter test --coverage`) sebagai panduan kualitas

## Fitur Utama

- Tidak ada aplikasi yang dibuat, hanya testing

---

## Hasil yang Dicapai

### 1. Struktur Test Suite

Test suite dibagi menjadi tiga tingkatan terstruktur sesuai piramida testing:

```text
test/
├── unit/
│   ├── note_logic_test.dart       # Unit test entity Note & fungsi murni filter
│   └── search_usecase_test.dart   # Unit test use case & Riverpod provider via FakeRepo
├── widget/
│   └── notes_page_test.dart       # Widget test UI, empty states, dan user interactions
└── widget_test.dart               # Suite pengujian komprehensif bawaan
integration_test/
└── app_test.dart                  # End-to-end integration test alur utama aplikasi
```

---

### 2. Skenario Pengujian yang Diterapkan

| Tingkat Pengujian | Skenario Pengujian | Kategori | Hasil |
|---|---|---|:---:|
| **Unit** | `fromMap` menangani map kosong tanpa melempar exception | Kasus Tepi | **PASS** |
| **Unit** | `toMap` dan `fromMap` menjaga integritas data & flag `dirty` | Kasus Sukses | **PASS** |
| **Unit** | `filterNotesByTitle` memfilter judul secara case-insensitive | Kasus Sukses | **PASS** |
| **Unit** | Whitespace berlebih pada input pencarian dipangkas (*trimmed*) | Kasus Tepi | **PASS** |
| **Unit** | Query pencarian tanpa kecocokan menghasilkan list kosong | Kasus Negatif | **PASS** |
| **Unit / Async** | `SearchNotesUseCase` memanggil `fetchNotes()` saat query kosong | Kasus Sukses | **PASS** |
| **Unit / Async** | `SearchNotesUseCase` memanggil `searchNotes()` saat query terisi | Kasus Sukses | **PASS** |
| **Unit / Async** | Repository melempar exception ditangkap dengan aman oleh use case | Kasus Kegagalan | **PASS** |
| **Unit / Async** | Provider memancarkan `AsyncError` saat repository gagal | Kasus Kegagalan | **PASS** |
| **Widget** | Tampilan awal me-render `NotesAppBar`, `NotesSearchBar`, dan FAB | Tampilan UI | **PASS** |
| **Widget** | Menampilkan `NotesEmptyState` saat database belum memiliki catatan | Kondisi Awal | **PASS** |
| **Widget** | Menampilkan ikon `search_off` & pesan saat pencarian tidak cocok | Masukan Invalid | **PASS** |
| **Widget** | Tombol clear (X) mengembalikan daftar catatan semula | Tindakan User | **PASS** |
| **Widget** | Menekan FAB Add memicu penambahan item baru secara reaktif | Tindakan User | **PASS** |
| **Integration** | Alur lengkap: Buka tab -> Tambah note -> Cari cocok/tidak -> Reset | End-to-End | **PASS** |

---

### 3. Eksekusi Perintah & Bukti Mesin Hijau

#### A. Analisis Statis (Static Analysis)
```bash
$ flutter analyze
Analyzing week5_offline_notes...
No issues found! (ran in 2.5s)
```

#### B. Pengujian Unit & Widget dengan Coverage
```bash
$ flutter test --coverage
00:04 +28: All tests passed!
```
#### C. Pengujian Integrasi (Integration Test di Perangkat Linux)
```bash
$ flutter test integration_test/app_test.dart -d linux
00:03 +1: (tearDownAll)
00:03 +1: All tests passed!
```

---

## Catatan Temuan & Mitigasi

1. **Pemisahan Dependensi Database**:
   - Database SQLite sungguhan tidak cocok dijalankan di unit test karena ketergantungan native FFI dan persistensi disk.
   - *Mitigasi*: Dibuat `FakeNoteRepository` dan `InMemoryNoteRepository` yang mengimplementasikan `NoteRepositoryInterface`, sehingga test dapat dijalankan secara instan, deterministik, dan terisolasi.
2. **Ambiguity Finder pada Integration Test**:
   - Saat memeriksa input pencarian, teks yang diketik ke dalam `TextField` juga menghasilkan widget `EditableText` yang memuat teks yang sama dengan item `ListTile`.
   - *Mitigasi*: Menggunakan finder spesifik `find.widgetWithText(ListTile, ...)` atau `find.byType(ListTile)` untuk menghindari error multi-match.
