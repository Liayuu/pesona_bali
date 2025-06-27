import 'package:flutter/material.dart';
import 'destination_detail_screen.dart';
import 'notification_screen.dart';
import 'ticket_screen.dart';
import 'bookmark_screen.dart';
import '../widgets/profile_sidebar.dart';
import '../controllers/destination_controller.dart';
import '../services/location_service.dart';
import '../database/database_helper.dart';
import 'package:geolocator/geolocator.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final DestinationController _destinationController = DestinationController();
  final LocationService _locationService = LocationService();
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.apps, 'label': 'Semua'},
    {'icon': Icons.terrain, 'label': 'Gunung'},
    {'icon': Icons.beach_access, 'label': 'Pantai'},
    {'icon': Icons.park, 'label': 'Taman'},
  ];
  int selectedCategoryIndex = 0;
  bool isProfileSidebarOpen = false;
  bool isLocationSearching = false;

  @override
  void initState() {
    super.initState();
    _destinationController.initialize();
    _destinationController.addListener(() {
      setState(() {}); // Refresh UI when destinations change
    });
    searchController.addListener(_filterDestinations);
  }

  void _filterDestinations() {
    final query = searchController.text;
    _destinationController.searchDestinations(query);
  }

  @override
  void dispose() {
    searchController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _findNearbyDestinations() async {
    setState(() {
      isLocationSearching = true;
    });

    try {
      // Show loading with location icon animation
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
              Expanded(
                child: Text(
                  '🛰️ Getting your GPS location...',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 10),
        ),
      );

      Position? position = await _locationService.getCurrentLocation();

      if (position != null) {
        // Show location found feedback
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Location found! Searching nearby places...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        // Get nearby destinations from database
        final dbHelper = DatabaseHelper();
        List<Map<String, dynamic>> nearbyPlaces = await dbHelper
            .getNearbyDestinations(
              position.latitude,
              position.longitude,
              50.0, // 50km radius
            );

        // Small delay to show searching message
        await Future.delayed(const Duration(milliseconds: 1500));
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (nearbyPlaces.isNotEmpty) {
          // Update the destination controller with nearby places
          _destinationController.setNearbyDestinations(nearbyPlaces);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Found ${nearbyPlaces.length} destinations within 50km of your location!',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View All',
                textColor: Colors.white,
                onPressed: () {
                  // Clear search to show all nearby destinations
                  searchController.clear();
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ No destinations found within 50km. Try expanding search radius or check different area.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }

        // Update user location in database
        await dbHelper.updateUserLocation(
          1, // Default user ID
          position.latitude,
          position.longitude,
          await _locationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Unable to get your location. Please check GPS settings.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () async {
                // Open location settings
                await Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLocationSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookmarkScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicketScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: '',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLocationSearching ? null : _findNearbyDestinations,
        backgroundColor: isLocationSearching ? Colors.grey : Colors.blue,
        tooltip:
            isLocationSearching
                ? 'Searching nearby places...'
                : 'Find places near me',
        heroTag: "nearMeButton",
        child:
            isLocationSearching
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.near_me, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isProfileSidebarOpen = true;
                          });
                        },
                        child: const Icon(Icons.person, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      Text(
                        'Pesona Bali',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          foreground:
                              Paint()
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
                              // Filter destinations by selected category
                              if (index == 0) {
                                // Show all destinations if first category is selected
                                _destinationController.clearFilters();
                              } else {
                                // Filter by specific category
                                _destinationController.selectCategory(
                                  cat['label'],
                                );
                              }
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: isSelected ? 55 : 50,
                                height: isSelected ? 55 : 50,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : Colors.blue[100],
                                  shape: BoxShape.circle,
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                          : null,
                                ),
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: isSelected ? 1.1 : 1.0,
                                  child: Icon(
                                    cat['icon'],
                                    color:
                                        isSelected ? Colors.white : Colors.blue,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: isSelected ? 13 : 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected ? Colors.blue : Colors.black87,
                                ),
                                child: Text(cat['label']),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text(
                    'Popular Destinations',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _destinationController,
                      builder: (context, child) {
                        final destinations =
                            _destinationController
                                    .filteredDestinations
                                    .isNotEmpty
                                ? _destinationController.filteredDestinations
                                : _destinationController.popularDestinations;

                        if (_destinationController.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_destinationController.errorMessage.isNotEmpty) {
                          return Center(
                            child: Text(_destinationController.errorMessage),
                          );
                        }

                        return GridView.builder(
                          itemCount: destinations.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3 / 4,
                              ),
                          itemBuilder: (context, index) {
                            final dest = destinations[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DestinationDetailScreen(
                                          imagePath: dest.imagePath,
                                          destinationName: dest.name,
                                          destinationDescription:
                                              dest.description,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(dest.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dest.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isProfileSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  isProfileSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const SizedBox.expand(),
              ),
            ),
          if (isProfileSidebarOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ProfileSidebar(
                onClose: () {
                  setState(() {
                    isProfileSidebarOpen = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
