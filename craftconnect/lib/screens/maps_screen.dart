import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;
  bool _isLoading = true;

  final Set<Marker> _markers = {};

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
    await _checkLocationPermission();

    if (_locationPermissionGranted) {
      await _listenToLiveLocation();
    }

    _addCraftLocationMarkers();

    setState(() => _isLoading = false);
  }

  Future<void> _checkLocationPermission() async {
    ph.PermissionStatus permission = await ph.Permission.location.status;

    if (permission.isDenied) {
      permission = await ph.Permission.location.request();
    }

    if (permission.isGranted) {
      _locationPermissionGranted = true;
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _listenToLiveLocation() async {
    _locationSubscription?.cancel();

    _locationSubscription = location.onLocationChanged.listen(
      (LocationData data) async {
        if (data.latitude == null || data.longitude == null) return;

        final LatLng newPosition =
            LatLng(data.latitude!, data.longitude!);

        setState(() {
          _currentLocation = newPosition;

          _markers.removeWhere(
            (m) => m.markerId.value == 'current_location',
          );

          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: newPosition,
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        });

        if (_controller.isCompleted) {
          final mapController = await _controller.future;
          mapController.animateCamera(
            CameraUpdate.newLatLng(newPosition),
          );
        }
      },
    );
  }

  void _addCraftLocationMarkers() {
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
        ),
      );
    }
  }

  BitmapDescriptor _getMarkerIcon(String type) {
    switch (type) {
      case 'pottery':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case 'textile':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet);
      case 'jewelry':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow);
      case 'woodwork':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'Enable location access to view nearby craft shops'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ph.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              myLocationEnabled: _locationPermissionGranted,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          if (_currentLocation != null &&
              _controller.isCompleted) {
            final controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newLatLng(_currentLocation!),
            );
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
