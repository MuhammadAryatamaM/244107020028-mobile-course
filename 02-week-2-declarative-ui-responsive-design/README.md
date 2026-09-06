# Week 2

## Tujuan

- Menjelaskan prinsip declarative UI dan hubungan antara widget, konfigurasi, serta state.
- Menggunakan StatelessWidget, StatefulWidget, Container, Row, Column, dan Expanded.
- Membedakan komponen Material 3 dan Cupertino untuk kebutuhan platform yang berbeda.
- Membangun layout responsif untuk ukuran layar mobile dan tablet.
- Menerapkan theme, dark mode, styling, dan aksesibilitas dasar.

## Fitur Utama

- Membuat aplikasi yang responsif
- Menggunakan komponen Material 3 atau Cupertino untuk UI
- Aksesibilitas untuk screen reader dan dark/light theme

## Hasil yang Dicapai

### Declarative UI

Pada pendekatan deklaratif, kode mendeskripsikan tampilan berdasarkan state saat ini. Ketika state berubah, Flutter membangun ulang bagian UI yang relevan. Developer berfokus pada hubungan data dan tampilan, bukan mengubah setiap elemen UI secara manual. `StatelessWidget` adalah elemen UI yang statis, cocok untuk UI yang output-nya ditentukan oleh konfigurasi dari parent. `StatefulWidget` adalah elemen UI yang dinamis, memiliki objek State untuk data yang dapat berubah (baik karena trigger pencet tombol atau rotate layar) selama lifecycle.

### Mengetahui `Expanded` dan `mainAxisSize` untuk Layout

`Expanded` untuk responsitivitas layar, mencegah overflow jika layar dipersempit. Latihan dengan menambah baris data baru.

<div align="center">

| Dengan `Expanded` | Tanpa `Expanded` | Tambah `No. Absen` |
| :---: | :---: | :---: |
| <img src="screenshots/with_expanded.png" height="200"> | <img src="screenshots/no_expanded.png" height="200"> | <img src="screenshots/add_absen.png" height="200"> |

</div>

`mainAxisSize` defaultnya adalah `max` dimana akan menjadi wrapper yang memenuhi seluruh `row` atau `column`, sebaliknya nilai `min` hanya memenuhi tempat seminimal mungkin untuk `children`

<div align="center">

| Dengan `min` | Dengan `max` |
| :---: | :---: |
| <img src="screenshots/main_axis_size_min.png" height="400"> | <img src="screenshots/main_axis_size_default.png" height="400"> |

</div>

### Menambah Aksesibilitas

`Semantics` adalah label yang bermakna pada elemen yang penting bagi screen reader. Tombol dark mode juga bisa ditaruh, dengan defaultnya bisa diset ke default system pengguna (`ThemeMode.system`) atau aplikasi, misal defaultnya dark. Ini contoh Semantic tombol Switch mode yang bisa dilihat dengan menambah `showSemanticsDebugger: true,` di `MaterialApp` dan adanya Dark Mode

<img src="screenshots/semantic.png" height="450" style="display: block; margin: 0 auto;">

<img src="screenshots/dark.png" height="450" style="display: block; margin: 0 auto;">

### Pilihan Desain Widget

`Material3` adalah widget dengan desain Android dan Cross-Platform, sementara `Cupertino` adalah widget dengan desain iOS. Misal perbedaan di tombol Switch dark mode

<div align="center">

| `Material3` | `Cupertino` |
| :---: | :---: |
| <img src="screenshots/material_switch.png" height="400"> | <img src="screenshots/cupertino_theme.png" height="400"> |

</div>

### Mengganti Jumlah Kolom Berdasarkan Lebar Layar

`LayoutBuilder` membaca ukuran layar, bisa digunakan untuk mengubah jumlah kolom/arah layout. kode `final columns = constraints.maxWidth >= 700 ? 2 : 1;` menentukan jumlah kolom dengan batasan tertentu (jika lebar layar >= 700px, kolomnya 2, else 1). Ini perbedaannya

<div align="center">

| Tambah Batasan (1000, lebar tapi masih 1 kolom) | Baseline (700, 1 kolom) | Kurangi Batasan (400, sempit tapi masih 2 kolom) |
| :---: | :---: | :---: |
| <img src="screenshots/more1000.png" height="300"> | <img src="screenshots/base700.png" height="300"> | <img src="screenshots/less400.png" height="300"> |

</div>

## AI Prompt Challenge

### 1. "Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya."

<div align="center">

| Jawaban AI | Rekomendasi + Alasan |
| :---: | :---: |
| <img src="screenshots/ai1.png" height="370"> | <img src="screenshots/ai1_result.png" height="370"> |

</div>

Jika diterapkan sesuai rekomendasi AI, hasilnya hanya berbeda di kasus ekstrim untuk layar sangat sempit

<div align="center">

| `GridView` | `LayoutBuilder` |
| :---: | :---: |
| <img src="screenshots/gridview.png" height="400"> | <img src="screenshots/layoutbuilder.png" height="400"> |

</div>

### 2. "Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya."

<img src="screenshots/ai2.png" height="450" width="70%" style="display: block; margin: 0 auto;">
<img src="screenshots/ai2_2.png" height="450" width="70%" style="display: block; margin: 0 auto;">

### 3. "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"

<img src="screenshots/ai3.png" height="450" style="display: block; margin: 0 auto;">

## Refactoring Challenge

### 1. Ekstrak kartu informasi menjadi widget reusable (misal InfoCard) yang menerima title dan value, sehingga tidak ada duplikasi widget.

`DashboardCard` diubah menjadi nama yang lebih generic `InfoCard` serta menambah `width` ke parameter agar tidak mendeklarasikan width tiap kartunya

<img src="screenshots/refactor1.png" width="40%" style="display: block; margin: 0 auto;">

### 2. Ganti warna dan ukuran yang di-hardcode dengan Theme.of(context) agar mengikuti tema terang/gelap secara otomatis.

Menambah variabel untuk tema default agar tidak diketik berkali-kali:
```
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
```

Warna diganti dengan color scheme primary (indigo) dengan `colorScheme.primary` dan teks style diganti dengan `textTheme`

<img src="screenshots/refactor2.png" width="40%" style="display: block; margin: 0 auto;">
<img src="screenshots/refactor2_2.png" width="40%" style="display: block; margin: 0 auto;">

### 3. Pindahkan breakpoint ke satu konstanta bernama (misal const kWideBreakpoint = 700;) agar hanya didefinisikan satu kali.

`const double kWideBreakpoint = 700;` ditaruh di awal kode, lalu `700` diganti dengan `kWideBreakpoint`

### 4. Jalankan flutter analyze dan pastikan tidak ada error maupun warning baru.

<img src="screenshots/analyze.png">

## Testing Dasar

Testing gagal karena `tester.getSize` hanya ingin menerima 1 elemen, tapi `Card` ada 4 elemen, karena itu errornya 'too many elements'

<img src="screenshots/test.png">

Cara memperbaikinya yaitu mengambil satu saja elemen, bisa pakai `first`

<img src="screenshots/test2.png">

