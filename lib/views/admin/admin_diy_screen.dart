import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_services.dart';
import 'admin_dashboard.dart';
import 'admin_users_screen.dart';
import 'admin_posts_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_edit_profile_screen.dart';
import 'admin_notification_screen.dart';
import '../auth/login_screen.dart';
import '../dashboard/video_player_screen.dart';

class AdminDiyScreen extends StatefulWidget {
  const AdminDiyScreen({super.key});

  @override
  State<AdminDiyScreen> createState() => _AdminDiyScreenState();
}

class _AdminDiyScreenState extends State<AdminDiyScreen> {
  final AdminService _service = AdminService();
  int _selectedIndex = 3; // DIY index

  static const Color _appBarColor = Color(0xFF1E88E5);
  static const Color _bg = Colors.white;
  static const Color _card = Colors.white;
  static const Color _textPrimary = Color(0xFF0D1B2A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF1E88E5);
  static const Color _border = Color(0xFFE5E9F2);

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
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
        return;
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
              backgroundColor: _accent,
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
        automaticallyImplyLeading: false,
        backgroundColor: _appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.build_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Manage DIY",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
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
            .collection('diy_tutorials')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: BikerColors.blue));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_rounded,
                      color: _textSecondary.withOpacity(0.3), size: 64),
                  const SizedBox(height: 12),
                  const Text("No videos yet",
                      style: TextStyle(color: _textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVideoDialog(context),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text("Add Video",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return _buildVideoTile(data, docs[i].id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVideoDialog(context),
        backgroundColor: _accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Add Video",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        items: const <BottomNavigationBarItem>[
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

  Widget _buildVideoTile(Map<String, dynamic> data, String docId) {
    return GestureDetector(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(
                  videoUrl: data['videoUrl'] as String? ?? '',
                  title: data['title'] as String? ?? 'DIY Video',
                  description: data['description'] as String? ?? '',
                  steps: List<String>.from((data['steps'] ?? []) as List),
                  duration: data['duration'] as String? ?? '00:00',
                  color: _accent,
                ),
              ),
            ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_circle_rounded,
                    color: _accent, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'] as String? ?? 'Untitled',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                    Text(
                        "${data['category'] ?? 'General'} • ${data['level'] ?? 'Beginner'}",
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                        )),
                    Text(
                        "${data['views'] ?? 0} views • ${data['likes'] ?? 0} likes",
                        style: const TextStyle(color: _accent, fontSize: 11)),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                color: _card,
                icon:
                    const Icon(Icons.more_vert_rounded, color: _textSecondary),
                onSelected: (val) async {
                  if (val == 'edit') {
                    _showEditVideoDialog(context, data, docId);
                  } else if (val == 'delete') {
                    _confirmDelete(docId);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded,
                          color: BikerColors.blue, size: 16),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: _textPrimary)),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  // ─── Add Video Dialog ───────────────────────────────────
  void _showAddVideoDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final stepsCtrl = TextEditingController();
    String category = 'Engine';
    String level = 'Beginner';

    final categories = [
      'Engine',
      'Chain',
      'Brakes',
      'Electricals',
      'Tyres',
      'Body'
    ];
    final levels = ['Beginner', 'Intermediate', 'Advanced'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add DIY Video",
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
              )),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _darkField(titleCtrl, "Video Title", Icons.title_rounded),
                const SizedBox(height: 10),
                _darkField(urlCtrl, "Video URL", Icons.link_rounded),
                const SizedBox(height: 10),
                _darkField(descCtrl, "Description", Icons.description_rounded),
                const SizedBox(height: 10),
                _darkField(
                    durationCtrl, "Duration (e.g. 05:30)", Icons.timer_rounded),
                const SizedBox(height: 10),
                _darkField(
                    stepsCtrl, "Steps (one per line)", Icons.list_rounded,
                    maxLines: 3),
                const SizedBox(height: 10),
                // Category
                _darkDropdown("Category", categories, category,
                    (v) => setS(() => category = v!)),
                const SizedBox(height: 10),
                // Level
                _darkDropdown(
                    "Level", levels, level, (v) => setS(() => level = v!)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancel", style: TextStyle(color: _textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || urlCtrl.text.isEmpty) return;
                await _service.addDiyVideo(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  videoUrl: urlCtrl.text.trim(),
                  category: category,
                  duration: durationCtrl.text.trim(),
                  level: level,
                  steps: stepsCtrl.text
                      .split('\n')
                      .where((s) => s.isNotEmpty)
                      .toList(),
                );
                await FirebaseFirestore.instance.collection('activities').add({
                  'description':
                      'Admin added a new DIY video: ${titleCtrl.text}',
                  'timestamp': FieldValue.serverTimestamp(),
                  'type': 'add_diy'
                });
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Video added! ✅",
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: _accent,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Add",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit Video Dialog ──────────────────────────────────
  void _showEditVideoDialog(
      BuildContext context, Map<String, dynamic> data, String docId) {
    final titleCtrl =
        TextEditingController(text: data['title'] as String? ?? '');
    final descCtrl =
        TextEditingController(text: data['description'] as String? ?? '');
    final urlCtrl =
        TextEditingController(text: data['videoUrl'] as String? ?? '');
    final durationCtrl =
        TextEditingController(text: data['duration'] as String? ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Video",
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
            )),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _darkField(titleCtrl, "Title", Icons.title_rounded),
              const SizedBox(height: 10),
              _darkField(urlCtrl, "Video URL", Icons.link_rounded),
              const SizedBox(height: 10),
              _darkField(descCtrl, "Description", Icons.description_rounded),
              const SizedBox(height: 10),
              _darkField(durationCtrl, "Duration", Icons.timer_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.updateDiyVideo(docId, {
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'videoUrl': urlCtrl.text.trim(),
                'duration': durationCtrl.text.trim(),
              });
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text("Updated! ", style: TextStyle(color: Colors.white)),
                backgroundColor: _accent,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BikerColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Update",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Video?",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
        content: const Text("This action cannot be undone.",
            style: TextStyle(color: _textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.deleteDiyVideo(docId);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Deleted", style: TextStyle(color: Colors.white)),
                backgroundColor: _accent,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _darkField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary),
        prefixIcon: Icon(icon, color: _accent, size: 18),
        filled: true,
        fillColor: const Color(0xFFF4F6FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _darkDropdown(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(color: _textPrimary, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _accent),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
