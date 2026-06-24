import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import 'bike_detail_screen.dart';
import 'live_map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'profile_tab.dart';
import 'cart_screen.dart';
import 'notification_screen.dart';

class MarketTab extends StatefulWidget {
  const MarketTab({super.key});

  @override
  State<MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends State<MarketTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late ScrollController _scrollCtrl;
  bool _isCollapsed = false;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'New', 'Used'];
  String _selectedFilter = 'Latest';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final User? _user = FirebaseAuth.instance.currentUser;

  // ─── Categories ────────────────────────────────────────
  // Hardcoded items to be shown in both User and Admin sides
  final List<Map<String, dynamic>> _staticBikes = [
    {
      'id': 'static_b1',
      'name': 'Yamaha YZF R6',
      'price': 'PKR 2,850,000',
      'condition': 'Used',
      'category': 'Bike',
      'year': '2022',
      'cc': '600cc',
      'location': 'Lahore',
      'rating': '4.9',
      'image': 'assets/images/bike1.png',
      'priceNum': 2850000,
      'icon': Icons.motorcycle_rounded,
      'description':
          'Mint condition Yamaha R6, professionally maintained. Performance exhaust installed.',
      'seller': 'Bikers Hub Official',
      'phone': '03001234567',
      'mileage': '5,000 km',
    },
    {
      'id': 'static_b2',
      'name': 'Honda CBR 1000RR',
      'price': 'PKR 4,200,000',
      'condition': 'New',
      'category': 'Bike',
      'year': '2023',
      'cc': '1000cc',
      'location': 'Karachi',
      'rating': '5.0',
      'image': 'assets/images/bike2.png',
      'priceNum': 4200000,
      'icon': Icons.motorcycle_rounded,
      'description':
          'Brand new Honda Fireblade. Zero meter, full warranty included.',
      'seller': 'Honda Atlas',
      'phone': '03217654321',
      'mileage': '0 km',
    },
    {
      'id': 'static_b3',
      'name': 'Kawasaki Ninja H2',
      'price': 'PKR 8,500,000',
      'condition': 'New',
      'category': 'Bike',
      'year': '2024',
      'cc': '1000cc',
      'location': 'Islamabad',
      'rating': '5.0',
      'image': 'assets/images/bike3.png',
      'priceNum': 8500000,
      'icon': Icons.motorcycle_rounded,
      'description': 'Supercharged masterpiece. The ultimate track weapon.',
      'seller': 'Premium Motors',
      'phone': '03331122334',
      'mileage': '0 km',
    },
    {
      'id': 'static_b4',
      'name': 'Suzuki GSX-R1000',
      'price': 'PKR 3,500,000',
      'condition': 'Used',
      'category': 'Bike',
      'year': '2021',
      'cc': '1000cc',
      'location': 'Faisalabad',
      'rating': '4.8',
      'image': 'assets/images/bike4.png',
      'priceNum': 3500000,
      'icon': Icons.motorcycle_rounded,
      'description': 'Well kept Gixxer, full service history available.',
      'seller': 'Individual Seller',
      'phone': '03456677889',
      'mileage': '8,500 km',
    },
    {
      'id': 'static_b5',
      'name': 'BMW S1000RR',
      'price': 'PKR 6,800,000',
      'condition': 'New',
      'category': 'Bike',
      'year': '2023',
      'cc': '1000cc',
      'location': 'Multan',
      'rating': '4.9',
      'image': 'assets/images/bike5.png',
      'priceNum': 6800000,
      'icon': Icons.motorcycle_rounded,
      'description': 'M Package included. German precision and speed.',
      'seller': 'BMW Motorrad',
      'phone': '03129988776',
      'mileage': '0 km',
    },
    {
      'id': 'static_b6',
      'name': 'Ducati Panigale V4',
      'price': 'PKR 7,500,000',
      'condition': 'New',
      'category': 'Bike',
      'year': '2024',
      'cc': '1103cc',
      'location': 'Lahore',
      'rating': '5.0',
      'image': 'assets/images/bike6.png',
      'priceNum': 7500000,
      'icon': Icons.motorcycle_rounded,
      'description': 'Italian exotic. Pure racing soul.',
      'seller': 'Ducati Pakistan',
      'phone': '03210000000',
      'mileage': '0 km',
    },
  ];

  final List<Map<String, dynamic>> _staticAccessories = [
    {
      'id': 'static_a1',
      'name': 'MT Stinger Helmet',
      'price': 'PKR 14,500',
      'condition': 'New',
      'category': 'Accessory',
      'priceNum': 14500,
      'image': 'assets/accessories/helemt.png',
      'icon': Icons.sports_motorsports_rounded,
      'rating': '4.7',
      'description': 'DOT approved aerodynamic helmet with dual visor.',
    },
    {
      'id': 'static_a2',
      'name': 'Racing Leather Jacket',
      'price': 'PKR 8,500',
      'condition': 'New',
      'category': 'Accessory',
      'priceNum': 8500,
      'icon': Icons.pan_tool_rounded,
      'image': 'assets/accessories/jacket.png',
      'rating': '4.5',
      'description':
          'Leather racing gloves with carbon fiber knuckle protection.',
    },
  ];

  final List<String> _filters = [
    'Latest',
    'Price: Low',
    'Price: High',
    'Popular'
  ];
  // Removed hardcoded _bikes and _accessories lists.
  // Data will now be fetched from Firestore.

  List<Map<String, dynamic>> _filterAndSortListings(
      List<Map<String, dynamic>> allItems) {
    List<Map<String, dynamic>> filtered = List.from(allItems);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = (item['name'] as String? ?? '').toLowerCase();
        final desc = (item['description'] as String? ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) ||
            desc.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((listing) {
        final category = listing['category'] as String? ?? 'Bike';
        final condition = listing['condition'] as String? ?? 'New';
        final bikeType = listing['bikeType'] as String? ?? '';

        if (_selectedCategory == 'Accessories') {
          return category == 'Accessory';
        } else if (_selectedCategory == 'New' || _selectedCategory == 'Used') {
          return condition == _selectedCategory;
        } else {
          return category == 'Bike' && bikeType == _selectedCategory;
        }
      }).toList();
    }

    // Apply sorting based on _selectedFilter
    switch (_selectedFilter) {
      case 'Latest':
        filtered.sort((a, b) {
          final dynamic aVal = a['createdAt'];
          final dynamic bVal = b['createdAt'];
          final aTime = aVal is Timestamp
              ? aVal.toDate()
              : (aVal is DateTime ? aVal : DateTime(0));
          final bTime = bVal is Timestamp
              ? bVal.toDate()
              : (bVal is DateTime ? bVal : DateTime(0));
          return bTime.compareTo(aTime);
        });
        break;
      case 'Price: Low':
        filtered.sort((a, b) {
          final aPrice = double.tryParse((a['price'] as String? ?? '0')
                  .replaceAll(RegExp(r'[PKR ,]'), '')) ??
              0;
          final bPrice = double.tryParse((b['price'] as String? ?? '0')
                  .replaceAll(RegExp(r'[PKR ,]'), '')) ??
              0;
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'Price: High':
        filtered.sort((a, b) {
          final aPrice = double.tryParse((a['price'] as String? ?? '0')
                  .replaceAll(RegExp(r'[PKR ,]'), '')) ??
              0;
          final bPrice = double.tryParse((b['price'] as String? ?? '0')
                  .replaceAll(RegExp(r'[PKR ,]'), '')) ??
              0;
          return bPrice.compareTo(aPrice);
        });
        break;
      case 'Popular':
        // Assuming 'views' or 'likes' field for popularity
        filtered.sort((a, b) {
          final aPopularity =
              (a['views'] as int? ?? 0) + (a['likes'] as int? ?? 0);
          final bPopularity =
              (b['views'] as int? ?? 0) + (b['likes'] as int? ?? 0);
          return bPopularity.compareTo(aPopularity);
        });
        break;
    }
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabCtrl.indexIsChanging) {
          setState(() {
            _selectedCategory = 'All';
          }); // Reset category when tab changes to avoid filtering issues
        }
      });

    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.hasClients) {
        // Trigger collapse UI when scrolled past the flexible space
        final collapsed = _scrollCtrl.offset > (140 - kToolbarHeight - 10);
        if (collapsed != _isCollapsed) {
          if (mounted) setState(() => _isCollapsed = collapsed);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (_, __) => [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(_buildTabBar()),
          ),
        ],
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('listings').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Combine dynamic Firestore data with static items
            final List<Map<String, dynamic>> firestoreItems =
                snapshot.data?.docs
                        .map((doc) => {
                              'id': doc.id,
                              ...(doc.data() as Map<String, dynamic>),
                            })
                        .toList() ??
                    [];

            final List<Map<String, dynamic>> allAvailableItems = [
              ..._staticBikes,
              ..._staticAccessories,
              ...firestoreItems,
            ];

            // Apply combined filtering and sorting
            List<Map<String, dynamic>> processedListings =
                _filterAndSortListings(allAvailableItems);

            List<Map<String, dynamic>> bikes = [
              ...processedListings
                  .where((l) => (l['category'] as String? ?? 'Bike') == 'Bike')
            ];
            List<Map<String, dynamic>> accessories = [
              ...processedListings.where((l) =>
                  (l['category'] as String? ?? 'Accessory') == 'Accessory')
            ];

            return TabBarView(
              controller: _tabCtrl,
              children: [
                _buildBikesGrid(bikes), // Pass filtered bikes
                _buildAccessoriesGrid(accessories), // Pass filtered accessories
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Sliver App Bar ─────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
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
                  Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text("BIKE MARKET",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          )),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  const Text("Buy & Sell Bikes & Accessories",
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
      // Dynamically show title only when collapsed
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isCollapsed ? 1 : 0,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text("BIKE MARKET",
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: BikerColors.black),
                decoration: InputDecoration(
                  hintText: "Search bikes, brands...",
                  hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.7), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: BikerColors.blue, size: 22),
                  filled: true, // Ensure it's filled
                  fillColor: Colors.white, // Explicitly set to white
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Categories ─────────────────────────────────────────
  Widget _buildCategories() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final sel = _selectedCategory == _categories[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = _categories[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? BikerColors.blue : BikerColors.greyLt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? BikerColors.blue : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Text(_categories[i],
                    style: TextStyle(
                      color: sel ? Colors.white : BikerColors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Tab Bar ─────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: BikerColors.blue,
        indicatorWeight: 3,
        labelColor: BikerColors.blue,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(
            icon: Icon(Icons.motorcycle_rounded, size: 18),
            text: "Bikes",
          ),
          Tab(
            icon: Icon(Icons.sports_motorsports_rounded, size: 18),
            text: "Accessories",
          ),
        ],
      ),
    );
  }

  // ─── Bikes Grid ──────────────────────────────────────────
  Widget _buildBikesGrid(List<Map<String, dynamic>> bikes) {
    // Now takes a list
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: bikes.length,
      itemBuilder: (_, i) => _buildBikeCard(bikes[i]),
    );
  }

  // ─── Accessories Grid ────────────────────────────────────
  Widget _buildAccessoriesGrid(List<Map<String, dynamic>> accessories) {
    // Now takes a list
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio:
            0.52, // Increased height ratio to prevent overflow in smaller grids
      ),
      itemCount: accessories.length,
      itemBuilder: (_, i) => _buildAccessoryCard(accessories[i]),
    );
  }

  // ─── Bike Card ───────────────────────────────────────────
  Widget _buildBikeCard(Map<String, dynamic> bike) {
    const color = BikerColors.blue; // Force consistent blue branding
    final isNew = bike['condition'] == 'New';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BikeDetailScreen(
              listingId: bike['id'] as String), // Pass listingId
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: (bike['image'] as String? ?? '').startsWith('http')
                        ? Image.network(bike['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.motorcycle_rounded,
                                size: 70,
                                color: color.withOpacity(0.6)))
                        : (bike['image'] as String? ?? '').startsWith('assets/')
                            ? Image.asset(bike['image'] as String? ?? '',
                                fit: BoxFit.cover)
                            : Image.file(
                                File(bike['image'] as String? ?? ''),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported_outlined),
                              ),
                  ),
                ),
                // Condition badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BikerColors.blue, // Use blue for tags as requested
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(bike['condition'] as String? ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
              ],
            ),
            // ── Info ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bike['name'] as String? ?? 'Unnamed Bike',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: BikerColors.black,
                      )),
                  const SizedBox(height: 3),
                  Text(
                      bike['price'] as String? ??
                          'Price N/A', // Handle missing price
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      )),
                  const SizedBox(height: 5),
                  // Year + CC
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 10, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(bike['year'] as String? ?? 'N/A', // Added null check
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(width: 8),
                    Icon(Icons.speed_rounded, size: 10, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(bike['cc'] as String? ?? 'N/A', // Added null check
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                  ]),
                  const SizedBox(height: 4),
                  // Location
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 10, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                        bike['location'] as String? ??
                            'N/A', // Display location
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                    const Spacer(),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 10, color: Color(0xFFF9A825)),
                      Text(
                          bike['rating'] as String? ??
                              '0.0', // Added null check
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                  const SizedBox(height: 8),
                  // View button
                  Container(
                    width: double.infinity,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("BIKE DETAIL",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Accessory Card ──────────────────────────────────────
  Widget _buildAccessoryCard(Map<String, dynamic> acc) {
    const color = BikerColors.blue; // Force consistent blue branding
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: (acc['image'] as String? ?? '').startsWith('http')
                  ? Image.network(acc['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          acc['icon'] as IconData? ?? Icons.category,
                          size: 52,
                          color: color))
                  : (acc['image'] as String? ?? '').startsWith('assets/')
                      ? Image.asset(acc['image'] as String? ?? '',
                          fit: BoxFit.cover)
                      : Image.file(
                          File(acc['image'] as String? ?? ''),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported_outlined),
                        ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acc['name'] as String? ?? 'Accessory',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: BikerColors.black,
                    )),
                const SizedBox(height: 3),
                Text(
                    acc['price'] as String? ??
                        'Price N/A', // Handle missing price
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    )),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 11, color: Color(0xFFF9A825)),
                  Text(acc['rating'] as String? ?? '0.0', // Added null check
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: BikerColors.blue
                          .withOpacity(0.1), // Use condition for badge
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(acc['condition'] as String? ?? 'N/A',
                        style: TextStyle(
                            color: BikerColors.blue,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 12),
                // Add to Cart button
                GestureDetector(
                  onTap: () {
                    // Check if price is missing or null
                    if (acc['priceNum'] == null ||
                        acc['price'] == 'Price N/A') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Cannot add to cart: Product price is unavailable"),
                          backgroundColor: BikerColors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    // Check if item already exists in cart
                    final index = cartItems
                        .indexWhere((item) => item['name'] == acc['name']);
                    if (index != -1) {
                      cartItems[index]['qty']++;
                    } else {
                      setState(() {
                        cartItems.add({
                          ...acc,
                          'qty': 1,
                        });
                      });
                    }
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      color: BikerColors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("ADD TO CART",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ─── Filter Sheet ────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Sort By",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: BikerColors.black,
                )),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _filters.map((f) {
                final sel = _selectedFilter == f;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilter = f);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? BikerColors.blue : BikerColors.greyLt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? BikerColors.blue : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(f,
                        style: TextStyle(
                          color: sel ? Colors.white : BikerColors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BikerColors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Apply Filter",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Get Initials Helper ────────────────────────────────
  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
