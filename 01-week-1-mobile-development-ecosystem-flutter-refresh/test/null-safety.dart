// Latihan mandiri
// Buat fungsi hitungLuasPersegiPanjang yang menerima panjang dan lebar bertipe double.
// Buat class Profil dengan properti nama, nim, dan email yang boleh kosong.
// Panggil keduanya dari main(), lalu tangani email kosong dengan aman.

void main() {
  String? nama;
  String? nim;
  String? email;
  print(hitungLuasPersegiPanjang(20.1, 13.5));
  final profil = Profil(nama: nama, nim: nim, email: email);
  print(profil.status());
}

double hitungLuasPersegiPanjang(double panjang, double lebar) {
  double luas = panjang * lebar;
  return luas;
}

class Profil {
  Profil({required this.nama, required this.nim, required this.email});
  final String? nama;
  final String? nim;
  final String? email;
  String status() => email ?? 'Email belum diisi';
}
