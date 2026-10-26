import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MapScreen — Lecture 21: Maps & Location Services
//
//  What this screen does:
//    1. Asks the user for location permission
//    2. Gets the device's current GPS coordinates
//    3. Shows an OpenStreetMap with:
//         • A blue pin at the user's current location
//         • Three fake "store" markers (red pins) nearby
//
//  Packages used:
//    • geolocator  — reads GPS coordinates and manages permissions
//    • flutter_map — renders the map (OpenStreetMap tiles, free, no API key)
//    • latlong2    — provides the LatLng type for coordinates
// ─────────────────────────────────────────────────────────────────────────────

// Represents a single store on the map
class _Store {
  final String name;
  final LatLng location;
  const _Store(this.name, this.location);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  // null while loading, filled when we get a GPS fix
  Position? _position;

  // Describes what stage we are in
  bool _isLoading = true;
  String? _errorMessage;

  // Fake store locations (offset slightly from wherever the user is)
  // We build these dynamically once we know the user's coordinates.
  List<_Store> _stores = [];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadLocation(); // start the permission + GPS flow
  }

  // ── Location logic ─────────────────────────────────────────────────────────

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Step 1 — Check if location services (GPS) are enabled on the device
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Location services are disabled.\n'
            'Please enable GPS in device settings.';
      });
      return;
    }

    // Step 2 — Check the current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // Step 3 — If not granted, ask the user
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // User tapped "Deny" — cannot proceed
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permission denied.\n'
              'Tap "Try Again" and allow location access.';
        });
        return;
      }
    }

    // Step 4 — If permanently denied, must go to app settings
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Location permission permanently denied.\n'
            'Please enable it in App Settings.';
      });
      return;
    }

    // Step 5 — All good! Fetch the GPS coordinates
    try {
      // LocationAccuracy.high → uses GPS chip (battery intensive but accurate)
      // LocationAccuracy.low  → uses WiFi/cell towers (saves battery)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Build fake store locations relative to the user's position
      final lat = position.latitude;
      final lng = position.longitude;

      setState(() {
        _position = position;
        _stores = [
          _Store('Store A', LatLng(lat + 0.003, lng + 0.004)),
          _Store('Store B', LatLng(lat - 0.005, lng + 0.002)),
          _Store('Store C', LatLng(lat + 0.001, lng - 0.006)),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not get location: $e';
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // State 1: getting location
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location…'),
          ],
        ),
      );
    }

    // State 2: something went wrong
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadLocation, // try again
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // State 3: we have coordinates — show the map
    final userLatLng = LatLng(_position!.latitude, _position!.longitude);
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // ── The Map ──────────────────────────────────────────────────────────
        FlutterMap(
          options: MapOptions(
            initialCenter: userLatLng,
            initialZoom: 14, // zoom 14 ≈ neighbourhood level
          ),
          children: [
            // TileLayer downloads map image tiles from OpenStreetMap servers.
            // {z} = zoom level, {x}/{y} = tile grid coordinates.
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Good practice: identify your app to the tile server
              userAgentPackageName: 'com.example.flutter_application_2',
            ),

            // MarkerLayer draws pins on top of the map tiles
            MarkerLayer(
              markers: [
                // User's location — blue pin
                Marker(
                  point: userLatLng,
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.my_location,
                    color: primary,
                    size: 40,
                  ),
                ),

                // Store markers — red pins
                ..._stores.map(
                  (store) => Marker(
                    point: store.location,
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      // Tap a store pin to see its name
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(store.name),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.store,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // ── Legend card ───────────────────────────────────────────────────────
        Positioned(
          bottom: 16,
          left: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Icon(Icons.my_location, color: primary, size: 18),
                    const SizedBox(width: 6),
                    const Text('Your location'),
                  ]),
                  const SizedBox(height: 4),
                  const Row(children: [
                    Icon(Icons.store, color: Colors.red, size: 18),
                    SizedBox(width: 6),
                    Text('Nearby stores (tap for name)'),
                  ]),
                ],
              ),
            ),
          ),
        ),

        // ── Accuracy badge ────────────────────────────────────────────────────
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Accuracy: ${_position!.accuracy.toStringAsFixed(0)} m',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
