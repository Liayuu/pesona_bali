import 'package:flutter/material.dart';
import 'destination_detail_screen.dart';

class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({super.key});

  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  // Daftar kategori destinasi dengan ikon dan label
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.terrain, 'label': 'Gunung'},
    {'icon': Icons.beach_access, 'label': 'Pantai'},
    {'icon': Icons.water, 'label': 'Danau'},
    {'icon': Icons.park, 'label': 'Taman'},
  ];
  int selectedCategoryIndex = 0;

  // Daftar lengkap semua destinasi
  final List<Map<String, dynamic>> destinations = [
    {
      'image': 'assets/gunung_agung.jpg',
      'name': 'Gunung Agung',
      'description':
          'Gunung Agung adalah gunung berapi tertinggi di Pulau Bali, Indonesia, dengan ketinggian sekitar 3.031 meter di atas permukaan laut (mdpl). Terletak di Kabupaten Karangasem, gunung ini merupakan salah satu tempat paling sakral bagi masyarakat Bali, karena diyakini sebagai tempat bersemayamnya para dewa.',
      'isPopular': true,
    },
    {
      'image': 'assets/gunung_catur.webp',
      'name': 'Gunung Catur',
      'description':
          'Gunung Catur adalah salah satu gunung berapi yang terletak di Kabupaten Tabanan, Bali, Indonesia. Dengan ketinggian sekitar 2.096 meter di atas permukaan laut (mdpl), Gunung Catur merupakan gunung tertinggi keempat di Pulau Bali.',
      'isPopular': false,
    },
    {
      'image': 'assets/lempuyang.jpg',
      'name': 'Lempuyang',
      'description':
          'Pura Lempuyang adalah sebuah pura Hindu yang terletak di lereng Gunung Lempuyang, Karangasem, Bali. Pura ini merupakan salah satu dari enam pura utama (Sad Kahyangan Jagad) di Bali dan menjadi tempat suci untuk memuja Ida Sang Hyang Widi Wasa.',
      'isPopular': true,
    },
    {
      'image': 'assets/gunung_abang.jpeg',
      'name': 'Gunung Abang',
      'description':
          'Gunung Abang merupakan gunung tertinggi ketiga di Pulau Bali setelah Gunung Agung dan Gunung Batukaru, dengan ketinggian sekitar 2.152 meter di atas permukaan laut (mdpl).',
      'isPopular': false,
    },
    {
      'image': 'assets/gunung_batur.jpg',
      'name': 'Gunung Batur',
      'description':
          'Gunung Batur adalah gunung berapi aktif yang terletak di Kintamani, Kabupaten Bangli, Bali, dengan ketinggian sekitar 1.717 meter di atas permukaan laut (mdpl).',
      'isPopular': true,
    },
    {
      'image': 'assets/trunyan.jpg',
      'name': 'Trunyan',
      'description':
          'Bukit Trunyan terletak di Desa Trunyan, Kecamatan Kintamani, Kabupaten Bangli. Bukit ini berlokasi di tepi timur Danau Batur. Trunyan dikenal dengan tradisi pemakaman unik.',
      'isPopular': false,
    },
    {
      'image': 'assets/jatiluwih.jpg',
      'name': 'Jatiluwih',
      'description':
          'Jatiluwih adalah sebuah desa wisata yang terkenal dengan sawah terasering yang indah dan merupakan Warisan Dunia UNESCO.',
      'isPopular': true,
    },
    {
      'image': 'assets/ubud.jpg',
      'name': 'Ubud',
      'description':
          'Ubud adalah pusat seni dan budaya Bali yang terkenal dengan hutan monyet, galeri seni, dan pemandangan sawah yang menakjubkan.',
      'isPopular': true,
    },
    {
      'image': 'assets/gwk.jpg',
      'name': 'GWK Cultural Park',
      'description':
          'Garuda Wisnu Kencana Cultural Park adalah taman budaya yang menampilkan patung Garuda Wisnu Kencana yang megah.',
      'isPopular': false,
    },
    {
      'image': 'assets/pantai2.jpg',
      'name': 'Pantai Kuta',
      'description':
          'Pantai Kuta adalah salah satu pantai paling terkenal di Bali dengan pasir putih dan ombak yang cocok untuk berselancar.',
      'isPopular': true,
    },
  ];

  late List<Map<String, dynamic>> filteredDestinations;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDestinations = destinations;
    searchController.addListener(_filterDestinations);
  }

  void _filterDestinations() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredDestinations =
          destinations.where((dest) {
            final name = dest['name'].toString().toLowerCase();
            return name.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Destinations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search destinations...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Kategori
              SizedBox(
                height: 120,
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(categories.length, (index) {
                    final cat = categories[index];
                    final bool isSelected = index == selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blue : Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat['icon'],
                              color: isSelected ? Colors.white : Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat['label'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const Text(
                'All Destinations',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Daftar semua destinasi
              Expanded(
                child: GridView.builder(
                  itemCount: filteredDestinations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final dest = filteredDestinations[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DestinationDetailScreen(
                                  imagePath: dest['image'],
                                  destinationName: dest['name'],
                                  destinationDescription: dest['description'],
                                ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(dest['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dest['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (dest['isPopular'] == true)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Popular',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
