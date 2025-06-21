import 'package:flutter/material.dart';
import '../widgets/start_button.dart'; // Mengimpor widget tombol mulai (StartButton)

// Kelas stateless widget bernama HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack agar bisa menumpuk widget (gambar latar + konten di atasnya)
      body: Stack(
        children: [
          // Widget untuk menampilkan gambar latar belakang memenuhi layar
          Container(
            height: double.infinity, // Tinggi layar penuh
            width: double.infinity, // Lebar layar penuh
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bali.png'), // Gambar latar dari asset
                fit: BoxFit.cover, // Menyesuaikan gambar agar menutupi seluruh layar
              ),
            ),
          ),

          // Container putih transparan di bagian bawah layar
          Align(
            alignment: Alignment.bottomCenter, // Menempatkan di bawah layar
            child: Container(
              margin: const EdgeInsets.all(16), // Margin luar
              padding: const EdgeInsets.all(16), // Padding dalam
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3, // 30% tinggi layar
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), // Warna putih dengan transparansi 80%
                borderRadius: BorderRadius.circular(24), // Sudut melengkung
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4), // Efek bayangan di bawah
                  ),
                ],
              ),
              // Isi dari container putih: teks dan tombol
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Tengah vertikal
                crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
                children: [
                  // Teks tebal berlapis efek stroke
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        // Efek stroke abu-abu sebagai lapisan bawah
                        Text(
                          'Welcome to Pesona Bali',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.black54, // Lapisan belakang (shadow tipis)
                          ),
                        ),
                        // Teks utama berwarna hitam
                        Text(
                          'Welcome to Pesona Bali',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Spasi antara teks dan tombol
                  
                  // Tombol "Start" yang diimpor dari widgets/start_button.dart
                  const Center(child: StartButton()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
