enum TicketStatus { pending, confirmed, completed, cancelled }

enum TripType { cultural, adventure, nature, photography, spiritual }

class Ticket {
  final String id;
  final String destinationId;
  final String destinationName;
  final String destinationImage;
  final String location;
  final DateTime tripDate;
  final String tripTime;
  final int participants;
  final TicketStatus status;
  final TripType tripType;
  final int basePrice;
  final bool includesTransportation;
  final bool includesAccommodation;
  final bool includesMeals;
  final int totalPrice;
  final String userEmail;
  final String userName;
  final String userPhone;
  final String specialRequests;
  final DateTime bookedAt;

  Ticket({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.destinationImage,
    required this.location,
    required this.tripDate,
    required this.tripTime,
    required this.participants,
    required this.status,
    required this.tripType,
    required this.basePrice,
    this.includesTransportation = false,
    this.includesAccommodation = false,
    this.includesMeals = false,
    required this.totalPrice,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    this.specialRequests = '',
    required this.bookedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      destinationImage: json['destinationImage'] ?? '',
      location: json['location'] ?? '',
      tripDate: DateTime.parse(json['tripDate'] ?? DateTime.now().toIso8601String()),
      tripTime: json['tripTime'] ?? '',
      participants: json['participants'] ?? 1,
      status: TicketStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TicketStatus.pending,
      ),
      tripType: TripType.values.firstWhere(
        (e) => e.toString().split('.').last == json['tripType'],
        orElse: () => TripType.cultural,
      ),
      basePrice: json['basePrice'] ?? 0,
      includesTransportation: json['includesTransportation'] ?? false,
      includesAccommodation: json['includesAccommodation'] ?? false,
      includesMeals: json['includesMeals'] ?? false,
      totalPrice: json['totalPrice'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      specialRequests: json['specialRequests'] ?? '',
      bookedAt: DateTime.parse(json['bookedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'destinationImage': destinationImage,
      'location': location,
      'tripDate': tripDate.toIso8601String(),
      'tripTime': tripTime,
      'participants': participants,
      'status': status.toString().split('.').last,
      'tripType': tripType.toString().split('.').last,
      'basePrice': basePrice,
      'includesTransportation': includesTransportation,
      'includesAccommodation': includesAccommodation,
      'includesMeals': includesMeals,
      'totalPrice': totalPrice,
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'specialRequests': specialRequests,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  Ticket copyWith({
    String? id,
    String? destinationId,
    String? destinationName,
    String? destinationImage,
    String? location,
    DateTime? tripDate,
    String? tripTime,
    int? participants,
    TicketStatus? status,
    TripType? tripType,
    int? basePrice,
    bool? includesTransportation,
    bool? includesAccommodation,
    bool? includesMeals,
    int? totalPrice,
    String? userEmail,
    String? userName,
    String? userPhone,
    String? specialRequests,
    DateTime? bookedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationImage: destinationImage ?? this.destinationImage,
      location: location ?? this.location,
      tripDate: tripDate ?? this.tripDate,
      tripTime: tripTime ?? this.tripTime,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      tripType: tripType ?? this.tripType,
      basePrice: basePrice ?? this.basePrice,
      includesTransportation: includesTransportation ?? this.includesTransportation,
      includesAccommodation: includesAccommodation ?? this.includesAccommodation,
      includesMeals: includesMeals ?? this.includesMeals,
      totalPrice: totalPrice ?? this.totalPrice,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      specialRequests: specialRequests ?? this.specialRequests,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }

  String get statusText {
    switch (status) {
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.confirmed:
        return 'Confirmed';
      case TicketStatus.completed:
        return 'Completed';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get tripTypeText {
    switch (tripType) {
      case TripType.cultural:
        return 'Cultural';
      case TripType.adventure:
        return 'Adventure';
      case TripType.nature:
        return 'Nature';
      case TripType.photography:
        return 'Photography';
      case TripType.spiritual:
        return 'Spiritual';
    }
  }

  @override
  String toString() {
    return 'Ticket(id: $id, destination: $destinationName, status: $statusText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ticket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
