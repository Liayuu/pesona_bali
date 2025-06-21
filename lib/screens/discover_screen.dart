import 'package:flutter/material.dart';
import 'destination_detail_screen.dart'; // Halaman detail destinasi

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}
// State dari DiscoverScreen
class _DiscoverScreenState extends State<DiscoverScreen> {
  // Daftar kategori destinasi dengan ikon dan label
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.terrain, 'label': 'Gunung'},
    {'icon': Icons.beach_access, 'label': 'Pantai'},
    {'icon': Icons.water, 'label': 'Danau'},
    {'icon': Icons.park, 'label': 'Taman'},
  ];
  int selectedCategoryIndex = 0; // Default kategori pertama aktif

  // Daftar destinasi beserta gambar dan deskripsi
  final List<Map<String, dynamic>> destinations = [
    {
      'image': 'assets/gunung_agung.jpg',
      'name': 'Gunung Agung',
      'description':
          'Gunung Agung adalah gunung berapi tertinggi di Pulau Bali, Indonesia, dengan ketinggian sekitar 3.031 meter di atas permukaan laut (mdpl). Terletak di Kabupaten Karangasem, gunung ini merupakan salah satu tempat paling sakral bagi masyarakat Bali, karena diyakini sebagai tempat bersemayamnya para dewa. Gunung Agung juga menjadi pusat spiritual penting karena di lerengnya terdapat Pura Besakih, pura terbesar dan paling suci di Bali. Selain nilai religiusnya, Gunung Agung juga menawarkan pemandangan alam yang spektakuler dan menjadi destinasi populer bagi para pendaki dan pecinta alam indah, Gunung Agung merupakan gunung berapi aktif. Letusan terbesarnya terjadi pada tahun 1963, yang menelan ribuan korban jiwa dan menghancurkan banyak wilayah di sekitarnya. Aktivitas vulkanik Gunung Agung masih terus dipantau hingga kini.Meski indah, Gunung Agung merupakan gunung berapi aktif. Letusan terbesarnya terjadi pada tahun 1963, yang menelan ribuan korban jiwa dan menghancurkan banyak wilayah di sekitarnya. Aktivitas vulkanik Gunung Agung masih terus dipantau hingga kini.Meski indah, Gunung Agung merupakan gunung berapi aktif. Letusan terbesarnya terjadi pada tahun 1963, yang menelan ribuan korban jiwa dan menghancurkan banyak wilayah di sekitarnya. Aktivitas vulkanik Gunung Agung masih terus dipantau hingga kini.',
    },
    {
      'image': 'assets/gunung_catur.webp',
      'name': 'Gunung Catur',
      'description':
          'Gunung Catur adalah salah satu gunung berapi yang terletak di Kabupaten Tabanan, Bali, Indonesia. Dengan ketinggian sekitar 2.096 meter di atas permukaan laut (mdpl), Gunung Catur merupakan gunung tertinggi keempat di Pulau Bali. Gunung ini terletak di sisi timur Danau Beratan dan berada dalam kawasan Baturiti dan Bedugul, yang terkenal dengan udara sejuk dan pemandangan alam yang memukau. Gunung Catur sangat populer di kalangan pendaki lokal dan wisatawan karena jalur pendakiannya yang relatif pendek dan mudah diakses. Dari puncaknya, pengunjung dapat menikmati panorama luar biasa berupa hamparan Danau Beratan, hutan lebat, dan lanskap pegunungan yang hijau. Di puncak gunung juga terdapat Pura Puncak Mangu, sebuah pura suci yang sering dikunjungi oleh umat Hindu untuk bersembahyang dan meditasi.',
    },
    {
      'image': 'assets/lempuyang.jpg',
      'name': 'Lempuyang',
      'description':
          'Pura Lempuyang adalah sebuah pura Hindu yang terletak di lereng Gunung Lempuyang, Karangasem, Bali. Pura ini merupakan salah satu dari enam pura utama (Sad Kahyangan Jagad) di Bali dan menjadi tempat suci untuk memuja Ida Sang Hyang Widi Wasa, khususnya manifestasinya sebagai Dewa Iswara. Pura ini juga terkenal karena "Gerbang Surga" (Gate of Heaven) yang menawarkan pemandangan Gunung Agung yang menakjubkan. ',
    },
    {
      'image': 'assets/gunung_abang.jpeg',
      'name': 'Gunung Abang',
      'description':
          'Gunung Abang merupakan gunung tertinggi ketiga di Pulau Bali setelah Gunung Agung dan Gunung Batukaru, dengan ketinggian sekitar 2.152 meter di atas permukaan laut (mdpl). Gunung ini terletak di Kecamatan Kintamani, Kabupaten Bangli, dan berada di sebelah timur Danau Batur. Gunung Abang adalah bagian dari kaldera Gunung Batur yang sangat luas, yang terbentuk dari letusan besar ribuan tahun silam. Meskipun tidak sepopuler Gunung Agung, Gunung Abang menawarkan jalur pendakian yang menantang namun cocok bagi pendaki pemula hingga menengah. Jalur pendakian didominasi oleh hutan tropis yang masih asri, menciptakan suasana sejuk dan mistis selama perjalanan menuju puncak. Dari puncaknya, pendaki disuguhkan pemandangan spektakuler berupa Gunung Batur, Danau Batur, dan bahkan Gunung Rinjani di Lombok saat cuaca cerah. ',
    },
    {
      'image': 'assets/gunung_batur.jpg',
      'name': 'Gunung Batur',
      'description':
          'Gunung Batur adalah gunung berapi aktif yang terletak di Kintamani, Kabupaten Bangli, Bali, dengan ketinggian sekitar 1.717 meter di atas permukaan laut (mdpl). Meskipun tidak setinggi Gunung Agung, Gunung Batur sangat populer di kalangan wisatawan karena pendakiannya yang relatif mudah dan pemandangan matahari terbit yang menakjubkan dari puncaknya. Gunung ini berada di dalam kaldera besar yang terbentuk akibat letusan dahsyat ribuan tahun lalu. Di dalam kaldera tersebut juga terdapat Danau Batur, danau terbesar di Bali, yang menambah keindahan alam kawasan ini. Kombinasi antara danau, pegunungan, dan desa tradisional seperti Desa Trunyan menjadikan Gunung Batur sebagai salah satu destinasi wisata alam dan budaya terbaik di Bali. ',
    },
    {
      'image': 'assets/trunyan.jpg',
      'name': 'Trunyan',
      'description':
          'Bukit Trunyan terletak di Desa Trunyan, Kecamatan Kintamani, Kabupaten Bangli. Bukit ini berlokasi di tepi timur Danau Batur. Trunyan dikenal dengan tradisi pemakaman unik, dimana warga yang meninggal tidak dikubur atau dikremasi, melainkan hanya ditaruh di bawah pohon Taru Menyan. Namun, selain aspek budaya dan tradisi yang unik, Bukit Trunyan menawarkan lanskap alam yang menakjubkan yang patut traveler eksplorasi. Dengan ketinggian 1.834 mdpl, bukit ini cocok untuk traveler yang suka mendaki ataupun pendaki pemula. Dari puncak Bukit Trunyan traveler bisa menikmati pemandangan epik yang siap memanjakan mata.Baca artikel detikTravel, "Bukit Trunyan Spot Mendaki untuk Pemula, bak Berdiri di Atas Awan',
    },
  ];

  // Daftar destinasi yang difilter berdasarkan pencarian
  late List<Map<String, dynamic>> filteredDestinations;
  // Controller untuk search bar
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDestinations = destinations;
    searchController.addListener(_filterDestinations); // Panggil filter saat mengetik
  }

  // Fungsi untuk memfilter destinasi berdasarkan input pencarian
  void _filterDestinations() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredDestinations = destinations.where((dest) {
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
      // Navigasi bawah
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Like'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar atas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.menu, size: 32),
                  Icon(Icons.person, size: 32),
                ],
              ),
              const SizedBox(height: 24),

              // Judul besar
              Stack(
                children: [
                  Text(
                    'Pesona Bali',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1.5
                        ..color = Colors.black54,
                    ),
                  ),
                  const Text(
                    'Pesona Bali',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                          hintText: 'Search',
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
                           // Ikon kategori dalam lingkaran       
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.blue[100],
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
                'Destination',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Daftar destinasi
              Expanded(
                child: GridView.builder(
                  itemCount: filteredDestinations.length, // Jumlah destinasi hasil filter
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
                        // Navigasi ke halaman detail saat diklik
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(
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