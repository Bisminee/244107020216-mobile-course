void main(){
  String? nama;
  String? nim;
  String? email;
  Profil pMahasiswa = Profil(nama: nama, nim: nim, email: email); 
  print(pMahasiswa.panggilProfil('Budi', '230120379912', email ?? 'E-mail boleh kosong'));
}

class Profil{
  Profil({required this.nama, required this.nim, required this.email} );
  String? nama;
  String? nim;
  String? email;

  String panggilProfil(String nama, String nim, String email){
    return('Halo $nama, dengan nim $nim, dengan email $email');
  }
}