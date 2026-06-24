import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'live_map_screen.dart';
import 'mechanic_tab.dart';
import 'market_tab.dart';
import 'diy_tab.dart';
import 'community_tab.dart';
import 'profile_tab.dart';
import 'sos_tab.dart';
import 'notification_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ─── Featured Bikes Data ───────────────────────────────
  final List<Map<String, dynamic>> _featuredBikes = [
    {
      'name': 'Yamaha YZF-R15',
      'price': 'PKR 8,50,000',
      'location': 'Lahore',
      'color': BikerColors.blue,
      'image': 'assets/images/bike1.png',
      'tag': 'Featured',
    },
    {
      'name': 'Honda CB150R',
      'price': 'PKR 4,20,000',
      'location': 'Karachi',
      'color': BikerColors.blue,
      'image': 'assets/images/bike2.png',
      'tag': 'New',
    },
    {
      'name': 'Suzuki GS150',
      'price': 'PKR 3,80,000',
      'location': 'Islamabad',
      'color': BikerColors.blue,
      'image': 'assets/images/bike3.png',
      'tag': 'Hot Deal',
    },
  ];

  // ─── Nearby Mechanics Data ─────────────────────────────
  final List<Map<String, dynamic>> _mechanics = [
    {
      'name': 'Ali Motors',
      'rating': '4.8',
      'distance': '0.5 km',
      'specialty': 'Engine Repair',
      'open': true,
    },
    {
      'name': 'Bike Care Center',
      'rating': '4.5',
      'distance': '1.2 km',
      'specialty': 'All Services',
      'open': true,
    },
    {
      'name': 'Speed Workshop',
      'rating': '4.3',
      'distance': '2.1 km',
      'specialty': 'Tyres & Brakes',
      'open': false,
    },
  ];

  // ─── Latest Posts Data ─────────────────────────────────
  final List<Map<String, dynamic>> _posts = [
    {
      'user': 'Zain Ahmed',
      'time': '2 hours ago',
      'content': 'Just finished a 200km ride to Murree. The weather was amazing!',
    },
    {
      'user': 'Hamza Khan',
      'time': '5 hours ago',
      'content': 'Any recommendations for a good mechanic in Gulberg?',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Apply real-time search filtering
    final filteredBikes = _featuredBikes
        .where(
            (b) => b['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    final filteredMechanics = _mechanics
        .where((m) =>
            m['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m['specialty'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    final filteredPosts = _posts
        .where((p) =>
            (p['user'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (p['content'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ────────────────────────────
          _buildSliverAppBar(),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ──────────────────────────
                _buildSearchBar(),

                // ── Quick Actions ───────────────────────
                _buildSectionHeader("Quick Actions", null),
                _buildQuickActions(),

                // ── Featured Bikes ──────────────────────
                _buildSectionHeader(
                    "Featured Bikes",
                    () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MarketTab()))),
                _buildFeaturedBikes(filteredBikes),

                // ── Nearby Mechanics ────────────────────
                _buildSectionHeader(
                    "Nearby Mechanics",
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MechanicTab()))),
                _buildNearbyMechanics(filteredMechanics),

                // ── Latest Posts ────────────────────────
                _buildSectionHeader(
                    "Community Posts",
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CommunityTab()))),
                _buildLatestPosts(filteredPosts),

                // ── DIY Banner ──────────────────────────
                _buildDIYBanner(),

                // ── SOS Banner ──────────────────────────
                _buildSOSBanner(),

                const SizedBox(height: 30),
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
      expandedHeight: 200,
      floating: false,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Welcome text
                  Text(
                    "Welcome back,",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _user?.displayName ?? "Rider! 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Ready for your next adventure?",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
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
            child: const Icon(Icons.motorcycle_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text("BIKERS HUB",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              )),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationScreen())),
              icon:
                  const Icon(Icons.notifications_rounded, color: Colors.white),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(color: BikerColors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Search bikes, mechanics...",
          hintStyle:
              TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: BikerColors.blue, size: 22),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BikerColors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── Section Header ─────────────────────────────────────
  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Text(title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: BikerColors.black,
                  )),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BikerColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("See All",
                    style: TextStyle(
                      color: BikerColors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Quick Actions ──────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.storefront_rounded,
        'label': 'Market',
        'screen': const MarketTab(),
      },
      {
        'icon': Icons.build_circle_rounded,
        'label': 'Mechanic',
        'screen': const MechanicTab(),
      },
      {
        'icon': Icons.play_circle_rounded,
        'label': 'DIY',
        'screen': const DiyTab(),
      },
      {
        'icon': Icons.people_rounded,
        'label': 'Community',
        'screen': const CommunityTab(),
      },
      {
        'icon': Icons.emergency_rounded,
        'label': 'SOS',
        'screen': const SosTab(),
      },
      {
        'icon': Icons.location_on_rounded,
        'label': 'Live Map',
        'screen': const LiveMapScreen(),
      },
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final action = actions[i];
          return GestureDetector(
            onTap: () {
              if (action['screen'] != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => action['screen'] as Widget));
              }
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: BikerColors.greyLt,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: Icon(action['icon'] as IconData,
                        color: BikerColors.blue, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(action['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BikerColors.black, // Text remains black
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Featured Bikes ─────────────────────────────────────
  Widget _buildFeaturedBikes(List<Map<String, dynamic>> bikes) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: bikes.length,
        itemBuilder: (_, i) {
          final bike = bikes[i];
          final color = bike['color'] as Color;
          return GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MarketTab())),
            child: Container(
              width: 200,
              margin: const EdgeInsets.symmetric(horizontal: 6),
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
                  // Image area
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Image.asset(
                            bike['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.motorcycle_rounded,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(bike['tag'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bike['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: BikerColors.black,
                            )),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(bike['price'] as String,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                )),
                            Row(children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 10, color: Colors.grey),
                              Text(bike['location'] as String,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  )),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Nearby Mechanics ───────────────────────────────────
  Widget _buildNearbyMechanics(List<Map<String, dynamic>> mechanics) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: mechanics.length,
      itemBuilder: (_, i) {
        final m = mechanics[i];
        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MechanicTab())),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
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
                      const SizedBox(height: 3),
                      Text(m['specialty'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
                // Rating + Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF9A825), size: 14),
                      Text(m['rating'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          )),
                    ]),
                    const SizedBox(height: 4),
                    Text(m['distance'] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (m['open'] as bool)
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text((m['open'] as bool) ? "Open" : "Closed",
                          style: TextStyle(
                            color:
                                (m['open'] as bool) ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// ─── Latest Posts ────────────────────────────────────────
  Widget _buildLatestPosts(List<Map<String, dynamic>> posts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final post = posts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: BikerColors.blue.withOpacity(0.15),
                    child: Text(
                      (post['user'] as String)[0],
                      style: const TextStyle(
                        color: BikerColors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['user'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: BikerColors.black,
                            )),
                        Text(post['time'] as String,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(post['content'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: BikerColors.black,
                    height: 1.4,
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostAction(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  // ─── DIY Banner ─────────────────────────────────────────
  Widget _buildDIYBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const DiyTab())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [BikerColors.darkBlue, BikerColors.blue],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: BikerColors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("DIY GARAGE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        )),
                  ),
                  const SizedBox(height: 8),
                  const Text("Fix Your Bike\nYourself! 🔧",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      )),
                  const SizedBox(height: 8),
                  const Text("50+ tutorials available",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_rounded,
                  color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SOS Banner ─────────────────────────────────────────
  Widget _buildSOSBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SosTab())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.red],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("EMERGENCY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        )),
                  ),
                  const SizedBox(height: 8),
                  const Text("Need Help?\nEmergency SOS 🆘",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      )),
                  const SizedBox(height: 8),
                  const Text("Alert contacts instantly",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency_rounded,
                  color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Get Initials ────────────────────────────────────────
  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }
}
