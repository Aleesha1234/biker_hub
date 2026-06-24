import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';
import 'admin_users_screen.dart';
import 'admin_diy_screen.dart';
import 'admin_posts_screen.dart';
import '../auth/login_screen.dart';
import 'admin_edit_profile_screen.dart';
import 'admin_notification_screen.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  final AdminService _service = AdminService();
  int _selectedIndex = 4; // Set to 4 as this is the Reports/Activity screen

  static const Color _appBarColor = Color(0xFF1E88E5); // Dashboard Blue
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0D1B2A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF00897B); // teal/green

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminPostsScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDiyScreen()));
        break;
      case 4:
        // Already here
        break;
      case 5:
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
      backgroundColor: Colors.white, // Changed to white
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        backgroundColor: _appBarColor, // Dashboard Blue
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.bar_chart_rounded,
                color: Colors.white), // Icon for Reports
            SizedBox(width: 12),
            Text(
              "Reports",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminEditProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminNotificationScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTopStatCard(
                    Icons.speed_rounded, "0.45s", "System Load", Colors.blue),
                const SizedBox(width: 12),
                _buildTopStatCard(
                    Icons.storage_rounded, "12.4MB", "Storage", Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<int>(
                      stream: _service.getActiveUserCount(),
                      builder: (context, snapshot) {
                        return _buildTopStatCardContent(
                            Icons.location_on_rounded,
                            "${snapshot.data ?? 0}",
                            "Active Now",
                            Colors.green);
                      }),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Sales Analysis (Last 7 Days)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary)),
            const SizedBox(height: 16),
            StreamBuilder<List<double>>(
                stream: _service.getWeeklySalesData('Bike'),
                builder: (context, snapshot) {
                  return _buildAnalysisCard(
                      "Bikes Sold",
                      "Real-time Data",
                      const Color(0xFFE57373),
                      snapshot.data ?? [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0]);
                }),
            const SizedBox(height: 16),
            StreamBuilder<List<double>>(
                stream: _service.getWeeklySalesData('Accessory'),
                builder: (context, snapshot) {
                  return _buildAnalysisCard(
                      "Accessories Sold",
                      "Real-time Data",
                      const Color(0xFF78909C),
                      snapshot.data ?? [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0]);
                }),
            const SizedBox(height: 20),
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
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_rounded),
            label: 'DIY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.exit_to_app_rounded),
            label: 'Exit',
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatCard(
      IconData icon, String val, String label, Color color) {
    return Expanded(
      child: _buildTopStatCardContent(icon, val, label, color),
    );
  }

  Widget _buildTopStatCardContent(
      IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(val,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
      String title, String avg, Color color, List<double> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary)),
              Text(avg,
                  style: const TextStyle(
                      fontSize: 12,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data
                  .map((val) => Container(
                        width: 32,
                        height: (val * 8).clamp(
                            0.0, 80.0), // Scale values for better visibility
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Text(day,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
