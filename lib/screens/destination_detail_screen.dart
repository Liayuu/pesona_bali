import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'book_trip_screen.dart';
import 'bookmark_screen.dart';

// Halaman detail destinasi
class DestinationDetailScreen extends StatefulWidget {
  // Parameter yang dikirim dari halaman sebelumnya
  final String imagePath; // Gambar utama destinasi
  final String destinationName; // Judul destinasi
  final String destinationDescription; // Deskripsi panjang

  const DestinationDetailScreen({
    super.key,
    required this.imagePath,
    required this.destinationName,
    required this.destinationDescription,
  });

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isBookmarked =
      false; // Status apakah destinasi sudah di-bookmark atau belum
  int? destinationId; // ID destinasi dari database

  @override
  void initState() {
    super.initState();
    _loadDestinationData();
  }
  // Load destination data dan check bookmark status
  Future<void> _loadDestinationData() async {
    try {
      print('=== LOADING DESTINATION DATA ===');
      print('Destination Name: ${widget.destinationName}');
      print('Image Path: ${widget.imagePath}');
      print('Description: ${widget.destinationDescription.substring(0, 50)}...');
      
      // Selalu pastikan destinasi tersimpan di database terlebih dahulu
      await _ensureDestinationInDatabase();
      
      // Debug: Print all destinations dan bookmarks
      await _dbHelper.debugPrintTables();
      
      // Kemudian check bookmark status
      await _checkBookmarkStatus();
      print('Final bookmark status: $isBookmarked');
    } catch (e) {
      print('Error loading destination data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading destination: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Pastikan destinasi ada di database
  Future<void> _ensureDestinationInDatabase() async {
    try {
      final db = await _dbHelper.database;
      
      // Cari destinasi berdasarkan nama
      final existing = await db.query(
        'destinations',
        where: 'name = ?',
        whereArgs: [widget.destinationName],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        destinationId = existing.first['id'] as int;
        print('Found existing destination with ID: $destinationId');
      } else {
        // Insert destinasi baru ke database
        print('Destination not found, inserting new one...');
        destinationId = await db.insert('destinations', {
          'name': widget.destinationName,
          'description': widget.destinationDescription,
          'image_url': widget.imagePath,
          'location': _extractLocationFromName(widget.destinationName),
          'category': _extractCategoryFromName(widget.destinationName),
          'price': 300000, // Default price
          'is_popular': 1, // Default popular
          'rating': 4.5, // Default rating
        });
        print('Inserted new destination with ID: $destinationId');
      }
    } catch (e) {
      print('Error ensuring destination in database: $e');
      throw e;
    }
  }

  // Extract location from destination name (smart guess)
  String _extractLocationFromName(String name) {
    if (name.toLowerCase().contains('batur')) return 'Kintamani, Bali';
    if (name.toLowerCase().contains('lempuyang')) return 'Karangasem, Bali';
    if (name.toLowerCase().contains('ubud')) return 'Ubud, Bali';
    if (name.toLowerCase().contains('jatiluwih')) return 'Tabanan, Bali';
    if (name.toLowerCase().contains('agung')) return 'Karangasem, Bali';
    if (name.toLowerCase().contains('gwk') || name.toLowerCase().contains('garuda')) return 'Badung, Bali';
    if (name.toLowerCase().contains('trunyan')) return 'Bangli, Bali';
    if (name.toLowerCase().contains('catur')) return 'Tabanan, Bali';
    if (name.toLowerCase().contains('pandawa')) return 'Badung, Bali';
    if (name.toLowerCase().contains('abang')) return 'Bangli, Bali';
    return 'Bali, Indonesia'; // Default
  }

  // Extract category from destination name (smart guess)  
  String _extractCategoryFromName(String name) {
    if (name.toLowerCase().contains('mount') || name.toLowerCase().contains('gunung')) return 'Gunung';
    if (name.toLowerCase().contains('beach') || name.toLowerCase().contains('pantai')) return 'Pantai';
    if (name.toLowerCase().contains('temple') || name.toLowerCase().contains('pura')) return 'Budaya';
    if (name.toLowerCase().contains('rice') || name.toLowerCase().contains('sawah')) return 'Taman';
    if (name.toLowerCase().contains('village') || name.toLowerCase().contains('desa')) return 'Budaya';
    return 'Wisata'; // Default
  }

  // Check apakah destinasi sudah di-bookmark
  Future<void> _checkBookmarkStatus() async {
    if (destinationId == null) return;

    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'bookmarks',
        where: 'user_id = ? AND destination_id = ?',
        whereArgs: [1, destinationId], // userId = 1
      );

      setState(() {
        isBookmarked = result.isNotEmpty;
      });
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  // Toggle bookmark status
  Future<void> _toggleBookmark() async {
    if (destinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destinasi tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('Toggling bookmark for destination ID: $destinationId');
      print('Current bookmark status: $isBookmarked');

      if (isBookmarked) {
        await _dbHelper.removeBookmark(1, destinationId!); // userId = 1
        print('Bookmark removed');
      } else {
        await _dbHelper.addBookmark(1, destinationId!); // userId = 1
        print('Bookmark added');
      }

      // Re-check bookmark status from database to confirm
      await _checkBookmarkStatus();
      print('New bookmark status after check: $isBookmarked');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBookmarked
                  ? 'Destinasi ditambahkan ke bookmark'
                  : 'Destinasi dihapus dari bookmark',
            ),
            backgroundColor: isBookmarked ? Colors.green : Colors.orange,
            action:
                isBookmarked
                    ? SnackBarAction(
                      label: 'Lihat Bookmark',
                      textColor: Colors.white,
                      onPressed: () {
                        // Close current snackbar first
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        // Navigate to bookmark screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookmarkScreen(),
                          ),
                        );
                      },
                    )
                    : null,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi saat toggle bookmark
  void _showBookmarkDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isBookmarked ? 'Remove Bookmark?' : 'Add to Bookmark?'),
            content: Text(
              isBookmarked
                  ? 'Apakah kamu ingin menghapus destinasi ini dari bookmark?'
                  : 'Apakah kamu ingin menambahkan destinasi ini ke bookmark?',
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.pop(context), // Tutup dialog tanpa aksi
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  _toggleBookmark(); // Toggle bookmark
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
      // AppBar dengan judul destinasi dan tombol bookmark
      appBar: AppBar(
        title: Text(widget.destinationName),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _showBookmarkDialog, // Saat ditekan, tampilkan dialog
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
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
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

            // Book Trip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BookTripScreen(
                              destinationName: widget.destinationName,
                              destinationImage: widget.imagePath,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_online),
                  label: const Text('Book This Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
