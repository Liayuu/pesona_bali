import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

class TicketController extends ChangeNotifier {
  final TicketService _ticketService = TicketService();

  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Initialize data
  void initialize() {
    loadTickets();
  }

  // Load tickets from service
  Future<void> loadTickets() async {
    _setLoading(true);
    try {
      _tickets = await _ticketService.getAllTickets();
      _clearError();
    } catch (e) {
      _setError('Failed to load tickets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Filter tickets by status
  void filterByStatus(TicketStatus? status) {
    if (status == null) {
      loadTickets(); // Load all tickets
    } else {
      _tickets = _tickets.where((ticket) => ticket.status == status).toList();
      notifyListeners();
    }
  }

  // Get tickets by status
  List<Ticket> getTicketsByStatus(TicketStatus status) {
    return _tickets.where((ticket) => ticket.status == status).toList();
  }

  // Get upcoming tickets
  List<Ticket> getUpcomingTickets() {
    final now = DateTime.now();
    return _tickets
        .where(
          (ticket) =>
              ticket.tripDate.isAfter(now) &&
              ticket.status != TicketStatus.cancelled,
        )
        .toList();
  }

  // Get past tickets
  List<Ticket> getPastTickets() {
    final now = DateTime.now();
    return _tickets.where((ticket) => ticket.tripDate.isBefore(now)).toList();
  }

  // Get ticket by ID
  Ticket? getTicketById(String id) {
    try {
      return _tickets.firstWhere((ticket) => ticket.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new ticket
  Future<String?> createTicket({
    required String destinationId,
    required String destinationName,
    required String destinationImage,
    required String location,
    required DateTime tripDate,
    required String tripTime,
    required int participants,
    required TripType tripType,
    required bool includesTransportation,
    required bool includesAccommodation,
    required bool includesMeals,
    required String userEmail,
    required String userName,
    required String userPhone,
    String? specialRequests,
  }) async {
    try {
      print('Creating ticket for destination: $destinationName'); // Debug log

      final basePrice = _getBasePriceByDestination(destinationName);
      print('Base price: $basePrice'); // Debug log

      final totalPrice = calculateTotalPrice(
        basePrice: basePrice,
        participants: participants,
        includesTransportation: includesTransportation,
        includesAccommodation: includesAccommodation,
        includesMeals: includesMeals,
      );

      print('Total price: $totalPrice'); // Debug log

      final ticket = Ticket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        destinationId: destinationId,
        destinationName: destinationName,
        destinationImage: destinationImage,
        location: location,
        tripDate: tripDate,
        tripTime: tripTime,
        participants: participants,
        totalPrice: totalPrice.toInt(),
        status: TicketStatus.pending,
        tripType: tripType,
        basePrice: basePrice.toInt(),
        includesTransportation: includesTransportation,
        includesAccommodation: includesAccommodation,
        includesMeals: includesMeals,
        userEmail: userEmail,
        userName: userName,
        userPhone: userPhone,
        specialRequests: specialRequests ?? '',
        bookedAt: DateTime.now(),
      );

      print('About to create ticket with service...'); // Debug log
      await _ticketService.createTicket(ticket);
      print('Ticket created successfully, reloading tickets...'); // Debug log
      await loadTickets(); // Refresh the list
      print('Tickets reloaded, returning ticket ID: ${ticket.id}'); // Debug log
      return ticket.id;
    } catch (e) {
      print('Error creating ticket: $e'); // Debug log
      _setError('Failed to create ticket: ${e.toString()}');
      return null;
    }
  }

  // Update ticket status
  Future<bool> updateTicketStatus(
    String ticketId,
    TicketStatus newStatus,
  ) async {
    try {
      await _ticketService.updateTicketStatus(ticketId, newStatus);
      await loadTickets(); // Refresh tickets list
      return true;
    } catch (e) {
      _setError('Failed to update ticket: ${e.toString()}');
      return false;
    }
  }

  // Cancel ticket
  Future<bool> cancelTicket(String ticketId) async {
    return await updateTicketStatus(ticketId, TicketStatus.cancelled);
  }

  // Restore cancelled ticket
  Future<bool> restoreTicket(String ticketId) async {
    return await updateTicketStatus(ticketId, TicketStatus.pending);
  }

  // Delete ticket
  Future<bool> deleteTicket(String ticketId) async {
    try {
      await _ticketService.deleteTicket(ticketId);
      await loadTickets(); // Refresh tickets list
      return true;
    } catch (e) {
      _setError('Failed to delete ticket: ${e.toString()}');
      return false;
    }
  }

  // Calculate total price including additional services
  double calculateTotalPrice({
    required double basePrice,
    required int participants,
    required bool includesTransportation,
    required bool includesAccommodation,
    required bool includesMeals,
  }) {
    double total = basePrice * participants;

    if (includesTransportation) total += 100000 * participants;
    if (includesAccommodation) total += 500000 * participants;
    if (includesMeals) total += 150000 * participants;

    return total;
  }

  // Get base price by destination name
  double _getBasePriceByDestination(String destinationName) {
    const Map<String, int> basePrices = {
      'Mount Batur Sunrise Trek': 350000,
      'Lempuyang Temple Tour': 275000,
      'Ubud Art & Culture': 450000,
      'Mount Agung Hiking': 500000,
      'Jatiluwih Rice Terrace': 200000,
      'Trunyan Village Tour': 300000,
      'GWK Cultural Park': 150000,
    };

    return (basePrices[destinationName] ?? 300000).toDouble();
  }

  // Get statistics
  Map<String, int> getTicketStatistics() {
    return {
      'total': _tickets.length,
      'confirmed': getTicketsByStatus(TicketStatus.confirmed).length,
      'pending': getTicketsByStatus(TicketStatus.pending).length,
      'completed': getTicketsByStatus(TicketStatus.completed).length,
      'cancelled': getTicketsByStatus(TicketStatus.cancelled).length,
      'upcoming': getUpcomingTickets().length,
    };
  }

  // Private helper methods
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
}
