import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/app_theme.dart';
import 'profile_tab.dart';
import 'notification_screen.dart';

class MechanicTab extends StatefulWidget {
  const MechanicTab({super.key});

  @override
  State<MechanicTab> createState() => _MechanicTabState();
}

class _MechanicTabState extends State<MechanicTab> {
  // ─── Data ──────────────────────────────────────────────
  lat_lng.LatLng _currentLocation = const lat_lng.LatLng(24.8607, 67.0011);
  final MapController _mapController = MapController();

  final User? _user = FirebaseAuth.instance.currentUser;
  StreamSubscription<Position>? _positionStream;

  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }

  final List<Map<String, dynamic>> _mechanics = [
    {
      'name': 'Pasha Autos',
      'type': 'Heavy Bike Specialist',
      'distance': '0.8 km',
      'rating': '4.9',
      'reviews': 128,
      'phone': '0300-1234567',
      'address': 'Shop 12, Tariq Road, Karachi',
      'open': true,
      'openTime': '8AM - 10PM',
      'specialties': ['Engine Repair', 'Oil Change', 'Heavy Bikes'],
      'lat': 24.8700,
      'lng': 67.0100,
      'experience': '15 years',
      'color': const Color(0xFF1565C0),
    },
    {
      'name': 'Zafar Workshop',
      'type': 'General Tuning & Oil',
      'distance': '1.5 km',
      'rating': '4.5',
      'reviews': 89,
      'phone': '0311-9876543',
      'address': 'Near Civic Center, Karachi',
      'open': true,
      'openTime': '9AM - 9PM',
      'specialties': ['Tuning', 'Oil Change', 'Brakes'],
      'lat': 24.8500,
      'lng': 66.9900,
      'experience': '10 years',
      'color': const Color(0xFF2E7D32),
    },
    {
      'name': 'Ali Speed Center',
      'type': 'Sports Bike Expert',
      'distance': '2.1 km',
      'rating': '4.7',
      'reviews': 64,
      'phone': '0333-5554444',
      'address': 'Plot 45, PECHS, Karachi',
      'open': false,
      'openTime': '10AM - 8PM',
      'specialties': ['Sports Bikes', 'Tyres', 'Suspension'],
      'lat': 24.8650,
      'lng': 67.0200,
      'experience': '8 years',
      'color': const Color(0xFFE65100),
    },
    {
      'name': 'Bike Care Plus',
      'type': 'Full Service Center',
      'distance': '3.0 km',
      'rating': '4.3',
      'reviews': 45,
      'phone': '0321-7778889',
      'address': 'Block 5, Gulshan, Karachi',
      'open': true,
      'openTime': '8AM - 11PM',
      'specialties': ['All Services', 'Electricals', 'Bodywork'],
      'lat': 24.8420,
      'lng': 67.0050,
      'experience': '5 years',
      'color': const Color(0xFF6A1B9A),
    },
  ];

  int? _selectedMechanic;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      Position position = await _determinePosition();
      if (mounted) {
        setState(() {
          _currentLocation =
              lat_lng.LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation, 14.0);
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() {
            _currentLocation = lat_lng.LatLng(pos.latitude, pos.longitude);
          });
        }
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  List<Map<String, dynamic>> get _sortedMechanics {
    final list = List<Map<String, dynamic>>.from(_mechanics);
    list.sort((a, b) {
      double distA = Geolocator.distanceBetween(_currentLocation.latitude,
          _currentLocation.longitude, a['lat'] as double, a['lng'] as double);
      double distB = Geolocator.distanceBetween(_currentLocation.latitude,
          _currentLocation.longitude, b['lat'] as double, b['lng'] as double);
      return distA.compareTo(distB);
    });
    return list;
  }

  String _getDistanceString(Map<String, dynamic> m) {
    double meters = Geolocator.distanceBetween(
      _currentLocation.latitude,
      _currentLocation.longitude,
      m['lat'] as double,
      m['lng'] as double,
    );
    return "${(meters / 1000).toStringAsFixed(1)} km";
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      appBar: AppBar(
        backgroundColor: BikerColors.darkBlue,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build_circle_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text("MECHANIC LOCATOR",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  )),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileTab())),
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Map Section ──────────────────────────────
              Expanded(
                flex: 4,
                child: _buildMap(),
              ),
              // ── List Section ─────────────────────────────
              _buildListHeader(),
              Expanded(
                flex: 5,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sortedMechanics.length,
                  itemBuilder: (_, i) =>
                      _buildMechanicCard(_sortedMechanics[i], i),
                ),
              ),
            ],
          ),
          // ── My Location Button ───────────────────────
          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton.small(
              onPressed: () => _mapController.move(_currentLocation, 15.0),
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location_rounded,
                  color: BikerColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Map Widget ──────────────────────────────────────────
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.biker_hub.app',
        ),
        MarkerLayer(
          markers: [
            // User Location Marker
            Marker(
              point: _currentLocation,
              width: 60,
              height: 60,
              child: _buildUserMarker(),
            ),
            // Mechanic Markers
            ..._mechanics.map((m) => Marker(
                  point: lat_lng.LatLng(m['lat'] as double, m['lng'] as double),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showMechanicBottomSheet(m),
                    child: Container(
                      decoration: BoxDecoration(
                        color: BikerColors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.build_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildUserMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BikerColors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: BikerColors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: BikerColors.blue.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: BikerColors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text("Nearby Mechanics",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: BikerColors.black,
              )),
        ],
      ),
    );
  }

  // ─── Mechanic Card ───────────────────────────────────────
  Widget _buildMechanicCard(Map<String, dynamic> m, int index) {
    final color = m['color'] as Color;
    final isOpen = m['open'] as bool;
    final isSelected = _selectedMechanic == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMechanic = index);
        _showMechanicBottomSheet(m);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: BikerColors.greyLt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.build_circle_rounded,
                  color: BikerColors.black, size: 26),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: BikerColors.black,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right side
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(isOpen ? "Open" : "Closed",
                      style: const TextStyle(
                        color: BikerColors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.grey, size: 11),
                  Text(_getDistanceString(m),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      )),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mechanic Detail Bottom Sheet ────────────────────────
  void _showMechanicBottomSheet(Map<String, dynamic> m) {
    final color = m['color'] as Color;
    final isOpen = m['open'] as bool;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: BikerColors.greyLt,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.build_circle_rounded,
                      color: BikerColors.black, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: BikerColors.black,
                          )),
                      Text(m['type'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(isOpen ? "Open" : "Closed",
                      style: const TextStyle(
                        color: BikerColors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats Row
            Row(
              children: [
                _buildStatChip(
                    Icons.star_rounded,
                    "${m['rating']} (${m['reviews']} reviews)",
                    const Color(0xFFF9A825)),
                const SizedBox(width: 8),
                _buildStatChip(Icons.location_on_rounded, _getDistanceString(m),
                    BikerColors.blue),
                const SizedBox(width: 8),
                _buildStatChip(
                    Icons.work_rounded, m['experience'] as String, color),
              ],
            ),
            const SizedBox(height: 16),
            // Details
            _buildDetailRow(
                Icons.location_on_rounded, m['address'] as String, color),
            const SizedBox(height: 8),
            _buildDetailRow(
                Icons.access_time_rounded, m['openTime'] as String, color),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.phone_rounded, m['phone'] as String, color),
            const SizedBox(height: 16),
            // Specialties
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: (m['specialties'] as List)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(s as String,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.directions_rounded,
                        size: 18, color: Colors.white),
                    label: const Text("Get Directions",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(text,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                color: BikerColors.black,
                fontSize: 13,
              )),
        ),
      ],
    );
  }
}
