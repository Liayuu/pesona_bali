class Destination {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String location;
  final String category;
  final int basePrice;
  final bool isPopular;
  final double rating;
  final List<String> tags;
  final bool isFromApi; // Flag untuk menunjukkan data dari API

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.location,
    required this.category,
    required this.basePrice,
    this.isPopular = false,
    this.rating = 0.0,
    this.tags = const [],
    this.isFromApi = false,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      basePrice: json['basePrice'] ?? 0,
      isPopular: json['isPopular'] ?? false,
      rating: json['rating']?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      isFromApi: json['isFromApi'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'location': location,
      'category': category,
      'basePrice': basePrice,
      'isPopular': isPopular,
      'rating': rating,
      'tags': tags,
      'isFromApi': isFromApi,
    };
  }

  Destination copyWith({
    String? id,
    String? name,
    String? description,
    String? imagePath,
    String? location,
    String? category,
    int? basePrice,
    bool? isPopular,
    double? rating,
    List<String>? tags,
    bool? isFromApi,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      location: location ?? this.location,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      isFromApi: isFromApi ?? this.isFromApi,
    );
  }

  @override
  String toString() {
    return 'Destination(id: $id, name: $name, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Destination && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
