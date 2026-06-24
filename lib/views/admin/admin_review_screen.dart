import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';
import 'admin_users_screen.dart';
import 'admin_posts_screen.dart';
import 'admin_diy_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_notification_screen.dart';
import 'admin_edit_profile_screen.dart';
import '../auth/login_screen.dart';

class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  int _selectedIndex = 0; // Typically sub-nav of Home

  static const Color _appBarColor = Color(0xFF1E88E5);
  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _card = Colors.white;
  static const Color _textPrimary = Color(0xFF0D1B2A);
  static const Color _textSecondary = Color(0xFF6B7280);

  void _onItemTapped(int index) {
    if (index == 5) {
      _showLogoutDialog();
      return;
    }
    setState(() => _selectedIndex = index);
    Widget screen;
    switch (index) {
      case 0:
        screen = const AdminDashboard();
        break;
      case 1:
        screen = const AdminUsersScreen();
        break;
      case 2:
        screen = const AdminPostsScreen();
        break;
      case 3:
        screen = const AdminDiyScreen();
        break;
      case 4:
        screen = const AdminActivityScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => screen));
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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Manage Reviews",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                overflow: TextOverflow.ellipsis,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('experiences')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _appBarColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No reviews found",
                    style: TextStyle(color: _textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildReviewTile(doc.id, data);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: _appBarColor,
        unselectedItemColor: _appBarColor.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 20,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.build_rounded), label: 'DIY'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app_rounded), label: 'Exit'),
        ],
      ),
    );
  }

  Widget _buildReviewTile(String id, Map<String, dynamic> data) {
    final user = data['user'] ?? 'Biker Hub User';
    final title = data['title'] ?? 'Review';
    final content = data['content'] ?? '';
    final timestamp = data['createdAt'] as Timestamp?;
    String timeDisplay = "Just now";
    if (timestamp != null) {
      final date = timestamp.toDate();
      timeDisplay = "${date.day}/${date.month}/${date.year}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _textPrimary)),
                    Row(
                      children: [
                        Text("By $user",
                            style: const TextStyle(
                                fontSize: 11, color: _textSecondary)),
                        const SizedBox(width: 8),
                        Text("• $timeDisplay",
                            style: const TextStyle(
                                fontSize: 11, color: _textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteReview(id, title),
                icon:
                    const Icon(Icons.delete_outline_rounded, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, color: _textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  void _deleteReview(String id, String reviewTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review?"),
        content: const Text(
            "Are you sure you want to remove this experience from the community?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('experiences')
                  .doc(id)
                  .delete();
              await FirebaseFirestore.instance.collection('activities').add({
                'description': 'Admin deleted a review: $reviewTitle',
                'timestamp': FieldValue.serverTimestamp(),
                'type': 'delete_review'
              });
              if (context.mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Review deleted successfully"),
                    backgroundColor: _appBarColor),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
