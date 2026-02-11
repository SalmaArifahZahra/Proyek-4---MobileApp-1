# LogBook App —  Counter with SRP Version
LogBook App adalah aplikasi mobile berbasis Flutter yang dikembangkan untuk memahami konsep dasar manajemen state serta penerapan Single Responsibility Principle (SRP) dalam arsitektur aplikasi. Proyek ini menjadi latihan awal untuk membangun struktur kode yang rapi, terorganisir, dan siap dikembangkan lebih lanjut.

## LogBook App —  Counter with SRP Version Gambaran Aplikasi
Aplikasi memungkinkan pengguna untuk:
• Menambah dan mengurangi nilai counter dengan angka step yang dapat diatur
• Melihat riwayat setiap perubahan nilai secara real-time
• Mendapatkan konfirmasi sebelum melakukan reset
Melalui fitur ini, aplikasi merepresentasikan bagaimana sebuah sistem kecil dapat dikelola dengan struktur yang jelas antara logika dan tampilan.

## Implementasi Prinsip SRP 
Single Responsibility Principle (SRP) adalah prinsip yang menyatakan bahwa setiap bagian kode hanya memiliki satu tugas utama agar tidak saling bercampur. Dalam aplikasi ini, logika perhitungan dan penyimpanan data berada di CounterController, sedangkan tampilan ada di CounterView. Saat menambahkan fitur History Logger, saya cukup menambahkan penyimpanan riwayat dan proses pencatatannya di Controller tanpa harus mengubah banyak bagian di tampilan. Karena tanggung jawabnya sudah jelas sejak awal, proses pengembangan jadi lebih mudah, rapi, dan tidak membingungkan.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
