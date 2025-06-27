import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class DestinationController extends ChangeNotifier {
  final DestinationService _destinationService = DestinationService();

  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];
  List<Destination> _popularDestinations = [];
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Destination> get destinations => _destinations;
  List<Destination> get filteredDestinations => _filteredDestinations;
  List<Destination> get popularDestinations => _popularDestinations;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Initialize data
  Future<void> initialize() async {
    await _loadDestinations();
    await _loadPopularDestinations();
  }

  Future<void> _loadDestinations() async {
    _setLoading(true);
    try {
      _destinations = await _destinationService.getAllDestinations();
      _filteredDestinations = List.from(_destinations);
      _clearError();
    } catch (e) {
      _setError('Failed to load destinations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadPopularDestinations() async {
    try {
      _popularDestinations = await _destinationService.getPopularDestinations();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load popular destinations: ${e.toString()}');
    }
  }

  // Search functionality
  Future<void> searchDestinations(String query) async {
    _searchQuery = query;
    await _applyFilters();
  }

  // Category filtering
  Future<void> selectCategory(String category) async {
    _selectedCategory = category;
    await _applyFilters();
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _selectedCategory = '';
    _filteredDestinations = List.from(_destinations);
    notifyListeners();
  }

  Future<void> _applyFilters() async {
    _setLoading(true);
    try {
      List<Destination> result = [];

      // If search query is not empty, use API search
      if (_searchQuery.isNotEmpty) {
        result = await _destinationService.searchDestinations(_searchQuery);
      } else {
        result = await _destinationService.getAllDestinations();
      }

      // Apply category filter
      if (_selectedCategory.isNotEmpty && _selectedCategory != 'Semua') {
        result =
            result.where((dest) => dest.category == _selectedCategory).toList();
      }

      _filteredDestinations = result;
      _clearError();
    } catch (e) {
      _setError('Failed to filter destinations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Get destination by ID
  Future<Destination?> getDestinationById(String id) async {
    return await _destinationService.getDestinationById(id);
  }

  // Get destination by name
  Future<Destination?> getDestinationByName(String name) async {
    return await _destinationService.getDestinationByName(name);
  }

  // Get available categories
  Future<List<String>> getCategories() async {
    return await _destinationService.getCategories();
  }

  // Get top rated destinations
  Future<List<Destination>> getTopRatedDestinations({int limit = 5}) async {
    return await _destinationService.getTopRatedDestinations(limit: limit);
  }

  // Advanced filtering
  Future<void> filterDestinations({
    String? category,
    int? maxPrice,
    double? minRating,
    bool? isPopular,
  }) async {
    _setLoading(true);
    try {
      _filteredDestinations = await _destinationService.filterDestinations(
        category: category,
        maxPrice: maxPrice,
        minRating: minRating,
        isPopular: isPopular,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to filter destinations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refreshDestinations() async {
    _destinationService.clearCache(); // Clear cache untuk refresh dari API
    await _loadDestinations();
    await _loadPopularDestinations();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Get destinations count by category
  Map<String, int> getDestinationCountByCategory() {
    final Map<String, int> categoryCount = {};
    for (final destination in _destinations) {
      categoryCount[destination.category] =
          (categoryCount[destination.category] ?? 0) + 1;
    }
    return categoryCount;
  }

  // Get price range
  Map<String, int> getPriceRange() {
    if (_destinations.isEmpty) return {'min': 0, 'max': 0};

    final prices = _destinations.map((dest) => dest.basePrice).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }

  // Set nearby destinations from location-based search
  void setNearbyDestinations(List<Map<String, dynamic>> nearbyPlaces) {
    try {
      _destinations =
          nearbyPlaces
              .map(
                (place) => Destination(
                  id: place['id']?.toString() ?? '0',
                  name: place['name'] ?? 'Unknown',
                  description: place['description'] ?? '',
                  location: place['location'] ?? '',
                  basePrice: (place['price'] ?? 0).toInt(),
                  rating: (place['rating'] ?? 0.0).toDouble(),
                  imagePath: place['image_url'] ?? 'assets/bali.png',
                  category: place['category'] ?? 'Other',
                  tags: [],
                  isPopular: (place['is_popular'] ?? 0) == 1,
                ),
              )
              .toList();

      _filteredDestinations = List.from(_destinations);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to process nearby destinations: ${e.toString()}');
    }
  }
}
