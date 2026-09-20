[Week 1](#week-1--mobile-development-ecosystem--flutter-refresh) | [Week 2](#week-2--declarative-ui--responsive-design) | [Week 3](#week-3-navigation--state-management) | [Week 4](#week-4-networking--rest-api) | [Week 5](#week-5-local-storage--offline-first) | [Week 6](#week-6-authentication-security--fcm) | [Week 7](#week-7-clean-architecture) | [Week 9](#week-9-ai-assisted-development--vibe-coding) | [Week 10](#week-10-ai-feature-integration) | [Week 11](#week-11-performance-optimization) | [Week 12](#week-12-testing--quality-assurance) | [Week 13](#week-13-cicd--automation) | [Week 14](#week-14-deployment--monitoring) | [Week 15](#week-15-secure-mobile-development)

# Week 1:  Mobile Development Ecosystem & Flutter Refresh

## Kapan native lebih tepat dipilih daripada cross-platform?
- Aplikasi memang hanya ditargetkan ke platform itu 
-  Membutuhkan performa maksimal
- Membutuhkan integrasi alat hardware-specific

## Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?

UI dideklarasikan sebagai fungsi dari state menggunakan widget tree. Ketika state berubah, Flutter membangun ulang bagian widget tree yang terpengaruh dengan state yang baru. Flutter membandingkan widget tree lama dan baru, lalu memperbarui UI di layar hanya pada bagian yang berubah.

## Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?

Karena akan jelas perubahan tertentu itu memengaruhi file yang mana, memudahkan tim/orang lain untuk membaca atau mencari perubahan. Commit yang rapi juga menunjukkan profesionalisme untuk portfolio. Commit file banyak dengan pesan ambigu/tidak jelas akan menyulitkan tim, misalnya saat debugging.

# Week 2:  Declarative UI & Responsive Design

## Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?

Imperative fokus pada langkah-langkah bagaimana memanipulasi UI secara manual, mencari elemennya lalu memberikan perintah satu per satu untuk mengubah warna atau teksnya setiap kali terjadi aksi. Declarative fokus mendeskripsikan seperti apa bentuk UI berdasarkan kondisi state saat ini, cukup memperbarui variabel datanya saja, dan framework menggambar ulang seluruh tampilan agar sesuai dengan kondisi data yang baru. 

## Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?

Expanded membantu saat butuh responsitivas (most of the time berhasil), tapi kadang bisa overflow jika elemen expandednya ke kanan tapi elemennya punya fixed height, membuatnya tidak bisa kemana-mana. Expanded juga bisa menghasilkan error jika ditaruh di elemen yang size nya tak hingga karena Expanded mengambil sisa ruang yang ada

## Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?

Breakpoint mengatur kapan suatu elemen bisa berubah layoutnya bergantung pada ukuran atau orientasi layar, misal jika layar lebar bisa muat 2 kolom, maka layar sempit tidak bisa dipaksa untuk muat 2 kolom, lebih baik 1 kolom. Theme juga berpengaruh ke preferensi user nyamannya bagaimana (light/dark) dan overall design UI juga

## Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?

Semua fitur berjalan dengan normal, tidak ada yang error, dan yang ditanyakan terjawab dengan baik seperti aksesibilitasnya, responsivitas, layout, dll

# Week 3: Navigation & State Management

## Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?

`setState` cukup untuk mengelola state yang bersifat lokal, sementara, dan hanya relevan untuk UI di satu layar tersebut (misalnya untuk mengontrol jalannya animasi, menyembunyikan/menampilkan menu dropdown, atau menyimpan isian karakter sementara pada TextField). Riverpod cocok jika menjadi global, ketika data tersebut mulai dibutuhkan oleh layar/halaman lain, memiliki logika bisnis yang rumit, atau ketika ingin datanya tetap aman tersimpan di memori meskipun pengguna sudah menavigasi keluar dan kembali lagi ke halaman tersebut di lain waktu

## Apa perbedaan context.go dan context.push, dan kapan masing-masing tepat digunakan?

`context.go` membuang tumpukan lama dan membentuk struktur halaman baru sesuai rutenya, digunakan untuk berpindah antar Tab menu utama atau forward paksa pengguna ke layar Login agar mereka tidak bisa menekan tombol Back

`context.push` meminjam halaman baru dan sekadar menumpuk di atas layar saat ini, digunakan untuk alur pendalaman, misal dari halaman "Daftar Produk" ke halaman "Detail Produk", dimana wajib ada tombol Back agar pengguna bisa kembali ke halaman asal

## Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?

Riverpod memaksa data hanya bisa berada di satu kondisi pasti dalam satu waktu, jika ia berubah menjadi Error, maka Loading otomatis musnah di detik itu juga, sehingga mustahil terjadi bentrok tampilan di aplikasi

## Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?

Di menu utama (provider dan page), tidak ada yang diubah karena sesuai dengan prompt. Hanya bagian test yang error, dan diperbaiki karena itu

# Week 4: Networking & REST API

## Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?

Memanggil Dio secara langsung dari UI melanggar prinsip Separation of Concerns (SoC) dan arsitektur Clean Code, membuat UI terikat dengan mekanisme pengambilan data. Jika aturan dilanggar, UI akan menjadi sulit diuji karena memerlukan HTTP client langsung di komponen tampilan, kode menjadi sulit dipelihara akibat logika bisnis berserakan di widget, dan aplikasi menjadi kaku di mana perubahan endpoint, header API, atau migrasi library HTTP di masa depan akan memaksa untuk merombak kode di seluruh file UI aplikasi

## Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (_page/_limit)?

- Pagination Client-Side artinya download semua data, baru menampilkannya misal 20 demi 20 di aplikasi. Cukup kalau data bersifat statis dan berukuran kecil.                                                                                                                 
- Pagination Server-Sidea artinya meminta data dari database server sesuai yang dilihat pengguna misal hanya 10 item. Wajib jika data berpotensi tumbuh tanpa batas (ribuan hingga jutaan)                             

## Bagaimana exception repository berubah menjadi AsyncError tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?

Saat mengembalikan sebuah Future di dalam method `build()` milik AsyncNotifier maupun FutureProvider, Riverpod sudah ada try/catch-nya sendiri. Ketika fetchPosts() melempar error jaringan, Riverpod akan menangkapnya dan otomatis menghentikan status Loading, lalu mengubah state menjadi tipe AsyncError. Di UI, pakai `.when(error: ...)` untuk menanganinya. Gunakan try/catch eksplisit saat mutasi data dari aksi user (tambah/edit/hapus/refresh manual) yang berada di luar `build()` Riverpod

## Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?

Tidak ada yang diperbaiki

# Week 5: Local Storage & Offline First

# Week 6: Authentication, Security & FCM

# Week 7: Clean Architecture

# Week 9: AI-assisted Development / Vibe Coding

# Week 10: AI Feature Integration

# Week 11: Performance Optimization

# Week 12: Testing & Quality Assurance

# Week 13: CI/CD & Automation

# Week 14: Deployment & Monitoring

# Week 15: Secure Mobile Development
