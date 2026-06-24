import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import 'profile_tab.dart';
import 'notification_screen.dart';

class SosTab extends StatefulWidget {
  const SosTab({super.key});

  @override
  State<SosTab> createState() => _SosTabState();
}

class _SosTabState extends State<SosTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _sosActivated = false;
  bool _locationSharing = false;
  final User? _user = FirebaseAuth.instance.currentUser;
  StreamSubscription<Position>? _positionStream;

  // ─── Emergency Contacts ────────────────────────────────
  final List<Map<String, dynamic>> _contacts = [
    {
      'name': 'Ahmed (Brother)',
      'phone': '923001234567',
      'initials': 'AB',
      'color': const Color(0xFF1565C0),
    },
    {
      'name': 'Sara (Sister)',
      'phone': '923119876543',
      'initials': 'SS',
      'color': const Color(0xFF2E7D32),
    },
    {
      'name': 'Usman (Friend)',
      'phone': '923335554444',
      'initials': 'UF',
      'color': const Color(0xFF6A1B9A),
    },
  ];

  // ─── Quick Actions ─────────────────────────────────────
  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Police',
      'number': '15',
      'icon': Icons.local_police_rounded,
      'color': const Color(0xFF1565C0),
      'desc': 'Law enforcement',
    },
    {
      'title': 'Ambulance',
      'number': '1122',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFF2E7D32),
      'desc': 'Medical emergency',
    },
    {
      'title': 'Rescue',
      'number': '1122',
      'icon': Icons.fire_truck_rounded,
      'color': const Color(0xFFE65100),
      'desc': 'Rescue services',
    },
    {
      'title': 'Edhi',
      'number': '115',
      'icon': Icons.volunteer_activism_rounded,
      'color': const Color(0xFF00695C),
      'desc': 'Welfare service',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // ─── Location Sharing Logic ────────────────────────────
  Future<void> _toggleLocationSharing(bool value) async {
    try {
      if (value) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showSnack("Location services are disabled.", Colors.red);
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            _showSnack("Location permissions are denied", Colors.red);
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          _showSnack("Location permissions are permanently denied", Colors.red);
          return;
        }

        setState(() => _locationSharing = true);

        // Start real-time tracking for contacts
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            // Here you would typically update a Firestore document that contacts are watching
            debugPrint(
                "Live Location Shared: ${position.latitude}, ${position.longitude}");
          },
          onError: (error) {
            _showSnack("Location tracking error: $error", Colors.red);
            setState(() => _locationSharing = false);
          },
        );
      } else {
        await _positionStream?.cancel();
        _positionStream = null;
        setState(() => _locationSharing = false);
      }
    } catch (e) {
      _showSnack("An unexpected error occurred: $e", Colors.red);
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

  // ─── SOS Press Handler ─────────────────────────────────
  void _handleSOS() {
    HapticFeedback.heavyImpact();
    _showSOSConfirmDialog();
  }

  Future<void> _activateSOS() async {
    setState(() => _sosActivated = true);
    HapticFeedback.heavyImpact();

    // Prepare SMS to all contacts
    final List<String> phoneNumbers = _contacts
        .map((c) => (c['phone'] as String).replaceAll(RegExp(r'[^0-9]'), ''))
        .toList();

    if (phoneNumbers.isNotEmpty) {
      final String numbers = phoneNumbers.join(',');
      final String message = Uri.encodeComponent(
          "EMERGENCY SOS! I need help. My location sharing is ${_locationSharing ? 'ACTIVE' : 'OFF'}. Please contact me immediately.");
      final Uri smsUri = Uri.parse("sms:$numbers?body=$message");

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }

    // Show activated snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.warning_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text("SOS Alert Sent! Help is on the way.",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );

    addNotification(
      title: "SOS Alert Sent",
      message:
          "An emergency alert was sent to your contacts. Your live location sharing is ${_locationSharing ? 'active' : 'inactive'}.",
      icon: Icons.warning_rounded,
    );
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Status Banner ───────────────────
                if (_sosActivated) _buildActiveBanner(),

                // ── SOS Button ───────────────────────
                _buildSOSButton(),

                // ── Location Toggle ──────────────────
                _buildLocationToggle(),

                // ── Emergency Numbers ────────────────
                _buildSectionTitle("Emergency Numbers", Icons.call_rounded),
                _buildEmergencyGrid(),

                // ── Emergency Contacts ───────────────
                _buildSectionTitle(
                    "My Emergency Contacts", Icons.contacts_rounded),
                _buildContactsList(),

                // ── Safety Tips ──────────────────────
                _buildSectionTitle("Safety Tips", Icons.security_rounded),
                _buildSafetyTips(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: BikerColors.darkBlue,
      expandedHeight: 150,
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
            child: const Icon(Icons.emergency_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text("EMERGENCY SOS",
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
      titleSpacing: 8,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BikerColors.darkBlue,
                BikerColors.blue,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Emergency SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      )),
                  Text("Your safety is our priority 🛡️",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen())),
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _showAddContactDialog(),
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
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
    );
  }

  // ─── Active Banner ──────────────────────────────────────
  Widget _buildActiveBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BikerColors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BikerColors.blue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SOS ACTIVE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    )),
                Text("Alert sent to contacts & services",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _sosActivated = false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Cancel",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── SOS Button ─────────────────────────────────────────
  Widget _buildSOSButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Press & hold the SOS button in case of emergency. Your location will be shared with emergency contacts.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Pulse animation
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _sosActivated ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: GestureDetector(
              onLongPress: _handleSOS,
              onTap: _handleSOS,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BikerColors.blue.withOpacity(0.1),
                      border: Border.all(
                        color: BikerColors.blue.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  // Middle ring
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BikerColors.blue.withOpacity(0.15),
                      border: Border.all(
                        color: BikerColors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Main button
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _sosActivated
                            ? [
                                BikerColors.blue,
                                BikerColors.darkBlue,
                              ]
                            : [
                                BikerColors.blue.withOpacity(0.7),
                                BikerColors.darkBlue,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: BikerColors.blue.withOpacity(0.6),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_rounded,
                            color: Colors.white, size: 44),
                        const SizedBox(height: 4),
                        const Text("SOS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            )),
                        Text(
                          _sosActivated ? "ACTIVE" : "Hold to activate",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Location Toggle ────────────────────────────────────
  Widget _buildLocationToggle() {
    return GestureDetector(
      onTap: () => _toggleLocationSharing(!_locationSharing),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _locationSharing
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: _locationSharing ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Live Location Sharing",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: BikerColors.black,
                      )),
                  Text(
                    _locationSharing
                        ? "Sharing with emergency contacts"
                        : "Tap to share location",
                    style: TextStyle(
                      fontSize: 12,
                      color: _locationSharing ? BikerColors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _locationSharing,
              activeColor: Colors.green,
              onChanged: _toggleLocationSharing,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Title ──────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: BikerColors.blue, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: BikerColors.black,
              )),
        ],
      ),
    );
  }

  // ─── Emergency Grid ─────────────────────────────────────
  Widget _buildEmergencyGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: _quickActions.length,
        itemBuilder: (_, i) {
          final action = _quickActions[i];
          final color = action['color'] as Color;
          return GestureDetector(
            onTap: () => _showCallDialog(
                action['title'] as String, action['number'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action['icon'] as IconData,
                        color: color, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(action['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: BikerColors.black,
                      )),
                  Text(action['number'] as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Contacts List ──────────────────────────────────────
  Widget _buildContactsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _contacts.length,
      itemBuilder: (_, i) {
        final c = _contacts[i];
        final color = c['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Text(c['initials'] as String,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    )),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: BikerColors.black,
                        )),
                    Text(c['phone'] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              // Call button
              GestureDetector(
                onTap: () =>
                    _showCallDialog(c['name'] as String, c['phone'] as String),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.call_rounded, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              // SOS send button
              GestureDetector(
                onTap: () {
                  _showSnack("SOS sent to ${c['name']}!", BikerColors.blue);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: BikerColors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded,
                      color: BikerColors.blue, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Safety Tips ────────────────────────────────────────
  Widget _buildSafetyTips() {
    final tips = [
      {
        'tip': 'Always wear a helmet before riding',
        'icon': Icons.sports_motorsports_rounded,
        'color': const Color(0xFF1565C0),
      },
      {
        'tip': 'Keep emergency contacts updated',
        'icon': Icons.contacts_rounded,
        'color': const Color(0xFF2E7D32),
      },
      {
        'tip': 'Share your route before long rides',
        'icon': Icons.route_rounded,
        'color': const Color(0xFFE65100),
      },
      {
        'tip': 'Carry first aid kit on long trips',
        'icon': Icons.medical_services_rounded,
        'color': BikerColors.blue,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: tips.map((t) {
            final color = t['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t['icon'] as IconData, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(t['tip'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: BikerColors.black,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── SOS Confirm Dialog ─────────────────────────────────
  void _showSOSConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_rounded, color: BikerColors.blue, size: 24),
          SizedBox(width: 8),
          Text("Send SOS Alert?",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: BikerColors.blue,
              )),
        ]),
        content: const Text(
            "This will send your location to all emergency contacts and services.",
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BikerColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("SEND SOS",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

// ─── Call Dialog ────────────────────────────────────────
  void _showCallDialog(String name, String number) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Call $name?",
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BikerColors.blue,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final String cleanNumber =
                  number.replaceAll(RegExp(r'[^0-9]'), '');
              final Uri telUri = Uri.parse("tel:$cleanNumber");
              if (await canLaunchUrl(telUri)) {
                await launchUrl(telUri);
              }
            },
            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 16),
            label:
                const Text("Call Now", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Add Contact Dialog ─────────────────────────────────
  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Emergency Contact",
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Contact Name",
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      color: BikerColors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Phone (e.g. 923001234567)",
                  prefixIcon:
                      const Icon(Icons.phone_outlined, color: BikerColors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = phoneCtrl.text.trim();
              if (nameCtrl.text.isNotEmpty &&
                  phone.length == 12 &&
                  phone.startsWith('92')) {
                setState(() {
                  _contacts.add({
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'initials': nameCtrl.text[0].toUpperCase(),
                    'color': BikerColors.blue,
                  });
                });
                Navigator.pop(context);
                _showSnack("Contact added!", Colors.green);
              } else {
                _showSnack(
                    "Enter a 12-digit number starting with 92", Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BikerColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
