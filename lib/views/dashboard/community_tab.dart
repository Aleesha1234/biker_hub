import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'chat_screen.dart';
import 'profile_tab.dart';
import 'notification_screen.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDetailController = TextEditingController();
  final TextEditingController _tripStartController = TextEditingController();
  final TextEditingController _tripEndController = TextEditingController();
  final TextEditingController _tripDateController = TextEditingController();
  final TextEditingController _tripTimeController = TextEditingController();
  final TextEditingController _tripKmController = TextEditingController();
  final TextEditingController _tripMaxRidersController =
      TextEditingController();
  final TextEditingController _expTitleController = TextEditingController();
  final TextEditingController _expContentController = TextEditingController();

  // ─── Chat Groups ───────────────────────────────────────
  List<Map<String, dynamic>> _groups = [
    {
      'name': 'Lahore Riders',
      'members': 245,
      'lastMsg': 'Sunday ride ka plan kya hai?',
      'time': '2m ago',
      'unread': 3,
      'image':
          'https://images.unsplash.com/photo-1558981403-c5f91adaca60?w=100&q=80',
      'online': 12,
      'isJoined': true,
    },
    {
      'name': 'Karachi Bikers',
      'members': 189,
      'lastMsg': 'New Yamaha R15 review dekho!',
      'time': '15m ago',
      'unread': 7,
      'image':
          'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=100&q=80',
      'online': 8,
      'isJoined': false,
    },
    {
      'name': 'Islamabad MC Club',
      'members': 134,
      'lastMsg': 'Margalla hills ride Saturday!',
      'time': '1h ago',
      'unread': 0,
      'image':
          'https://images.unsplash.com/photo-1471466054146-e71bcc0d2bb2?w=100&q=80',
      'online': 5,
      'isJoined': true,
    },
    {
      'name': 'DIY Mechanics',
      'members': 312,
      'lastMsg': 'Carburetor cleaning tutorial uploaded',
      'time': '2h ago',
      'unread': 1,
      'image':
          'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=100&q=80',
      'online': 20,
      'isJoined': false,
    },
    {
      'name': 'Bike Marketplace',
      'members': 567,
      'lastMsg': 'Honda 125 for sale - good condition',
      'time': '3h ago',
      'unread': 0,
      'image':
          'https://images.unsplash.com/photo-1558981420-87aa9dad1c89?w=100&q=80',
      'online': 35,
      'isJoined': true,
    },
    {
      'name': 'Safety & Tips',
      'members': 98,
      'lastMsg': 'Always wear helmet - stay safe!',
      'time': '5h ago',
      'unread': 2,
      'image':
          'https://images.unsplash.com/photo-1609630875171-b1321377ee65?w=100&q=80',
      'online': 4,
      'isJoined': false,
    },
  ];

  // ─── Trip Plans ────────────────────────────────────────
  List<Map<String, dynamic>> _trips = [
    {
      'title': 'Lahore → Islamabad',
      'date': 'Sunday, Apr 20',
      'time': '6:00 AM',
      'riders': 8,
      'maxRiders': 15,
      'organizer': 'Ahmed Khan',
      'distance': '375 km',
      'status': 'Open',
      'hasJoined': false,
    },
    {
      'title': 'Karachi Coastal Drive',
      'date': 'Saturday, Apr 26',
      'time': '5:30 AM',
      'riders': 12,
      'maxRiders': 20,
      'organizer': 'Sara Biker',
      'distance': '80 km',
      'status': 'Open',
      'hasJoined': false,
    },
    {
      'title': 'Murree Hill Ride',
      'date': 'Sunday, Apr 27',
      'time': '7:00 AM',
      'riders': 20,
      'maxRiders': 20,
      'organizer': 'Usman Rides',
      'distance': '60 km',
      'status': 'Full',
      'hasJoined': false,
    },
  ];

  // ─── Experiences / Posts ───────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupNameController.dispose();
    _groupDetailController.dispose();
    _tripStartController.dispose();
    _tripEndController.dispose();
    _tripDateController.dispose();
    _tripTimeController.dispose();
    _tripKmController.dispose();
    _tripMaxRidersController.dispose();
    _expTitleController.dispose();
    _expContentController.dispose();
    super.dispose();
  }

  String _getInitials() {
    final name = _user?.displayName ?? "BH";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "B";
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupsTab(),
          _buildTripsTab(),
          _buildExperiencesTab(),
        ],
      ),
      // ── FAB ─────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOptions,
        backgroundColor: BikerColors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: BikerColors.darkBlue,
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
            child:
                const Icon(Icons.people_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text("COMMUNITY",
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: BikerColors.blue,
            indicatorWeight: 3,
            labelColor: BikerColors.blue,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: "Groups"),
              Tab(text: "Trips"),
              Tab(text: "Experiences"),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Groups Tab ─────────────────────────────────────────
  Widget _buildGroupsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (_, i) {
        final g = _groups[i];
        const color = BikerColors.blue;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                groupName: g['name'] as String,
                groupColor: color,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                // Group DP
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: BikerColors.greyLt,
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(
                      image: NetworkImage(g['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Text(
                    g['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: BikerColors.black,
                    ),
                  ),
                ),
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 20, color: BikerColors.blue),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Trips Tab ──────────────────────────────────────────
  Widget _buildTripsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trips.length,
      itemBuilder: (_, i) {
        final trip = _trips[i];
        const color = BikerColors.blue;
        final isFull = trip['status'] == 'Full';
        final bool hasJoined = trip['hasJoined'] ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.route_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: BikerColors.black,
                              )),
                          Text("By ${trip['organizer']}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFull
                            ? Colors.black.withOpacity(0.05)
                            : BikerColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFull ? Colors.grey : BikerColors.blue,
                          width: 1,
                        ),
                      ),
                      child: Text(trip['status'] as String,
                          style: TextStyle(
                            color: isFull ? Colors.grey : BikerColors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ],
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildTripDetail(Icons.calendar_today_rounded,
                            trip['date'] as String, color),
                        _buildTripDetail(Icons.access_time_rounded,
                            trip['time'] as String, color),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTripDetail(Icons.straighten_rounded,
                            trip['distance'] as String, color),
                        _buildTripDetail(
                            Icons.people_rounded,
                            "${trip['riders']}/${trip['maxRiders']} riders",
                            color),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Riders joined",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                )),
                            Text("${trip['riders']}/${trip['maxRiders']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (trip['riders'] as int) /
                                (trip['maxRiders'] as int),
                            backgroundColor: color.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Join button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (isFull || hasJoined)
                            ? null
                            : () {
                                setState(() {
                                  trip['riders']++;
                                  trip['hasJoined'] = true;
                                  if (trip['riders'] >= trip['maxRiders']) {
                                    trip['status'] = 'Full';
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Joined ${trip['title']}! You are now part of the group."),
                                    backgroundColor: BikerColors.blue,
                                  ),
                                );
                                addNotification(
                                  title: "Trip Joined",
                                  message:
                                      "You have joined the trip: ${trip['title']}",
                                  icon: Icons.route_rounded,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasJoined ? Colors.black : BikerColors.blue,
                          disabledBackgroundColor:
                              hasJoined ? Colors.black : Colors.grey.shade300,
                          disabledForegroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                            hasJoined
                                ? "Already Joined ✓"
                                : (isFull ? "Trip Full" : "Join Trip 🏍️"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripDetail(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: const TextStyle(
                  fontSize: 12,
                  color: BikerColors.black,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  // ─── Experiences Tab ────────────────────────────────────
  Widget _buildExperiencesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('experiences')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: BikerColors.blue));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No experiences shared yet."));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final post = doc.data() as Map<String, dynamic>;
            final tagColor = BikerColors.blue;
            final initials = (post['user'] as String?)?.isNotEmpty == true
                ? post['user'][0].toUpperCase()
                : 'B';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: tagColor.withOpacity(0.15),
                          child: Text(initials,
                              style: TextStyle(
                                color: tagColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              )),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['user'] as String? ?? 'Biker Hub User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: BikerColors.black,
                                  )),
                              const Text("Experience Shared",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['title'] as String? ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: BikerColors.black,
                            )),
                        const SizedBox(height: 6),
                        Text(post['content'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border_rounded,
                              color: Colors.grey, size: 18),
                          label: const Text("0",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── New Group Dialog ──────────────────────────────────
  void _showNewGroupDialog() {
    String? tempImagePath;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Create New Group",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: BikerColors.black)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    // Mock camera behavior: setting a specific image URL to simulate capture
                    setDialogState(() {
                      tempImagePath =
                          'https://images.unsplash.com/photo-1558981403-c5f91adaca60?w=100&q=80';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Camera accessed. Photo set as DP.")),
                    );
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: BikerColors.blue.withOpacity(0.08),
                    backgroundImage: tempImagePath != null
                        ? NetworkImage(tempImagePath!)
                        : null,
                    child: tempImagePath == null
                        ? const Icon(Icons.add_a_photo_rounded,
                            color: BikerColors.blue, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _groupNameController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: "Group Name",
                    hintText: "e.g. Mountain Riders",
                    prefixIcon: const Icon(Icons.group_work_rounded,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _groupDetailController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Group Details",
                    hintText: "What is this group about?",
                    prefixIcon:
                        const Icon(Icons.info_outline, color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
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
                if (_groupNameController.text.isNotEmpty) {
                  setState(() {
                    _groups.insert(0, {
                      'name': _groupNameController.text,
                      'members': 1,
                      'lastMsg': 'Group created! Tap to chat.',
                      'time': 'Just now',
                      'unread': 0,
                      'image': tempImagePath ??
                          'https://images.unsplash.com/photo-1558981403-c5f91adaca60?w=100&q=80',
                      'online': 1,
                      'isJoined': true,
                      'detail': _groupDetailController.text,
                    });
                  });
                  _groupNameController.clear();
                  _groupDetailController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BikerColors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child:
                  const Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── New Experience Dialog ─────────────────────────────
  void _showNewExperienceDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Share Experience",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: BikerColors.black)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Tell the community about your latest ride or bike tips!",
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                  controller: _expTitleController,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "e.g. My First Solo Trip",
                    prefixIcon: const Icon(Icons.title_rounded,
                        color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _expContentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Experience Details",
                    hintText: "Share your story, route, or maintenance tips...",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
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
                if (_expTitleController.text.isNotEmpty &&
                    _expContentController.text.isNotEmpty) {
                  final String expTitle = _expTitleController.text;
                  FirebaseFirestore.instance.collection('experiences').add({
                    'user': _user?.displayName ?? "Biker Hub User",
                    'title': expTitle,
                    'content': _expContentController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'likes': 0,
                    'comments': 0,
                    'tag': 'Shared Experience',
                  });
                  _expTitleController.clear();
                  _expContentController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Experience shared successfully!"),
                        backgroundColor: BikerColors.blue),
                  );
                  addNotification(
                    title: "Experience Shared",
                    message:
                        "Your experience '$expTitle' has been shared with the community.",
                    icon: Icons.edit_rounded,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BikerColors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Post", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── New Trip Dialog ──────────────────────────────────
  void _showNewTripDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Plan a Trip",
            style: TextStyle(
                fontWeight: FontWeight.w800, color: BikerColors.black)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tripStartController,
                decoration: InputDecoration(
                  hintText: "From (e.g. Lahore)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tripEndController,
                decoration: InputDecoration(
                  hintText: "To (e.g. Islamabad)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tripDateController,
                decoration: InputDecoration(
                  hintText: "Date (e.g. Sunday, Apr 20)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tripTimeController,
                decoration: InputDecoration(
                  hintText: "Time (e.g. 6:00 AM)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tripKmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Total Distance (e.g. 375)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tripMaxRidersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Max Riders (e.g. 15)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
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
              if (_tripStartController.text.isNotEmpty &&
                  _tripEndController.text.isNotEmpty &&
                  _tripKmController.text.isNotEmpty &&
                  _tripMaxRidersController.text.isNotEmpty) {
                setState(() {
                  final int maxRiders =
                      int.tryParse(_tripMaxRidersController.text) ?? 1;
                  final int currentRiders = 1; // Creator joins
                  _trips.insert(0, {
                    'title':
                        '${_tripStartController.text} → ${_tripEndController.text}',
                    'date': _tripDateController.text.isEmpty
                        ? "TBA"
                        : _tripDateController.text,
                    'time': _tripTimeController.text.isEmpty
                        ? "TBA"
                        : _tripTimeController.text,
                    'riders': currentRiders,
                    'maxRiders': maxRiders,
                    'organizer': _user?.displayName ?? "Biker Hub User",
                    'distance': '${_tripKmController.text} km',
                    'status': currentRiders >= maxRiders ? 'Full' : 'Open',
                    'hasJoined': true,
                  });
                });
                _tripStartController.clear();
                _tripEndController.clear();
                _tripDateController.clear();
                _tripTimeController.clear();
                _tripKmController.clear();
                _tripMaxRidersController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Trip planned successfully!"),
                      backgroundColor: BikerColors.blue),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please fill all trip details."),
                      backgroundColor: Colors.redAccent),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BikerColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text("Plan Trip", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// ─── Create Options ─────────────────────────────────────
  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Create New",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: BikerColors.black,
                  )),
              const SizedBox(height: 20),
              _buildCreateOption(
                icon: Icons.chat_rounded,
                title: "New Group",
                subtitle: "Create a riders group",
                color: Colors.black,
                onTap: () {
                  Navigator.pop(context);
                  _showNewGroupDialog();
                },
              ),
              _buildCreateOption(
                icon: Icons.route_rounded,
                title: "Plan a Trip",
                subtitle: "Invite riders to join",
                color: Colors.black,
                onTap: () {
                  Navigator.pop(context);
                  _showNewTripDialog();
                },
              ),
              _buildCreateOption(
                icon: Icons.edit_rounded,
                title: "Share Experience",
                subtitle: "Post your ride story",
                color: Colors.black,
                onTap: () {
                  Navigator.pop(context);
                  _showNewExperienceDialog();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: BikerColors.black,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                      color: BikerColors.black,
                      fontSize: 12,
                    )),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
