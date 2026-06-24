import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import 'notification_screen.dart';
import 'profile_tab.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  lat_lng.LatLng _currentLocation =
      const lat_lng.LatLng(24.8607, 67.0011); // Default Karachi
  bool _isLoading = true;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _currentLocation =
              lat_lng.LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_currentLocation, 15.0);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      appBar: AppBar(
        backgroundColor: BikerColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text("LIVE MAP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                )),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationScreen())),
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
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BikerColors.blue))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.biker_hub.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on_rounded,
                          color: BikerColors.blue, size: 40),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
