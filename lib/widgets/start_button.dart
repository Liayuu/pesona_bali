import 'package:flutter/material.dart';
import '../screens/discover_screen.dart'; // Import halaman DiscoverScreen

// Widget tombol StartButton yang dapat digunakan kembali
class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Fungsi yang dijalankan saat tombol ditekan
      onPressed: () {
        // Navigasi ke halaman DiscoverScreen saat tombol ditekan
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
        );
      },
      // Styling tombol menggunakan ElevatedButton.styleFrom
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Warna latar belakang tombol
        foregroundColor: Colors.white, // Warna teks dan ikon tombol
        minimumSize: const Size(500, 60), // Ukuran minimum tombol (lebar x tinggi)
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Jarak isi tombol ke tepi
        textStyle: const TextStyle(fontSize: 18), // Ukuran font teks tombol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Sudut tombol membulat
        ),
      ),
      // Isi tombol berupa teks dan ikon yang disusun secara horizontal
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ukuran Row disesuaikan dengan isi (tidak memenuhi lebar penuh)
        children: const [
          Text('Start Here'), // Teks pada tombol
          SizedBox(width: 10), // Jarak antara teks dan ikon
        ],
      ),
    );
  }
}
