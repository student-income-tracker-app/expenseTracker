import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'app_palette.dart';

class CurrentLocationPage extends StatefulWidget {
  const CurrentLocationPage({super.key});

  @override
  State<CurrentLocationPage> createState() => _CurrentLocationPageState();
}

class _CurrentLocationPageState extends State<CurrentLocationPage> {
  String _status = '';
  String _locationLabel = 'OMAN / MUSCAT';
  bool _hasHome = false;
  LatLng _mapCenter = const LatLng(23.5880, 58.3829);
  final MapController _mapController = MapController();
  _ServiceType _selectedService = _ServiceType.food;
  bool _loadingPlaces = false;
  List<_NearbyPlace> _places = [];

  @override
  void initState() {
    super.initState();
    _loadHome();
    _fetchLocation();
  }

  Future<void> _loadHome() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('home_lat');
    final lng = prefs.getDouble('home_lng');
    if (lat != null && lng != null) {
      setState(() {
        _hasHome = true;
        _locationLabel = 'Home Location';
        _mapCenter = LatLng(lat, lng);
      });
      _mapController.move(_mapCenter, 15);
    }
  }

  Future<void> _saveHome(double lat, double lng, {String? label}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('home_lat', lat);
    await prefs.setDouble('home_lng', lng);
    setState(() {
      _hasHome = true;
      _locationLabel = label ?? 'Home Location';
      _mapCenter = LatLng(lat, lng);
    });
    _mapController.move(_mapCenter, 15);
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _status = 'Checking permissions...';
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = 'Location services are disabled.';
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Location permission denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status = 'Location permission permanently denied.';
      });
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String label = 'Lat ${pos.latitude.toStringAsFixed(4)} / Lng ${pos.longitude.toStringAsFixed(4)}';
    try {
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final country = (place.country ?? '').toUpperCase();
        final city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
        if (country.isNotEmpty && city.isNotEmpty) {
          label = '$country / $city';
        } else if (country.isNotEmpty) {
          label = country;
        }
      }
    } catch (_) {
      // keep fallback label
    }

    setState(() {
      _status = '';
      _locationLabel = 'Current Location';
      _mapCenter = LatLng(pos.latitude, pos.longitude);
    });
    _mapController.move(_mapCenter, 15);
    await _fetchPlaces();

    if (!_hasHome) {
      await _saveHome(pos.latitude, pos.longitude, label: label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final placeMarkers = _places
        .map(
          (place) => Marker(
            point: LatLng(place.lat, place.lng),
            width: 32,
            height: 32,
            child: Icon(
              _serviceIcon(_selectedService),
              color: palette.primary.withOpacity(0.8),
              size: 28,
            ),
          ),
        )
        .toList();
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: palette.primary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Image.asset(
                'images/logo2.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              Text(
                'Current Location',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: palette.primary),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ServiceChip(
                    label: 'Food',
                    selected: _selectedService == _ServiceType.food,
                    onTap: () => _onServiceSelected(_ServiceType.food),
                    palette: palette,
                  ),
                  const SizedBox(width: 8),
                  _ServiceChip(
                    label: 'Transport',
                    selected: _selectedService == _ServiceType.transport,
                    onTap: () => _onServiceSelected(_ServiceType.transport),
                    palette: palette,
                  ),
                  const SizedBox(width: 8),
                  _ServiceChip(
                    label: 'Shopping',
                    selected: _selectedService == _ServiceType.shopping,
                    onTap: () => _onServiceSelected(_ServiceType.shopping),
                    palette: palette,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _fetchLocation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.cardFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _mapCenter,
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.course_project_group16',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _mapCenter,
                                      width: 44,
                                      height: 44,
                                      child: Icon(Icons.location_pin, color: palette.primary, size: 44),
                                    ),
                                    ...placeMarkers,
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _locationLabel,
                          style: TextStyle(color: palette.primary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        if (_status.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _status,
                            style: TextStyle(color: palette.primary, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _hasHome ? 'Tap to refresh current location' : 'Tap to set home location',
                          style: TextStyle(color: palette.primary, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        if (_loadingPlaces)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: CircularProgressIndicator(color: palette.primary),
                          )
                        else if (_places.isEmpty)
                          Text(
                            'No nearby places found.',
                            style: TextStyle(color: palette.primary, fontSize: 12),
                          )
                        else
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              itemCount: _places.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final place = _places[index];
                                return _PlaceTile(place: place, palette: palette);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _serviceIcon(_ServiceType type) {
    switch (type) {
      case _ServiceType.food:
        return Icons.restaurant;
      case _ServiceType.transport:
        return Icons.directions_bus;
      case _ServiceType.shopping:
        return Icons.shopping_bag;
    }
  }

  Future<void> _onServiceSelected(_ServiceType type) async {
    setState(() => _selectedService = type);
    await _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() => _loadingPlaces = true);
    try {
      final query = _buildOverpassQuery(_selectedService, _mapCenter.latitude, _mapCenter.longitude);
      final url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) {
        setState(() {
          _places = [];
          _loadingPlaces = false;
        });
        return;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] is List ? data['elements'] as List : [];
      final places = <_NearbyPlace>[];
      for (final element in elements) {
        if (element is Map) {
          final lat = element['lat'];
          final lng = element['lon'];
          if (lat is num && lng is num) {
            final tags = element['tags'] is Map ? element['tags'] as Map : {};
            final name = (tags['name'] ?? tags['brand'] ?? 'Unnamed').toString();
            final distance = Geolocator.distanceBetween(
              _mapCenter.latitude,
              _mapCenter.longitude,
              lat.toDouble(),
              lng.toDouble(),
            );
            places.add(
              _NearbyPlace(
                name: name,
                lat: lat.toDouble(),
                lng: lng.toDouble(),
                distanceMeters: distance,
              ),
            );
          }
        }
      }
      places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      setState(() {
        _places = places.take(12).toList();
        _loadingPlaces = false;
      });
    } catch (_) {
      setState(() {
        _places = [];
        _loadingPlaces = false;
      });
    }
  }

  String _buildOverpassQuery(_ServiceType type, double lat, double lng) {
    const radius = 2000;
    switch (type) {
      case _ServiceType.food:
        return '[out:json];(node["amenity"~"restaurant|cafe|fast_food"](around:$radius,$lat,$lng););out 20;';
      case _ServiceType.transport:
        return '[out:json];(node["amenity"~"bus_station|taxi|fuel"](around:$radius,$lat,$lng);node["public_transport"="station"](around:$radius,$lat,$lng););out 20;';
      case _ServiceType.shopping:
        return '[out:json];(node["shop"~"supermarket|mall|clothes|convenience"](around:$radius,$lat,$lng););out 20;';
    }
  }

}

enum _ServiceType { food, transport, shopping }

class _NearbyPlace {
  final String name;
  final double lat;
  final double lng;
  final double distanceMeters;

  const _NearbyPlace({
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
  });
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppPalette palette;

  const _ServiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? palette.buttonFill : palette.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: palette.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final _NearbyPlace place;
  final AppPalette palette;

  const _PlaceTile({required this.place, required this.palette});

  @override
  Widget build(BuildContext context) {
    final distanceKm = (place.distanceMeters / 1000);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.cardFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.cardBorder.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Icon(Icons.place, color: palette.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              place.name,
              style: TextStyle(color: palette.primary, fontWeight: FontWeight.w600, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${distanceKm.toStringAsFixed(1)} km',
            style: TextStyle(color: palette.primary.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

