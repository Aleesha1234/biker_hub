import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import 'video_player_screen.dart';
import 'profile_tab.dart';
import 'notification_screen.dart';

class DiyTab extends StatefulWidget {
  const DiyTab({super.key});

  @override
  State<DiyTab> createState() => _DiyTabState();
}

class _DiyTabState extends State<DiyTab> {
  final User? _user = FirebaseAuth.instance.currentUser;

  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }

  // ─── Categories ────────────────────────────────────────
  final List<String> _categories = [
    'All',
    'Engine',
    'Chain',
    'Brakes',
    'Electricals',
    'Tyres',
    'Body',
  ];
  String _selectedCategory = 'All';

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────
          _buildSliverAppBar(),
          // ── Content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Search ───────────────────────────
                _buildSearchBar(),
                // ── Categories ───────────────────────
                _buildCategories(),
                // ── Tutorial List ─────────────────────
                _buildTutorialList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sliver App Bar ─────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: BikerColors.darkBlue,
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
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Fix Your Bike Yourself! 🔧",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      )),
                  Text("Save money with DIY tutorials",
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
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.build_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text("DIY GARAGE",
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Search Bar ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search tutorials...",
          hintStyle:
              TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: BikerColors.blue, size: 22),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── Categories ─────────────────────────────────────────
  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final selected = _selectedCategory == _categories[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? BikerColors.blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(_categories[i],
                  style: TextStyle(
                    color: selected ? Colors.white : BikerColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          );
        },
      ),
    );
  }

  // ─── Tutorial List ───────────────────────────────────────
  Widget _buildTutorialList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('diy_tutorials')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text("No tutorials found",
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        var list = snapshot.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .toList();

        // Filter by category
        if (_selectedCategory != 'All') {
          list = list.where((t) => t['category'] == _selectedCategory).toList();
        }

        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text("No tutorials found for this category",
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (_, i) => _buildTutorialCard(list[i]),
        );
      },
    );
  }

  // ─── Tutorial Card ───────────────────────────────────────
  Widget _buildTutorialCard(Map<String, dynamic> data) {
    // Use blue as fallback color for admin-added tutorials
    final Color color = BikerColors.blue;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoUrl: (data['videoUrl'] ?? data['url']) as String? ?? '',
            title: data['title'] as String? ?? 'DIY Tutorial',
            description: (data['description'] ?? data['desc']) as String? ?? '',
            steps: List<String>.from((data['steps'] ?? []) as List),
            duration: data['duration'] as String? ?? '00:00',
            color: color,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BikerColors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            BikerColors.blue.withOpacity(0.05),
                            BikerColors.blue.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  // Tool icon background (always blue)
                  Icon(
                      _getCategoryIcon(
                          data['category'] as String? ?? 'General'),
                      size: 80,
                      color: BikerColors.blue.withOpacity(0.15)),
                  // Play button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: BikerColors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BikerColors.blue.withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 32),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white, size: 11),
                        const SizedBox(width: 3),
                        Text(data['duration'] as String? ?? '00:00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            )),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BikerColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                        data['category']
                            as String, // Text color is now BikerColors.blue
                        style: TextStyle(
                          color: BikerColors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(data['title'] as String? ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: BikerColors.black,
                      )),
                  const SizedBox(height: 4),
                  // Description
                  Text(data['description'] ?? data['desc'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.4,
                      )),
                  const SizedBox(height: 12),
                  // Bottom row
                  Row(
                    children: [
                      // Likes
                      Icon(Icons.favorite_rounded,
                          size: 14, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text("${data['likes'] ?? 0}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )),
                      const Spacer(),
                      // Steps count
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BikerColors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Icon(Icons.list_rounded,
                              size: 13, color: BikerColors.blue),
                          const SizedBox(width: 4),
                          Text("${(data['steps'] as List? ?? []).length} Steps",
                              style: TextStyle(
                                color: BikerColors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              )),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Engine':
        return Icons.settings_rounded;
      case 'Chain':
        return Icons.link_rounded;
      case 'Brakes':
        return Icons.brightness_1_rounded;
      case 'Electricals':
        return Icons.electric_bolt_rounded;
      case 'Tyres':
        return Icons.tire_repair_rounded;
      case 'Body':
        return Icons.handyman_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}
