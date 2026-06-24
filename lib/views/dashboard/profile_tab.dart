import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';
import 'my_orders_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';

// ── Colors directly yahan define hain ──────────────────────
const _blue = Color(0xFF0066FF);
const _darkBlue = Color(0xFF001F3F);
const _black = Color(0xFF000000);
const _white = Color(0xFFFFFFFF);
const _greyLt = Color(0xFFF8F9FA);
const _blueLt = Color(0xFF1E88E5);

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  User? _user = FirebaseAuth.instance.currentUser;

  // ─── Logout ────────────────────────────────────────────
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout?",
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
        content: const Text("Are you sure you want to logout?",
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: _blue)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 28),
            _buildSectionTitle("Account"),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.edit_rounded,
              label: "Edit Profile",
              subtitle: "Update your info",
              color: _blue,
              onTap: () async {
                final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()));
                if (updated == true) {
                  setState(() {
                    _user = FirebaseAuth.instance.currentUser;
                  });
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.shopping_bag_rounded,
              label: "My Orders",
              subtitle: "Track your purchases",
              color: const Color(0xFFE65100),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("Preferences"),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.settings_rounded,
              label: "App Settings",
              subtitle: "Theme, language",
              color: Colors.grey,
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            _buildMenuItem(
              icon: Icons.help_rounded,
              label: "Help & Support",
              subtitle: "FAQ & contact us",
              color: _blueLt,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen()));
              },
            ),
            const SizedBox(height: 28),
            _buildLogoutButton(),
            const SizedBox(height: 12),
            const Text("Bikers Hub v1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkBlue, _blue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("MY PROFILE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      )),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationScreen())),
                        icon: const Icon(Icons.notifications_rounded,
                            color: Colors.white70, size: 22),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen())),
                        icon: const Icon(Icons.settings_rounded,
                            color: Colors.white70, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: _blue.withOpacity(0.3),
                      child: Text(
                        _getInitials(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _blue, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: _blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                _user?.displayName ?? "Biker Rider",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _user?.email ?? "biker@email.com",
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Verified badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Colors.greenAccent, size: 14),
                    SizedBox(width: 6),
                    Text("Verified Biker",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Stats Row ──────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard("3", "Groups", Icons.groups_rounded),
          const SizedBox(width: 12),
          _buildStatCard("0", "Trips", Icons.route_rounded),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _greyLt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: _blue, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _black,
                )),
            Text(label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  // ─── Section Title ──────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 1,
              )),
          const SizedBox(width: 10),
          const Expanded(
              child: Divider(color: Color(0xFFE8E8E8), thickness: 1)),
        ],
      ),
    );
  }

  // ─── Menu Item ──────────────────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _black,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ─── Logout Button ──────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue.withOpacity(0.1),
            foregroundColor: _blue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _blue, width: 1.5),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: _blue, size: 20),
              SizedBox(width: 10),
              Text("LOGOUT",
                  style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Get Initials ───────────────────────────────────────
  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }
}
