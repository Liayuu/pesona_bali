import 'package:flutter/material.dart';

// Halaman detail destinasi
class DestinationDetailScreen extends StatefulWidget {
  // Parameter yang dikirim dari halaman sebelumnya
  final String imagePath;               // Gambar utama destinasi
  final String destinationName;         // Judul destinasi
  final String destinationDescription;  // Deskripsi panjang

  const DestinationDetailScreen({
    super.key,
    required this.imagePath,
    required this.destinationName,
    required this.destinationDescription,
  });

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  bool isFavorite = false; // Status apakah destinasi sudah difavoritkan atau belum

  // Fungsi untuk menampilkan dialog konfirmasi saat toggle favorite
  void _showFavoriteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFavorite ? 'Remove Favorite?' : 'Add to Favorite?'),
        content: Text(isFavorite
            ? 'Apakah kamu ingin menghapus destinasi ini dari favorit?'
            : 'Apakah kamu ingin menambahkan destinasi ini ke favorit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog tanpa aksi
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite; // Toggle status favorite
              });
              Navigator.pop(context); // Tutup dialog
              // Tampilkan notifikasi singkat di bawah
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFavorite
                      ? 'Destinasi ditambahkan ke favorit'
                      : 'Destinasi dihapus dari favorit'),
                ),
              );
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul destinasi dan tombol favorite
      appBar: AppBar(
        title: Text(widget.destinationName),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _showFavoriteDialog, // Saat ditekan, tampilkan dialog
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar utama destinasi
            Image.asset(
              widget.imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),

            // Judul destinasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.destinationName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Deskripsi destinasi (scrollable jika panjang)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.destinationDescription,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify, // Rata kiri-kanan
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
