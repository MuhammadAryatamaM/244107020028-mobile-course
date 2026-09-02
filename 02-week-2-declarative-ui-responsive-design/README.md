# Week 2

## Hasil yang Dicapai

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


