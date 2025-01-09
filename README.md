 - Johan Ridho Akbar Auradhana / A11.2022.14472

# Bumdesa Finance

Bumdesa Finance adalah aplikasi manajemen keuangan untuk Badan Usaha Milik Desa (BUMDes). Aplikasi ini membantu BUMDes dalam mengelola transaksi keuangan secara digital.

## Fitur

- **Manajemen Transaksi**: Pengguna dapat menambah, mengedit, dan menghapus transaksi keuangan.
- **Menampilkan Saldo Terkini**: Pengguna dapat melihat saldo terkini dari transaksi yang telah dilakukan.
- **Total Debet dan Kredit**: Pengguna dapat melihat total debet dan kredit dari semua transaksi.
- **Login/Logout**: Pengguna dapat login dan logout dengan aman menggunakan Firebase Authentication.
- **Penyimpanan Lokal**: Data pengguna disimpan secara lokal menggunakan `SharedPreferences` untuk memastikan pengguna tetap login.

## Teknologi yang Digunakan

- **Flutter**: Framework utama untuk pengembangan aplikasi.
- **Firebase Authentication**: Untuk otentikasi pengguna.
- **Cloud Firestore**: Untuk penyimpanan data transaksi dan profil pengguna.
- **SharedPreferences**: Untuk penyimpanan data pengguna secara lokal.

## Instalasi

1. **Clone Repository**:
   ```sh
   git clone https://github.com/jonyxz/bumdesa-finance.git
   cd bumdesa-finance
   ```
2. **Install Dependencies**:
    ```sh
   flutter pub get
   ```  
3. **Jalankan Aplikasi**:
    ```sh
   flutter run
   ```
