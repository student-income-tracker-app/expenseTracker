import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
  final Map<_ServiceType, List<_NearbyPlace>> _placesCache = {};
  DateTime? _lastFetchAt;

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
    final visiblePlaces = _places.isEmpty ? _buildFallbackPlaces() : _places;
    final placeMarkers = visiblePlaces
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _fetchLocation,
                              icon: const Icon(Icons.my_location, size: 18),
                              label: const Text('Refresh location'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openExternalMap(
                                _mapCenter.latitude,
                                _mapCenter.longitude,
                                category: _serviceSearchLabel(_selectedService),
                              ),
                              icon: const Icon(Icons.map_outlined, size: 18),
                              label: const Text('Open in maps'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_loadingPlaces)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: CircularProgressIndicator(color: palette.primary),
                        )
                      else
                        SizedBox(
                          height: 150,
                          child: ListView.separated(
                            itemCount: visiblePlaces.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final place = visiblePlaces[index];
                              return _PlaceTile(
                                place: place,
                                palette: palette,
                                onOpenMap: () => _openExternalMap(
                                  place.lat,
                                  place.lng,
                                  category: place.name,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
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
    setState(() {
      _selectedService = type;
      _places = _placesCache[type] ?? _buildFallbackPlaces();
    });
    await _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    final now = DateTime.now();
    final hasFreshCache = _placesCache.containsKey(_selectedService) &&
        _lastFetchAt != null &&
        now.difference(_lastFetchAt!).inSeconds < 90;
    if (hasFreshCache) {
      setState(() {
        _places = _placesCache[_selectedService]!;
        _loadingPlaces = false;
        _status = '';
      });
      return;
    }

    setState(() {
      _loadingPlaces = true;
      _status = 'Searching nearby places...';
    });
    try {
      final query = _buildOverpassQuery(_selectedService, _mapCenter.latitude, _mapCenter.longitude);
      final data = await _fetchOverpassData(query);
      if (data == null) {
        setState(() {
          _places = [];
          _loadingPlaces = false;
          _status = 'Could not load nearby places right now.';
        });
        return;
      }
      final elements = data['elements'] is List ? data['elements'] as List : [];
      final places = <_NearbyPlace>[];
      for (final element in elements) {
        if (element is Map) {
          final point = _extractLatLng(element);
          if (point == null) continue;
          final tags = element['tags'] is Map ? element['tags'] as Map : {};
          final name = (tags['name'] ?? tags['brand'] ?? 'Unnamed').toString();
          final distance = Geolocator.distanceBetween(
            _mapCenter.latitude,
            _mapCenter.longitude,
            point.latitude,
            point.longitude,
          );
          places.add(
            _NearbyPlace(
              name: name,
              lat: point.latitude,
              lng: point.longitude,
              distanceMeters: distance,
            ),
          );
        }
      }
      places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      final finalPlaces = places.isEmpty ? _buildFallbackPlaces() : places;
      setState(() {
        _places = finalPlaces.take(12).toList();
        _placesCache[_selectedService] = _places;
        _lastFetchAt = DateTime.now();
        _loadingPlaces = false;
        _status = places.isEmpty
            ? 'Live places unavailable. Showing suggested nearby places.'
            : '';
      });
    } catch (_) {
      final fallback = _buildFallbackPlaces();
      setState(() {
        _places = fallback;
        _placesCache[_selectedService] = _places;
        _lastFetchAt = DateTime.now();
        _loadingPlaces = false;
        _status = 'Live places unavailable. Showing suggested nearby places.';
      });
    }
  }

  String _buildOverpassQuery(_ServiceType type, double lat, double lng) {
    const radius = 5000;
    switch (type) {
      case _ServiceType.food:
        return '[out:json];('
            'node["amenity"~"restaurant|cafe|fast_food"](around:$radius,$lat,$lng);'
            'way["amenity"~"restaurant|cafe|fast_food"](around:$radius,$lat,$lng);'
            'relation["amenity"~"restaurant|cafe|fast_food"](around:$radius,$lat,$lng);'
            'node["shop"~"bakery|supermarket|convenience"](around:$radius,$lat,$lng);'
            'way["shop"~"bakery|supermarket|convenience"](around:$radius,$lat,$lng);'
            'relation["shop"~"bakery|supermarket|convenience"](around:$radius,$lat,$lng);'
            ');out center 60;';
      case _ServiceType.transport:
        return '[out:json];('
            'node["amenity"~"bus_station|taxi|fuel"](around:$radius,$lat,$lng);'
            'way["amenity"~"bus_station|taxi|fuel"](around:$radius,$lat,$lng);'
            'relation["amenity"~"bus_station|taxi|fuel"](around:$radius,$lat,$lng);'
            'node["public_transport"="station"](around:$radius,$lat,$lng);'
            'way["public_transport"="station"](around:$radius,$lat,$lng);'
            'relation["public_transport"="station"](around:$radius,$lat,$lng);'
            'node["highway"="bus_stop"](around:$radius,$lat,$lng);'
            ');out center 60;';
      case _ServiceType.shopping:
        return '[out:json];('
            'node["shop"~"supermarket|mall|clothes|convenience"](around:$radius,$lat,$lng);'
            'way["shop"~"supermarket|mall|clothes|convenience"](around:$radius,$lat,$lng);'
            'relation["shop"~"supermarket|mall|clothes|convenience"](around:$radius,$lat,$lng);'
            ');out center 60;';
    }
  }

  Future<Map<String, dynamic>?> _fetchOverpassData(String query) async {
    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass.openstreetmap.ru/api/interpreter',
    ];
    for (final endpoint in endpoints) {
      try {
        final url = Uri.parse(endpoint);
        final response = await http.post(
          url,
          headers: const {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          },
          body: {'data': query},
        ).timeout(const Duration(seconds: 4));
        if (response.statusCode != 200) continue;
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } catch (_) {
        // try next endpoint
      }
    }
    return null;
  }

  List<_NearbyPlace> _buildFallbackPlaces() {
    final presets = _fallbackNamesFor(_selectedService);
    final offsets = <List<double>>[
      [0.0040, 0.0025],
      [-0.0035, 0.0018],
      [0.0020, -0.0030],
      [-0.0025, -0.0020],
      [0.0050, -0.0015],
      [-0.0045, 0.0032],
    ];
    final result = <_NearbyPlace>[];
    for (var i = 0; i < presets.length && i < offsets.length; i++) {
      final lat = _mapCenter.latitude + offsets[i][0];
      final lng = _mapCenter.longitude + offsets[i][1];
      final distance = Geolocator.distanceBetween(
        _mapCenter.latitude,
        _mapCenter.longitude,
        lat,
        lng,
      );
      result.add(
        _NearbyPlace(
          name: presets[i],
          lat: lat,
          lng: lng,
          distanceMeters: distance,
        ),
      );
    }
    result.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return result;
  }

  List<String> _fallbackNamesFor(_ServiceType type) {
    switch (type) {
      case _ServiceType.food:
        return const [
          'Nearby Restaurant',
          'Coffee Shop',
          'Fast Food Point',
          'Bakery',
          'Family Restaurant',
          'Snack Corner',
        ];
      case _ServiceType.transport:
        return const [
          'Bus Stop',
          'Taxi Point',
          'Fuel Station',
          'Transport Hub',
          'Car Service',
          'Public Station',
        ];
      case _ServiceType.shopping:
        return const [
          'Supermarket',
          'Shopping Store',
          'Clothes Shop',
          'Mini Market',
          'Mall',
          'Convenience Shop',
        ];
    }
  }

  LatLng? _extractLatLng(Map element) {
    final lat = element['lat'];
    final lng = element['lon'];
    if (lat is num && lng is num) {
      return LatLng(lat.toDouble(), lng.toDouble());
    }
    final center = element['center'];
    if (center is Map) {
      final cLat = center['lat'];
      final cLng = center['lon'];
      if (cLat is num && cLng is num) {
        return LatLng(cLat.toDouble(), cLng.toDouble());
      }
    }
    return null;
  }

  String _serviceSearchLabel(_ServiceType type) {
    switch (type) {
      case _ServiceType.food:
        return 'food';
      case _ServiceType.transport:
        return 'transport';
      case _ServiceType.shopping:
        return 'shopping';
    }
  }

  Future<void> _openExternalMap(
    double lat,
    double lng, {
    String? category,
  }) async {
    final query = (category == null || category.trim().isEmpty)
        ? '$lat,$lng'
        : '${category.trim()} near $lat,$lng';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      setState(() {
        _status = 'Could not open maps app on this device.';
      });
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
  final VoidCallback onOpenMap;

  const _PlaceTile({
    required this.place,
    required this.palette,
    required this.onOpenMap,
  });

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
          const SizedBox(width: 6),
          IconButton(
            onPressed: onOpenMap,
            icon: Icon(Icons.open_in_new, color: palette.primary, size: 18),
            tooltip: 'Open in maps',
          ),
        ],
      ),
    );
  }
}

