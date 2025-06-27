import 'package:flutter/material.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';
import 'book_trip_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with WidgetsBindingObserver {
  final TicketController _ticketController = TicketController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTickets();
    // Add listener to refresh when data changes
    _ticketController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticketController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh tickets when app comes back to foreground
      _loadTickets();
    }
  }

  Future<void> _loadTickets() async {
    await _ticketController.loadTickets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showFilterDialog();
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body:
          _ticketController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _ticketController.tickets.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadTickets,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ticketController.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _ticketController.tickets[index];
                    return _buildTicketCard(ticket);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate and wait for result, then refresh tickets
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookTripScreen()),
          );
          // Refresh tickets when returning from booking
          _loadTickets();
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Trip'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tickets found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book your first adventure!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookTripScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(ticket.destinationImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.destinationName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(ticket.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(
                  Icons.calendar_today,
                  'Date',
                  '${ticket.tripDate.day}/${ticket.tripDate.month}/${ticket.tripDate.year}',
                ),
                const SizedBox(width: 20),
                _buildInfoItem(Icons.access_time, 'Time', ticket.tripTime),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(
                  Icons.people,
                  'Participants',
                  '${ticket.participants}',
                ),
                const SizedBox(width: 20),
                _buildInfoItem(
                  Icons.attach_money,
                  'Price',
                  'Rp ${ticket.totalPrice.toStringAsFixed(0)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showTicketDetails(ticket);
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (ticket.status == TicketStatus.confirmed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _downloadTicket(ticket),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Download'),
                    ),
                  ),
                if (ticket.status == TicketStatus.pending ||
                    ticket.status == TicketStatus.confirmed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelTicket(ticket),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.confirmed:
        return Colors.green;
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.cancelled:
        return Colors.red;
      case TicketStatus.completed:
        return Colors.blue;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Tickets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Tickets'),
                onTap: () {
                  _ticketController.filterByStatus(null);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Confirmed'),
                onTap: () {
                  _ticketController.filterByStatus(TicketStatus.confirmed);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pending'),
                onTap: () {
                  _ticketController.filterByStatus(TicketStatus.pending);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Completed'),
                onTap: () {
                  _ticketController.filterByStatus(TicketStatus.completed);
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTicketDetails(Ticket ticket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ticket.destinationName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ticket ID: ${ticket.id}'),
              const SizedBox(height: 8),
              Text('Location: ${ticket.location}'),
              const SizedBox(height: 8),
              Text(
                'Date: ${ticket.tripDate.day}/${ticket.tripDate.month}/${ticket.tripDate.year}',
              ),
              const SizedBox(height: 8),
              Text('Participants: ${ticket.participants}'),
              const SizedBox(height: 8),
              Text('Total Price: Rp ${ticket.totalPrice.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              Text(
                'Status: ${ticket.status.toString().split('.').last.toUpperCase()}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _downloadTicket(Ticket ticket) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ticket for ${ticket.destinationName}...'),
        backgroundColor: Colors.green,
      ),
    );
    // Implement actual download logic here
  }

  // Cancel ticket functionality
  void _cancelTicket(Ticket ticket) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Cancel Booking?'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to cancel this booking?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('• Destination: ${ticket.destinationName}'),
                      Text('• Date: ${ticket.tripDate.day}/${ticket.tripDate.month}/${ticket.tripDate.year}'),
                      Text('• Participants: ${ticket.participants}'),
                      Text('• Total: Rp ${ticket.totalPrice.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. The booking will be permanently cancelled.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Booking'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _confirmCancelTicket(ticket);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCancelTicket(Ticket ticket) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Text('Cancelling booking...'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Cancel the ticket
      bool success = await _ticketController.cancelTicket(ticket.id);

      if (success) {
        // Refresh ticket list
        await _loadTickets();
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Booking cancelled successfully!\nTicket ID: ${ticket.id}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () {
                  _undoCancelTicket(ticket);
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Failed to cancel booking. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Undo cancel functionality (restore ticket)
  void _undoCancelTicket(Ticket ticket) async {
    try {
      bool success = await _ticketController.restoreTicket(ticket.id);
      
      if (success) {
        await _loadTickets();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.restore, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Booking restored successfully!'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore booking: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
