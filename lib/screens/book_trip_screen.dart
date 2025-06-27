import 'package:flutter/material.dart';
import '../controllers/ticket_controller.dart';
import '../models/ticket.dart';
import 'ticket_screen.dart';

class BookTripScreen extends StatefulWidget {
  final String? destinationName;
  final String? destinationImage;

  const BookTripScreen({
    super.key,
    this.destinationName,
    this.destinationImage,
  });

  @override
  State<BookTripScreen> createState() => _BookTripScreenState();
}

class _BookTripScreenState extends State<BookTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestController = TextEditingController();
  final TicketController _ticketController = TicketController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedDestination = '';
  String _selectedTripType = 'Cultural';
  int _participantCount = 0;
  bool _needsTransportation = false;
  bool _needsAccommodation = false;
  bool _needsMeals = false;

  final List<String> _destinations = [
    'Mount Batur Sunrise Trek',
    'Lempuyang Temple Tour',
    'Ubud Art & Culture',
    'Mount Agung Hiking',
    'Jatiluwih Rice Terrace',
    'Trunyan Village Tour',
    'GWK Cultural Park',
  ];

  final List<String> _tripTypes = [
    'Cultural',
    'Adventure',
    'Nature',
    'Photography',
    'Spiritual',
  ];

  final Map<String, int> _basePrices = {
    'Mount Batur Sunrise Trek': 350000,
    'Lempuyang Temple Tour': 275000,
    'Ubud Art & Culture': 450000,
    'Mount Agung Hiking': 500000,
    'Jatiluwih Rice Terrace': 200000,
    'Trunyan Village Tour': 300000,
    'GWK Cultural Park': 150000,
  };

  @override
  void initState() {
    super.initState();
    // Set default destination, ensuring it exists in the list
    if (widget.destinationName != null &&
        _destinations.contains(widget.destinationName)) {
      _selectedDestination = widget.destinationName!;
    } else {
      _selectedDestination = _destinations[0];
    }
    _nameController.text = 'Citra Anggrika'; // Pre-fill with user data
    _emailController.text = 'citra.anggrika@email.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  int _calculateTotalPrice() {
    // Jika tidak ada participants, harga 0
    if (_participantCount == 0) return 0;

    int basePrice = _basePrices[_selectedDestination] ?? 0;
    int total = basePrice * _participantCount;

    if (_needsTransportation) total += 100000 * _participantCount;
    if (_needsAccommodation) total += 500000 * _participantCount;
    if (_needsMeals) total += 150000 * _participantCount;

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Trip'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Selection
              _buildSectionHeader('Trip Details'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Destination',
                          prefixIcon: Icon(Icons.place),
                        ),
                        value: _selectedDestination,
                        items:
                            _destinations.map((dest) {
                              return DropdownMenuItem(
                                value: dest,
                                child: Text(dest),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDestination = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a destination';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Trip Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _selectedTripType,
                        items:
                            _tripTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTripType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Date & Time
              _buildSectionHeader('Schedule'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                        subtitle: const Text('Trip date'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          _selectedTime == null
                              ? 'Select Time'
                              : _selectedTime!.format(context),
                        ),
                        subtitle: const Text('Start time'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 6, minute: 0),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Participants
              _buildSectionHeader('Participants'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Number of Participants',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                _participantCount > 0
                                    ? () => setState(() => _participantCount--)
                                    : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_participantCount',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _participantCount < 10
                                    ? () => setState(() => _participantCount++)
                                    : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Personal Information
              _buildSectionHeader('Personal Information'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Additional Services
              _buildSectionHeader('Additional Services'),
              Card(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Transportation'),
                      subtitle: const Text(
                        'Pick-up and drop-off service (+Rp 100,000/person)',
                      ),
                      value: _needsTransportation,
                      onChanged: (value) {
                        setState(() {
                          _needsTransportation = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Accommodation'),
                      subtitle: const Text(
                        'Hotel/homestay booking (+Rp 500,000/person)',
                      ),
                      value: _needsAccommodation,
                      onChanged: (value) {
                        setState(() {
                          _needsAccommodation = value!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Meals'),
                      subtitle: const Text(
                        'Breakfast, lunch, and dinner (+Rp 150,000/person)',
                      ),
                      value: _needsMeals,
                      onChanged: (value) {
                        setState(() {
                          _needsMeals = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Special Requests
              _buildSectionHeader('Special Requests'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _specialRequestController,
                    decoration: const InputDecoration(
                      labelText: 'Special Requests (Optional)',
                      hintText: 'Any special requirements or requests...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Price Summary
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        'Base Price',
                        _participantCount == 0
                            ? 'Rp 0 (0 participants)'
                            : 'Rp ${(_basePrices[_selectedDestination] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} x $_participantCount person${_participantCount > 1 ? 's' : ''}',
                      ),
                      if (_needsTransportation)
                        _buildPriceRow(
                          'Transportation',
                          'Rp ${(100000 * _participantCount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        ),
                      if (_needsAccommodation)
                        _buildPriceRow(
                          'Accommodation',
                          'Rp ${(500000 * _participantCount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        ),
                      if (_needsMeals)
                        _buildPriceRow(
                          'Meals',
                          'Rp ${(150000 * _participantCount).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${_calculateTotalPrice().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Book Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _participantCount > 0 ? _submitBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _participantCount > 0 ? Colors.blue : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _participantCount == 0
                        ? 'Select Participants'
                        : 'Book Trip',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _submitBooking() {
    // Comprehensive validation with specific error messages
    List<String> missingFields = [];

    // Check required fields
    if (_nameController.text.trim().isEmpty) {
      missingFields.add('Full Name');
    }
    if (_emailController.text.trim().isEmpty) {
      missingFields.add('Email');
    }
    if (_phoneController.text.trim().isEmpty) {
      missingFields.add('Phone');
    }
    if (_selectedDate == null) {
      missingFields.add('Trip Date');
    }
    if (_selectedTime == null) {
      missingFields.add('Trip Time');
    }
    if (_participantCount == 0) {
      missingFields.add('Number of Participants (must be at least 1)');
    }

    // If there are missing fields, show specific error message
    if (missingFields.isNotEmpty) {
      String errorMessage = 'Please fill in the following required fields:\n';
      for (int i = 0; i < missingFields.length; i++) {
        errorMessage += '• ${missingFields[i]}';
        if (i < missingFields.length - 1) {
          errorMessage += '\n';
        }
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
                'Missing Required Fields',
                style: TextStyle(color: Colors.red),
              ),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // Additional form validation (email format, etc.)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Destination: $_selectedDestination'),
                Text(
                  'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
                Text('Time: ${_selectedTime!.format(context)}'),
                Text('Participants: $_participantCount'),
                Text(
                  'Total: Rp ${_calculateTotalPrice().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                ),
                const SizedBox(height: 12),
                const Text('Are you sure you want to book this trip?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _confirmBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    print('_confirmBooking called'); // Debug log

    // Store current context before any async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop(); // Close confirmation dialog

    try {
      print('Creating ticket...'); // Debug log
      // Create ticket using controller
      final ticketId = await _ticketController.createTicket(
        destinationId: _selectedDestination,
        destinationName: _selectedDestination,
        destinationImage: widget.destinationImage ?? 'assets/bali.png',
        location: 'Bali, Indonesia', // Default location
        tripDate: _selectedDate!,
        tripTime: _selectedTime!.format(context),
        participants: _participantCount,
        tripType:
            _selectedTripType == 'Cultural'
                ? TripType.cultural
                : _selectedTripType == 'Adventure'
                ? TripType.adventure
                : _selectedTripType == 'Nature'
                ? TripType.nature
                : _selectedTripType == 'Photography'
                ? TripType.photography
                : TripType.spiritual,
        includesTransportation: _needsTransportation,
        includesAccommodation: _needsAccommodation,
        includesMeals: _needsMeals,
        userEmail: _emailController.text,
        userName: _nameController.text,
        userPhone: _phoneController.text,
        specialRequests: _specialRequestController.text,
      );

      print('Ticket created with ID: $ticketId'); // Debug log

      if (ticketId != null) {
        print('Showing success dialog'); // Debug log
        // Show success dialog with WhatsApp option
        if (mounted) {
          _showBookingSuccessDialog(ticketId);
        }
      } else {
        print('Ticket creation failed'); // Debug log
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to book trip. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _confirmBooking: $e'); // Debug log
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error booking trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBookingSuccessDialog(String ticketId) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Booking Confirmed!'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your trip has been booked successfully!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ticket ID: $ticketId',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('• Destination: $_selectedDestination'),
                        Text(
                          '• Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                        Text('• Time: ${_selectedTime!.format(context)}'),
                        Text('• Participants: $_participantCount'),
                        Text(
                          '• Total: Rp ${_calculateTotalPrice().toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can view and manage your tickets in the Tickets section.',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close success dialog
                  Navigator.pop(context); // Go back to previous screen

                  // Show success snackbar
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Trip booked successfully! Ticket ID: $ticketId',
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'View Tickets',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TicketScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              ),
            ],
          ),
    );
  }
}
