import 'package:flutter/material.dart';
import 'package:biker_hub/services/admin_services.dart';
import 'package:biker_hub/utils/app_theme.dart';
import 'package:biker_hub/views/admin/admin_users_screen.dart';
import 'package:biker_hub/views/admin/admin_diy_screen.dart';
import 'package:biker_hub/views/admin/admin_activity_screen.dart';
import 'package:biker_hub/views/admin/admin_posts_screen.dart';
import 'package:biker_hub/views/admin/admin_notification_screen.dart';
import 'package:biker_hub/views/register_screen.dart';
import 'package:biker_hub/views/auth/login_screen.dart';

// New screen for admin profile editing
import 'package:biker_hub/views/admin/admin_review_screen.dart';
import 'package:biker_hub/views/admin/admin_edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For logout
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  int _selectedIndex = 0; // For bottom navigation bar

  // Define colors based on the image
  static const Color _appBarColor =
      Color(0xFF1E88E5); // Brighter blue, not too dark
  static const Color _backgroundColor = Color(0xFFF4F6FB); // Light Grey
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0D1B2A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _accentColor =
      Color(0xFF00897B); // Teal/Green for some icons
  static const Color _redAccent = Colors.red; // For reviews icon

  Future<Map<String, int>> _dashboardStatsFuture = Future.value({});

  @override
  void initState() {
    super.initState();
    _dashboardStatsFuture = _adminService.getDashboardStats();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home (current screen)
        break;
      case 1: // Users
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
        break;
      case 2: // Products (mapping to AdminPostsScreen as per instruction)
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminPostsScreen()));
        break;
      case 3: // DIY
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AdminDiyScreen()));
        break;
      case 4: // Reports
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminActivityScreen()));
        break;
      case 5: // Exit
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Logout",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?",
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _appBarColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Motorcycle icon (from image) - Placeholder, assuming asset exists
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                'assets/images/motorcycle_icon.png', // Replace with actual asset path if different
                height: 24,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.two_wheeler,
                      color: Colors.white, size: 24); // Fallback icon
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String adminName = "admin";
                  if (snapshot.hasData && snapshot.data!.exists) {
                    adminName = snapshot.data!['name'] ?? "admin";
                  }
                  return Text(
                    "Welcome $adminName",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          // Edit Profile Icon
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminEditProfileScreen()),
              );
            },
          ),
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminNotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "System Overview",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, userSnap) {
                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('listings')
                        .snapshots(),
                    builder: (context, prodSnap) {
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('experiences')
                              .snapshots(),
                          builder: (context, expSnap) {
                            return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('diy_tutorials')
                                    .snapshots(),
                                builder: (context, diySnap) {
                                  final totalUsers = userSnap.hasData
                                      ? userSnap.data!.docs.length
                                      : 0;
                                  // Static 7 items + Firestore items
                                  final totalProducts = (prodSnap.hasData
                                          ? prodSnap.data!.docs.length
                                          : 0) +
                                      7;
                                  final totalReviews = expSnap.hasData
                                      ? expSnap.data!.docs.length
                                      : 0;
                                  final totalDIY = diySnap.hasData
                                      ? diySnap.data!.docs.length
                                      : 0;

                                  return GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    children: [
                                      _buildStatCard(
                                        icon: Icons.people_alt_rounded,
                                        iconColor: _appBarColor,
                                        count: totalUsers,
                                        label: "Total Users",
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AdminUsersScreen())),
                                      ),
                                      _buildStatCard(
                                        icon: Icons.inventory_2_rounded,
                                        iconColor: Colors.orange,
                                        count: totalProducts,
                                        label: "Total Products",
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AdminPostsScreen())),
                                      ),
                                      _buildStatCard(
                                        icon: Icons.star_rounded,
                                        iconColor: _redAccent,
                                        count: totalReviews,
                                        label: "Reviews",
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const AdminReviewScreen()));
                                        },
                                      ),
                                      _buildStatCard(
                                        icon: Icons.bar_chart_rounded,
                                        iconColor: _accentColor,
                                        label: "Reports",
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AdminActivityScreen())),
                                      ),
                                    ],
                                  );
                                });
                          });
                    });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: _appBarColor,
        unselectedItemColor: _appBarColor.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        iconSize: 20,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.build_rounded),
            label: 'DIY',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.exit_to_app_rounded),
            label: 'Exit',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    int? count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 10),
            if (count != null) ...[
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 5),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
