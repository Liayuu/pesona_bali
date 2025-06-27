import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    initializeApi(); // Initialize Dio automatically
  }

  late Dio _dio;
  // Using JSONPlaceholder as real API for testing
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  void initializeApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // Check internet connectivity
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get destinations from API (convert posts to travel data)
  Future<List<Map<String, dynamic>>> fetchDestinations({
    double? latitude,
    double? longitude,
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (!await hasInternetConnection()) {
        print('API: No internet connection, using mock data');
        return _getMockDestinations();
      }

      print('API: Fetching destinations from JSONPlaceholder...');
      final response = await _dio.get('/posts');

      if (response.statusCode == 200) {
        print('API: Successfully fetched ${response.data.length} posts');
        // Convert JSONPlaceholder posts to travel destinations
        List<dynamic> posts = response.data;
        return _convertPostsToDestinations(posts.take(limit).toList());
      } else {
        throw Exception('Failed to fetch destinations');
      }
    } catch (e) {
      print('API Error fetching destinations: $e');
      return _getMockDestinations();
    }
  }

  // Create booking via API
  Future<Map<String, dynamic>?> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      if (!await hasInternetConnection()) {
        print('API: No internet connection, using mock response');
        return _getMockBookingResponse();
      }

      print('API: Creating booking via JSONPlaceholder...');
      final response = await _dio.post('/posts', data: bookingData);

      if (response.statusCode == 201) {
        print(
          'API: Booking created successfully with ID: ${response.data['id']}',
        );
        return {
          'id': 'BK${response.data['id']}',
          'ticket_number': 'TKT${DateTime.now().millisecondsSinceEpoch}',
          'status': 'confirmed',
          'created_at': DateTime.now().toIso8601String(),
          'api_response': response.data,
        };
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      print('API Error creating booking: $e');
      return _getMockBookingResponse();
    }
  }

  // Convert JSONPlaceholder posts to travel destinations
  List<Map<String, dynamic>> _convertPostsToDestinations(List<dynamic> posts) {
    // Predefined Bali destinations mapped to posts
    final List<Map<String, dynamic>> baliDestinations = [
      {
        'name': 'Mount Batur Sunrise Trek',
        'description':
            'Nikmati pemandangan matahari terbit yang spektakuler dari puncak Gunung Batur. Pendakian dimulai dini hari dengan pemandu lokal berpengalaman.',
        'location': 'Kintamani, Bali',
        'latitude': -8.2500,
        'longitude': 115.3750,
        'price': 350000.0,
        'rating': 4.8,
        'image_url': 'assets/gunung_batur.jpg',
        'category': 'Gunung',
        'is_popular': 1,
      },
      {
        'name': 'Lempuyang Temple - Gates of Heaven',
        'description':
            'Kunjungi Pura Lempuyang yang terkenal dengan gerbang surganya. Lokasi instagramable dengan pemandangan Gunung Agung yang menakjubkan.',
        'location': 'Karangasem, Bali',
        'latitude': -8.3720,
        'longitude': 115.6250,
        'price': 275000.0,
        'rating': 4.7,
        'image_url': 'assets/lempuyang.jpg',
        'category': 'Budaya',
        'is_popular': 1,
      },
      {
        'name': 'Ubud Art & Culture Village',
        'description':
            'Jelajahi pusat seni dan budaya Bali di Ubud. Kunjungi galeri seni, workshop tradisional, dan nikmati suasana desa yang autentik.',
        'location': 'Ubud, Bali',
        'latitude': -8.5069,
        'longitude': 115.2625,
        'price': 320000.0,
        'rating': 4.6,
        'image_url': 'assets/ubud.jpg',
        'category': 'Budaya',
        'is_popular': 1,
      },
      {
        'name': 'Jatiluwih Rice Terraces',
        'description':
            'Saksikan keindahan terasering sawah Jatiluwih yang menakjubkan. Warisan budaya dunia UNESCO dengan pemandangan hijau yang menyejukkan mata.',
        'location': 'Tabanan, Bali',
        'latitude': -8.3648,
        'longitude': 115.1336,
        'price': 250000.0,
        'rating': 4.5,
        'image_url': 'assets/jatiluwih.jpg',
        'category': 'Taman',
        'is_popular': 1,
      },
      {
        'name': 'Mount Agung Sacred Volcano',
        'description':
            'Gunung tertinggi di Bali yang dianggap suci oleh masyarakat Hindu Bali. Pendakian menantang dengan pemandangan pulau yang luar biasa.',
        'location': 'Karangasem, Bali',
        'latitude': -8.3440,
        'longitude': 115.5083,
        'price': 400000.0,
        'rating': 4.7,
        'image_url': 'assets/gunung_agung.jpg',
        'category': 'Gunung',
        'is_popular': 0,
      },
      {
        'name': 'Garuda Wisnu Kencana (GWK)',
        'description':
            'Taman budaya dengan patung Garuda Wisnu Kencana yang megah. Pertunjukan budaya, museum, dan pemandangan sunset yang menawan.',
        'location': 'Badung, Bali',
        'latitude': -8.8103,
        'longitude': 115.1668,
        'price': 125000.0,
        'rating': 4.4,
        'image_url': 'assets/gwk.jpg',
        'category': 'Budaya',
        'is_popular': 0,
      },
      {
        'name': 'Trunyan Ancient Village',
        'description':
            'Desa kuno Trunyan di tepi Danau Batur dengan tradisi pemakaman unik. Budaya Bali Aga yang masih terjaga hingga kini.',
        'location': 'Bangli, Bali',
        'latitude': -8.2542,
        'longitude': 115.3931,
        'price': 300000.0,
        'rating': 4.3,
        'image_url': 'assets/trunyan.jpg',
        'category': 'Budaya',
        'is_popular': 0,
      },
      {
        'name': 'Mount Catur Hidden Peak',
        'description':
            'Gunung tersembunyi dengan jalur pendakian yang menantang. Pemandangan hutan tropis dan udara segar pegunungan Bali.',
        'location': 'Tabanan, Bali',
        'latitude': -8.3167,
        'longitude': 115.1333,
        'price': 375000.0,
        'rating': 4.2,
        'image_url': 'assets/gunung_catur.webp',
        'category': 'Gunung',
        'is_popular': 0,
      },
      {
        'name': 'Pandawa Beach Paradise',
        'description':
            'Pantai Pandawa dengan pasir putih dan tebing kapur yang indah. Tempat sempurna untuk bersantai dan menikmati sunset Bali.',
        'location': 'Badung, Bali',
        'latitude': -8.8486,
        'longitude': 115.1969,
        'price': 150000.0,
        'rating': 4.6,
        'image_url': 'assets/pantai2.jpg',
        'category': 'Pantai',
        'is_popular': 0,
      },
      {
        'name': 'Mount Abang Crater Lake',
        'description':
            'Gunung Abang dengan danau kawah yang eksotis. Pendakian moderate dengan pemandangan Danau Batur dari ketinggian.',
        'location': 'Bangli, Bali',
        'latitude': -8.2833,
        'longitude': 115.4000,
        'price': 325000.0,
        'rating': 4.4,
        'image_url': 'assets/gunung_abang.jpeg',
        'category': 'Gunung',
        'is_popular': 0,
      },
    ];

    return posts.asMap().entries.map((entry) {
      int index = entry.key;
      var post = entry.value;

      // Use predefined Bali destination if available, otherwise create generic one
      Map<String, dynamic> destination;
      if (index < baliDestinations.length) {
        destination = Map<String, dynamic>.from(baliDestinations[index]);
      } else {
        // Fallback for additional posts beyond predefined destinations
        destination = {
          'name': 'Destinasi Bali ${index + 1}',
          'description':
              'Destinasi wisata menarik di Bali dengan pengalaman yang tak terlupakan. Nikmati keindahan alam dan budaya Bali yang autentik.',
          'location': 'Bali, Indonesia',
          'latitude': -8.5 + (index * 0.05),
          'longitude': 115.0 + (index * 0.05),
          'price': (200000 + (index * 25000)).toDouble(),
          'rating': 4.0 + (index % 10) * 0.05,
          'image_url': 'assets/bali.png',
          'category': 'Budaya',
          'is_popular': 0,
        };
      }

      // Add API specific fields
      destination['api_id'] = post['id'].toString();
      destination['from_api'] = true;

      return destination;
    }).toList();
  }

  // Mock booking response
  Map<String, dynamic> _getMockBookingResponse() {
    return {
      'id': 'BK${DateTime.now().millisecondsSinceEpoch}',
      'ticket_number': 'TKT${DateTime.now().millisecondsSinceEpoch}',
      'status': 'confirmed',
      'created_at': DateTime.now().toIso8601String(),
      'from_api': false,
    };
  }

  // Mock data for fallback
  List<Map<String, dynamic>> _getMockDestinations() {
    return [
      {
        'api_id': '1',
        'name': 'Mount Batur Sunrise Trek',
        'description':
            'Experience breathtaking sunrise views from the summit of Mount Batur',
        'location': 'Kintamani, Bali',
        'latitude': -8.2500,
        'longitude': 115.3750,
        'price': 350000.0,
        'rating': 4.8,
        'image_url': 'assets/gunung_batur.jpg',
        'category': 'Gunung',
        'is_popular': 1,
        'from_api': false, // Flag untuk menunjukkan data mock
      },
      {
        'api_id': '2',
        'name': 'Lempuyang Temple Tour',
        'description': 'Visit the famous Gates of Heaven at Lempuyang Temple',
        'location': 'Karangasem, Bali',
        'latitude': -8.3720,
        'longitude': 115.6250,
        'price': 275000.0,
        'rating': 4.7,
        'image_url': 'assets/lempuyang.jpg',
        'category': 'Taman',
        'is_popular': 1,
        'from_api': false,
      },
      {
        'api_id': '3',
        'name': 'Ubud Art & Culture',
        'description': 'Immerse yourself in Balinese art and culture',
        'location': 'Ubud, Bali',
        'latitude': -8.5069,
        'longitude': 115.2625,
        'price': 320000.0,
        'rating': 4.6,
        'image_url': 'assets/ubud.jpg',
        'category': 'Budaya',
        'is_popular': 0,
        'from_api': false,
      },
      {
        'api_id': '4',
        'name': 'Jatiluwih Rice Terrace',
        'description': 'Stunning rice terraces with panoramic views',
        'location': 'Tabanan, Bali',
        'latitude': -8.3648,
        'longitude': 115.1336,
        'price': 200000.0,
        'rating': 4.5,
        'image_url': 'assets/jatiluwih.jpg',
        'category': 'Taman',
        'is_popular': 1,
        'from_api': false,
      },
    ];
  }
}
