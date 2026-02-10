import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Location location = Location();

  // Default location (San Francisco)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  // Current user location
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;
  bool _isLoading = true;

  // Map markers
  Set<Marker> _markers = {};

  // Sample craft locations (example data)
  final List<Map<String, dynamic>> _craftLocations = [
    {
      'id': 'pottery_shop_1',
      'title': 'Mumbai Pottery Studio',
      'description': 'Traditional ceramic crafts',
      'position': const LatLng(19.0760, 72.8777),
      'type': 'pottery',
    },
    {
      'id': 'textile_shop_1',
      'title': 'Delhi Textile Hub',
      'description': 'Handwoven fabrics & embroidery',
      'position': const LatLng(28.6139, 77.2090),
      'type': 'textile',
    },
    {
      'id': 'jewelry_shop_1',
      'title': 'Jaipur Jewelry Market',
      'description': 'Traditional silver & gemstone jewelry',
      'position': const LatLng(26.9124, 75.7873),
      'type': 'jewelry',
    },
    {
      'id': 'woodwork_shop_1',
      'title': 'Bangalore Woodcraft Studio',
      'description': 'Handcrafted wooden furniture',
      'position': const LatLng(12.9716, 77.5946),
      'type': 'woodwork',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    debugPrint('🗺️ Initializing Google Maps...');

    // Check and request location permission
    await _checkLocationPermission();

    // Get current location if permission granted
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }

    // Add craft location markers
    _addCraftLocationMarkers();

    setState(() {
      _isLoading = false;
    });

    debugPrint('✅ Maps initialization complete');
  }

  Future<void> _checkLocationPermission() async {
    debugPrint('🔒 Checking location permissions...');

    PermissionStatus permission = await Permission.location.status;

    if (permission.isDenied) {
      permission = await Permission.location.request();
    }

    if (permission.isGranted) {
      _locationPermissionGranted = true;
      debugPrint('✅ Location permission granted');
    } else {
      debugPrint('❌ Location permission denied');
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location access to show craft shops near you.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    debugPrint('📍 Getting current location...');

    try {
      LocationData locationData = await location.getLocation();

      setState(() {
        _currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      });

      // Add current location marker
      _addCurrentLocationMarker();

      debugPrint(
        '✅ Current location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
      );
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  void _addCraftLocationMarkers() {
    debugPrint('🏪 Adding craft location markers...');

    for (var craft in _craftLocations) {
      _markers.add(
        Marker(
          markerId: MarkerId(craft['id']),
          position: craft['position'],
          infoWindow: InfoWindow(
            title: craft['title'],
            snippet: craft['description'],
          ),
          icon: _getMarkerIcon(craft['type']),
          onTap: () => _onMarkerTapped(craft),
        ),
      );
    }

    debugPrint('✅ Added ${_craftLocations.length} craft location markers');
  }

  BitmapDescriptor _getMarkerIcon(String craftType) {
    switch (craftType) {
      case 'pottery':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'textile':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      case 'jewelry':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      case 'woodwork':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _onMarkerTapped(Map<String, dynamic> craft) {
    debugPrint('📍 Marker tapped: ${craft['title']}');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                craft['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(craft['description'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(_getCraftIcon(craft['type']), color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    craft['type'].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToLocation(craft['position']);
                },
                child: const Text('View on Map'),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCraftIcon(String craftType) {
    switch (craftType) {
      case 'pottery':
        return Icons.auto_awesome;
      case 'textile':
        return Icons.checkroom;
      case 'jewelry':
        return Icons.diamond;
      case 'woodwork':
        return Icons.carpenter;
      default:
        return Icons.store;
    }
  }

  Future<void> _navigateToLocation(LatLng position) async {
    debugPrint(
      '🎯 Navigating to location: ${position.latitude}, ${position.longitude}',
    );

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) {
      await _getCurrentLocation();
    }

    if (_currentLocation != null) {
      await _navigateToLocation(_currentLocation!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get your location. Please check permissions.',
          ),
        ),
      );
    }
  }

  void _changeMapType() {
    setState(() {
      // Cycle through map types (this is just for demo, normally you'd have a picker)
      // For demo purposes, we'll just show a snackbar
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map type changed! (Feature ready for implementation)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CraftConnect Maps'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _changeMapType,
            icon: const Icon(Icons.layers),
            tooltip: 'Change Map Type',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Maps...'),
                ],
              ),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              markers: _markers,
              myLocationEnabled: _locationPermissionGranted,
              myLocationButtonEnabled: false, // Using custom FAB
              zoomControlsEnabled: false,
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                debugPrint('✅ Google Map created successfully');
              },
              onCameraMove: (CameraPosition position) {
                // Optional: Track camera movements
                debugPrint('📷 Camera moved to: ${position.target}');
              },
              onTap: (LatLng position) {
                debugPrint(
                  '👆 Map tapped at: ${position.latitude}, ${position.longitude}',
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location_fab',
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'refresh_fab',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeMap();
            },
            backgroundColor: Colors.teal,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎨 Discover Local Craft Shops',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Found ${_craftLocations.length} craft locations nearby',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🛑 MapsScreen disposed');
    super.dispose();
  }
}
