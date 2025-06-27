import '../models/ticket.dart';
import '../database/database_helper.dart';
import 'api_service.dart';

class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  // Get all tickets (local only untuk demo)
  Future<List<Ticket>> getAllTickets() async {
    try {
      // Get from local database only (disable API for demo)
      List<Map<String, dynamic>> localTickets = await _dbHelper.getTickets();

      // Convert to Ticket objects
      return localTickets
          .map((ticketData) => _convertDbTicketToModel(ticketData))
          .toList();
    } catch (e) {
      print('Error getting tickets: $e');
      return [];
    }
  }

  // Create new ticket (local + API)
  Future<void> createTicket(Ticket ticket) async {
    try {
      print(
        'TicketService: Creating ticket with ID: ${ticket.id}',
      ); // Debug log

      // Convert ticket to API format
      Map<String, dynamic> bookingData = {
        'destination_id': ticket.destinationId,
        'trip_date': ticket.tripDate.toIso8601String(),
        'participants': ticket.participants,
        'trip_type': ticket.tripType.toString(),
        'special_requests': ticket.specialRequests,
        'user_email': ticket.userEmail,
        'user_name': ticket.userName,
        'user_phone': ticket.userPhone,
      };

      print('TicketService: Trying API call...'); // Debug log
      // Try to create booking via API
      Map<String, dynamic>? apiResponse = await _apiService.createBooking(
        bookingData,
      );

      if (apiResponse != null) {
        print('TicketService: API call successful'); // Debug log
        // Update ticket with API response
        ticket = ticket.copyWith(
          id: apiResponse['ticket_number'],
          status: _parseTicketStatus(apiResponse['status']),
        );
      } else {
        print('TicketService: API call failed, using local data'); // Debug log
      }

      // Save to local database
      print('TicketService: Saving to local database...'); // Debug log
      await _dbHelper.insertTicket(_convertTicketToDb(ticket));
      print('TicketService: Ticket saved successfully'); // Debug log
    } catch (e) {
      print('Error creating ticket: $e');
      // Save locally even if API fails
      print('TicketService: Saving locally as fallback...'); // Debug log
      await _dbHelper.insertTicket(_convertTicketToDb(ticket));
      print('TicketService: Fallback save completed'); // Debug log
    }
  }

  // Update ticket status
  Future<void> updateTicketStatus(
    String ticketId,
    TicketStatus newStatus,
  ) async {
    try {
      // Update in local database
      await _dbHelper.updateTicketStatus(ticketId, newStatus.toString());

      // TODO: Sync with API if needed
    } catch (e) {
      print('Error updating ticket status: $e');
    }
  }

  // Delete ticket method
  Future<void> deleteTicket(String ticketId) async {
    try {
      // Delete from local database
      final db = await _dbHelper.database;
      await db.delete(
        'tickets',
        where: 'ticket_number = ?',
        whereArgs: [ticketId],
      );

      // TODO: Also delete from API if needed
    } catch (e) {
      print('Error deleting ticket: $e');
    }
  }

  // Get tickets by status
  Future<List<Ticket>> getTicketsByStatus(TicketStatus status) async {
    List<Ticket> allTickets = await getAllTickets();
    return allTickets.where((ticket) => ticket.status == status).toList();
  }

  // Get upcoming tickets
  Future<List<Ticket>> getUpcomingTickets() async {
    List<Ticket> allTickets = await getAllTickets();
    final now = DateTime.now();
    return allTickets.where((ticket) {
      return ticket.tripDate.isAfter(now) &&
          (ticket.status == TicketStatus.confirmed ||
              ticket.status == TicketStatus.pending);
    }).toList();
  }

  // Get past tickets
  Future<List<Ticket>> getPastTickets() async {
    List<Ticket> allTickets = await getAllTickets();
    final now = DateTime.now();
    return allTickets.where((ticket) {
      return ticket.tripDate.isBefore(now) ||
          ticket.status == TicketStatus.completed;
    }).toList();
  }

  // Helper methods for data conversion
  Ticket _convertDbTicketToModel(Map<String, dynamic> dbData) {
    return Ticket(
      id: dbData['ticket_number'] ?? '',
      destinationId: dbData['destination_id']?.toString() ?? '',
      destinationName: dbData['destination_name'] ?? '',
      destinationImage: dbData['destination_image'] ?? '',
      location: dbData['location'] ?? 'Bali, Indonesia',
      tripDate: DateTime.parse(
        dbData['trip_date'] ?? DateTime.now().toIso8601String(),
      ),
      tripTime: dbData['trip_time'] ?? '',
      participants: dbData['participants'] ?? 1,
      status: _parseTicketStatus(dbData['status']),
      tripType: _parseTripType(dbData['trip_type']),
      basePrice:
          ((dbData['base_price'] is String)
              ? int.tryParse(dbData['base_price']) ?? 0
              : (dbData['base_price'] ?? 0.0).toInt()),
      totalPrice:
          ((dbData['total_price'] is String)
              ? int.tryParse(dbData['total_price']) ?? 0
              : (dbData['total_price'] ?? 0.0).toInt()),
      includesTransportation: (dbData['includes_transportation'] ?? 0) == 1,
      includesAccommodation: (dbData['includes_accommodation'] ?? 0) == 1,
      includesMeals: (dbData['includes_meals'] ?? 0) == 1,
      userEmail: dbData['user_email'] ?? '',
      userName: dbData['user_name'] ?? '',
      userPhone: dbData['user_phone'] ?? '',
      specialRequests: dbData['special_requests'] ?? '',
      bookedAt: DateTime.parse(
        dbData['booked_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> _convertTicketToDb(Ticket ticket) {
    return {
      'ticket_number': ticket.id,
      'user_id': 1, // Default user ID
      'destination_id': int.tryParse(ticket.destinationId) ?? 0,
      'destination_name': ticket.destinationName,
      'destination_image': ticket.destinationImage,
      'trip_date': ticket.tripDate.toIso8601String(),
      'trip_time': ticket.tripTime,
      'participants': ticket.participants,
      'status': ticket.status.toString(),
      'trip_type': ticket.tripType.toString(),
      'base_price': ticket.basePrice,
      'total_price': ticket.totalPrice,
      'includes_transportation': ticket.includesTransportation ? 1 : 0,
      'includes_accommodation': ticket.includesAccommodation ? 1 : 0,
      'includes_meals': ticket.includesMeals ? 1 : 0,
      'user_email': ticket.userEmail,
      'user_name': ticket.userName,
      'user_phone': ticket.userPhone,
      'special_requests': ticket.specialRequests,
      'booked_at': ticket.bookedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _convertApiTicketToLocal(Map<String, dynamic> apiData) {
    return {
      'api_id': apiData['id'],
      'ticket_number': apiData['ticket_number'],
      'user_id': 1,
      'destination_name': apiData['destination_name'],
      'trip_date': apiData['trip_date'],
      'status': apiData['status'],
      'total_price': apiData['total_price'],
      'booked_at': apiData['created_at'],
      'synced_to_api': 1,
    };
  }

  TicketStatus _parseTicketStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return TicketStatus.pending;
      case 'confirmed':
        return TicketStatus.confirmed;
      case 'completed':
        return TicketStatus.completed;
      case 'cancelled':
        return TicketStatus.cancelled;
      default:
        return TicketStatus.pending;
    }
  }

  TripType _parseTripType(String? type) {
    switch (type?.toLowerCase()) {
      case 'adventure':
        return TripType.adventure;
      case 'cultural':
        return TripType.cultural;
      case 'nature':
        return TripType.nature;
      case 'photography':
        return TripType.photography;
      case 'spiritual':
        return TripType.spiritual;
      default:
        return TripType.adventure;
    }
  }
}
