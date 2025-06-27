import '../models/destination.dart';
import 'api_service.dart';

class DestinationService {
  static final DestinationService _instance = DestinationService._internal();
  factory DestinationService() => _instance;
  DestinationService._internal();

  final ApiService _apiService = ApiService();
  List<Destination> _cachedDestinations = [];
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Get destinations from API with caching
  Future<List<Destination>> getAllDestinations() async {
    // Check if cache is still valid
    if (_cachedDestinations.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiry) {
      print('DestinationService: Using cached data');
      return _cachedDestinations;
    }

    try {
      print('DestinationService: Fetching from API...');
      List<Map<String, dynamic>> apiData =
          await _apiService.fetchDestinations();

      _cachedDestinations =
          apiData.map((data) => _convertApiToDestination(data)).toList();
      _lastFetchTime = DateTime.now();

      print(
        'DestinationService: Fetched ${_cachedDestinations.length} destinations from API',
      );
      return _cachedDestinations;
    } catch (e) {
      print('DestinationService Error: $e');
      // Fallback to local data if API fails
      return _getLocalDestinations();
    }
  }

  // Convert API data to Destination model
  Destination _convertApiToDestination(Map<String, dynamic> data) {
    return Destination(
      id: data['api_id']?.toString() ?? '',
      name: data['name'] ?? 'Unknown Destination',
      description: data['description'] ?? 'No description available',
      imagePath: data['image_url'] ?? 'assets/placeholder.jpg',
      location: data['location'] ?? 'Unknown Location',
      category: data['category'] ?? 'Other',
      basePrice: ((data['price'] as num?)?.toDouble() ?? 0.0).round(),
      isPopular: (data['is_popular'] == 1) || (data['is_popular'] == true),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      tags: _generateTags(data['category']),
      isFromApi: data['from_api'] ?? false, // Flag untuk UI
    );
  }

  List<String> _generateTags(String? category) {
    switch (category?.toLowerCase()) {
      case 'gunung':
        return ['Adventure', 'Nature', 'Hiking'];
      case 'taman':
        return ['Cultural', 'Nature', 'Photography'];
      case 'pantai':
        return ['Beach', 'Relaxation', 'Water Sport'];
      case 'budaya':
        return ['Cultural', 'Historical', 'Art'];
      default:
        return ['Travel', 'Adventure'];
    }
  }

  // Local fallback data
  List<Destination> _getLocalDestinations() {
    return [
      Destination(
        id: '1',
        name: 'Gunung Agung',
        description:
            'Gunung Agung adalah gunung berapi tertinggi di Pulau Bali, Indonesia, dengan ketinggian sekitar 3.031 meter di atas permukaan laut (mdpl). Terletak di Kabupaten Karangasem, gunung ini merupakan salah satu tempat paling sakral bagi masyarakat Bali.',
        imagePath: 'assets/gunung_agung.jpg',
        location: 'Karangasem, Bali',
        category: 'Gunung',
        basePrice: 500000,
        isPopular: true,
        rating: 4.8,
        tags: ['Adventure', 'Spiritual', 'Nature'],
        isFromApi: false,
      ),
      Destination(
        id: '2',
        name: 'Lempuyang',
        description:
            'Pura Lempuyang adalah sebuah pura Hindu yang terletak di lereng Gunung Lempuyang, Karangasem, Bali. Pura ini merupakan salah satu dari enam pura utama (Sad Kahyangan Jagad) di Bali dan terkenal dengan "Gerbang Surga" yang menawarkan pemandangan Gunung Agung yang menakjubkan.',
        imagePath: 'assets/lempuyang.jpg',
        location: 'Karangasem, Bali',
        category: 'Taman',
        basePrice: 275000,
        isPopular: true,
        rating: 4.9,
        tags: ['Cultural', 'Spiritual', 'Photography'],
        isFromApi: false,
      ),
      Destination(
        id: '3',
        name: 'Gunung Batur',
        description:
            'Gunung Batur adalah gunung berapi aktif yang terletak di Kintamani, Kabupaten Bangli, Bali, dengan ketinggian sekitar 1.717 meter di atas permukaan laut (mdpl). Meskipun tidak setinggi Gunung Agung, Gunung Batur sangat populer karena pemandangan matahari terbit yang menakjubkan.',
        imagePath: 'assets/gunung_batur.jpg',
        location: 'Kintamani, Bali',
        category: 'Gunung',
        basePrice: 350000,
        isPopular: true,
        rating: 4.7,
        tags: ['Adventure', 'Nature', 'Photography'],
        isFromApi: false,
      ),
      Destination(
        id: '4',
        name: 'Ubud',
        description:
            'Ubud adalah pusat seni dan budaya Bali yang terkenal dengan hutan monyet, galeri seni, dan pemandangan sawah yang menakjubkan.',
        imagePath: 'assets/ubud.jpg',
        location: 'Ubud, Bali',
        category: 'Taman',
        basePrice: 450000,
        isPopular: true,
        rating: 4.6,
        tags: ['Cultural', 'Art', 'Nature'],
        isFromApi: false,
      ),
    ];
  }

  // Get popular destinations
  Future<List<Destination>> getPopularDestinations() async {
    final destinations = await getAllDestinations();
    return destinations.where((dest) => dest.isPopular).toList();
  }

  // Get destinations by category
  Future<List<Destination>> getDestinationsByCategory(String category) async {
    final destinations = await getAllDestinations();
    return destinations.where((dest) => dest.category == category).toList();
  }

  // Search destinations
  Future<List<Destination>> searchDestinations(String query) async {
    if (query.isEmpty) {
      return await getAllDestinations();
    }

    final destinations = await getAllDestinations();
    return destinations.where((dest) {
      return dest.name.toLowerCase().contains(query.toLowerCase()) ||
          dest.description.toLowerCase().contains(query.toLowerCase()) ||
          dest.location.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get destination by ID
  Future<Destination?> getDestinationById(String id) async {
    try {
      final destinations = await getAllDestinations();
      return destinations.firstWhere((dest) => dest.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get destination by name
  Future<Destination?> getDestinationByName(String name) async {
    try {
      final destinations = await getAllDestinations();
      return destinations.firstWhere(
        (dest) => dest.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    final destinations = await getAllDestinations();
    return destinations.map((dest) => dest.category).toSet().toList();
  }

  // Filter destinations
  Future<List<Destination>> filterDestinations({
    String? category,
    double? minRating,
    int? maxPrice,
    bool? isPopular,
  }) async {
    final destinations = await getAllDestinations();
    var filtered = destinations.where((dest) {
      if (category != null && dest.category != category) return false;
      if (minRating != null && dest.rating < minRating) return false;
      if (maxPrice != null && dest.basePrice > maxPrice) return false;
      if (isPopular != null && dest.isPopular != isPopular) return false;
      return true;
    });

    return filtered.toList();
  }

  // Get top rated destinations
  Future<List<Destination>> getTopRatedDestinations({int limit = 10}) async {
    final destinations = await getAllDestinations();
    var sorted = List<Destination>.from(destinations);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Get newest destinations
  Future<List<Destination>> getNewestDestinations({int limit = 5}) async {
    final destinations = await getAllDestinations();
    return destinations.take(limit).toList();
  }

  // Clear cache (force refresh from API)
  void clearCache() {
    _cachedDestinations.clear();
    _lastFetchTime = null;
    print('DestinationService: Cache cleared');
  }
}
