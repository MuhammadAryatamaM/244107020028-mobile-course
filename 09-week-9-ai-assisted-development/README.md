# Week 9

## Tujuan

- Menjelaskan workflow AI-assisted development (prompt, generate, verify, test, refactor, explain)
- Menulis prompt dan konteks yang efektif untuk fitur Flutter kecil
- Mengenali halusinasi dan keterbatasan AI pada kode Flutter
- Melakukan debugging dan refactoring kode hasil AI ke Clean Architecture
- Menguji kode hasil AI dengan flutter analyze dan test
- Mendokumentasikan prompt, hasil AI, dan keputusan terima/tolak

## Fitur Utama

- Tidak ada aplikasi yang dibangun, hanya prakter AI-assited development

## Hasil yang Dicapai

### Struktur Prompt

Satu prompt baik mengisi lima slot secara singkat: Peran, konteks, tugas, batas, dan output
<img src="screenshots/prompt.png" style="display: block; margin: 0 auto;">
<img src="screenshots/prompt2.png" style="display: block; margin: 0 auto;">
<img src="screenshots/prompt3.png" style="display: block; margin: 0 auto;">

### Selalu Verifikasi Hasil

<img src="screenshots/verif.png" style="display: block; margin: 0 auto;">

## AI Challenge

<img src="screenshots/prompt4.png" style="display: block; margin: 0 auto;">
<img src="screenshots/prompt5.png" style="display: block; margin: 0 auto;">
<img src="screenshots/prompt6.png" style="display: block; margin: 0 auto;">

### Minimal 1 temuan AI terbukti benar (bukti grep/test) lalu diperbaiki.

SQL Wildcard Injection di `note_repository.dart`: `where: 'title LIKE ?', whereArgs: ['%$query%']`. Jika user mencari karakter % atau _, SQLite memperlakukannya sebagai wildcard (% = sembarang string, _ = sembarang 1 karakter), bukan teks literal, membuat pencarian % mengembalikan seluruh catatan tanpa filter. Diperbaiki dengan secara eksplisit membuat Escape Character (`\`) untuk wildcard.

### Minimal 1 temuan AI ditolak dengan alasan teknis tertulis.

Usulan me-refactor seluruh routing navigasi atau me-mock go_router secara penuh dalam widget test. Kode mock duplikat (`_SearchResultBody`) ditolak karena tidak mencerminkan production widget. Ditulis ulang manual agar menguji NotesPage langsung via simulasi `tester.enterText()`

### Keputusan tiap file: terima, terima + refactor, atau tolak + tulis manual.

- `note_repository.dart`: Terima + Refactor   
- `search_notes_use_case.dart`: Terima + Refactor
- `notes_page.dart`: Terima
- `widget_test.dart`: Tolak + Tulis Manual

## Refactoring Challenge

### Perkecil hasil AI di atas 80 baris menjadi fungsi/use case kecil yang bisa diuji.

`notes_page.dart` (203 baris) dipecah menjadi widget kecil:
- `notes_page.dart`: Hanya mengorkestrasi layout utama halaman (app bar, search bar, list notes / empty state, dan FAB).
- `notes_app_bar.dart`: Menangani switch offline, badge dirty count, dan aksi trigger sync.
- `notes_search_bar.dart`: Menangani input pencarian, tombol clear, dan binding dengan state query.
- `notes_empty_state.dart`: Komponen khusus empty state (baik saat pencarian tidak cocok maupun saat belum ada data).

### Pindahkan filter/search dari widget ke use case domain yang murni.

Memisahkan dependensi UI/Riverpod dari domain logic sehingga dapat diuji secara terisolasi tanpa framework UI:
- Pure Filter Function `filterNotesByTitle`:
```
    List<Note> filterNotesByTitle(List<Note> notes, String query) {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return notes;
      return notes
          .where((note) => note.title.toLowerCase().contains(cleanQuery))
          .toList();
    }
``` 
- Pure Domain Use Case `SearchNotesUseCase`: Bergantung hanya pada abstraksi domain interface `NoteRepositoryInterface`, bukan implementasi database SQLite langsung.
- Providers dipindahkan ke `notes_providers.dart` pada layer presentasi.

### Hapus import lintas layer dan pastikan analyze tetap bersih.

- Entity domain `Note` dan `NoteRepositoryInterface` berada di package domain.
- Data layer mengimplementasikan interface dari domain.
- Presentation layer hanya mengonsumsi use case dan provider, tanpa akses langsung ke internal SQLite.

<img src="screenshots/verif2.png" style="display: block; margin: 0 auto;">