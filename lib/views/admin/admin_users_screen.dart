import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';
import 'admin_edit_profile_screen.dart';
import 'admin_diy_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_posts_screen.dart';
import 'admin_notification_screen.dart';
import '../register_screen.dart';
import '../auth/login_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _service = AdminService();
  String _search = '';
  int _selectedIndex = 1; // Set to 1 as this is the Users screen

  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF0D1B2A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E9F2);
  static const Color _accent =
      Color(0xFF00897B); // teal/green — decent, not blue

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
        // Already here
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminActivityScreen()));
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
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
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
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        backgroundColor: const Color(0xFF1E88E5), // Dashboard Blue
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text(
              "Manage Users",
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
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────
          Container(
            color: _card,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              style: const TextStyle(color: _textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Search users...",
                hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: _textSecondary, size: 20),
                filled: true,
                fillColor: _bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Users List ──────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accent),
                  );
                }
                var docs = snapshot.data!.docs;
                if (_search.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['name'] as String? ?? '')
                        .toLowerCase()
                        .contains(_search.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No users found",
                        style: TextStyle(color: _textSecondary, fontSize: 14)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final uid = docs[i].id;
                    return _buildUserTile(data, uid);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: const Color(0xFF1E88E5).withOpacity(0.5),
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

  Widget _buildUserTile(Map<String, dynamic> data, String uid) {
    final isBlocked = data['isBlocked'] as bool? ?? false;
    final isAdmin = (data['role']?.toString() ?? '') == 'admin';
    final name = data['name'] as String? ?? 'Unknown';
    final email = data['email'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBlocked ? Colors.red.withOpacity(0.25) : _border,
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
          // ── Avatar ────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isBlocked
                  ? Colors.red.withOpacity(0.1)
                  : _accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: isBlocked ? Colors.red : _accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text("Admin",
                            style: TextStyle(
                              color: _accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                    if (isBlocked) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text("Blocked",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Action Menu ───────────────────────────
          if (!isAdmin)
            PopupMenuButton<String>(
              color: _card,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _border),
              ),
              icon: const Icon(Icons.more_vert_rounded,
                  color: _textSecondary, size: 20),
              onSelected: (val) async {
                if (val == 'block') {
                  await _service.toggleBlockUser(uid, true);
                  await FirebaseFirestore.instance
                      .collection('activities')
                      .add({
                    'description': 'Admin blocked user: $name',
                    'timestamp': FieldValue.serverTimestamp(),
                    'type': 'block_user'
                  });
                  _showSnack("User blocked", Colors.red);
                } else if (val == 'unblock') {
                  await _service.toggleBlockUser(uid, false);
                  await FirebaseFirestore.instance
                      .collection('activities')
                      .add({
                    'description': 'Admin unblocked user: $name',
                    'timestamp': FieldValue.serverTimestamp(),
                    'type': 'unblock_user'
                  });
                  _showSnack("User unblocked", Colors.green);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: isBlocked ? 'unblock' : 'block',
                  child: Row(
                    children: [
                      Icon(
                        isBlocked
                            ? Icons.check_circle_outline_rounded
                            : Icons.block_rounded,
                        color: isBlocked ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isBlocked ? 'Unblock User' : 'Block User',
                        style: TextStyle(
                          color: isBlocked ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
