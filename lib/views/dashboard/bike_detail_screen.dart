import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

class BikeDetailScreen extends StatefulWidget {
  final String listingId;
  const BikeDetailScreen({super.key, required this.listingId});

  @override
  State<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  int _selectedImage = 0;

  // Mock data lookup for hardcoded items
  Map<String, dynamic>? _getStaticData(String id) {
    final data = [
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
        'description': 'Italian exotic. Pure racing soul.',
        'seller': 'Ducati Pakistan',
        'phone': '03210000000',
        'mileage': '0 km',
      },
    ];
    return data
        .cast<Map<String, dynamic>?>()
        .firstWhere((e) => e?['id'] == id, orElse: () => null);
  }

  Widget _buildContent(Map<String, dynamic> bike, Color color) {
    final isNew = bike['condition'] == 'New';
    return CustomScrollView(
      slivers: [
        _buildAppBar(bike, color),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildMainInfo(bike, color, isNew),
              _buildSpecsCard(bike, color),
              _buildSellerCard(bike, color),
              _buildDescriptionCard(bike, color),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(Map<String, dynamic> bike, Color color) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: color,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: (bike['image'] as String? ?? '').startsWith('http')
            ? Image.network(bike['image'] as String, fit: BoxFit.cover)
            : Image.asset(bike['image'] as String? ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.motorcycle,
                    size: 100, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const color = BikerColors.blue;

    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      body: widget.listingId.startsWith('static_')
          ? _buildContent(_getStaticData(widget.listingId)!, color)
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('listings')
                  .doc(widget.listingId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Product not available."));
                }

                final bike = snapshot.data!.data() as Map<String, dynamic>;
                final isNew = bike['condition'] == 'New';

                return CustomScrollView(
                  slivers: [
                    // ── App Bar ──────────────────────────────
                    SliverAppBar(
                      expandedHeight: 280,
                      pinned: true,
                      backgroundColor: color,
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: (bike['imagePath'] != null &&
                                (bike['image'] as String? ?? '')
                                    .startsWith('http'))
                            ? Image.network(bike['image'] as String,
                                fit: BoxFit.cover)
                            : Image.asset(bike['image'] as String? ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.motorcycle,
                                    size: 100,
                                    color: Colors.white)),
                      ),
                    ),

                    // ── Content ──────────────────────────────
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildMainInfo(bike, color, isNew),
                          _buildSpecsCard(bike, color),
                          _buildSellerCard(bike, color),
                          _buildDescriptionCard(bike, color),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                );
              }),
      bottomNavigationBar: _buildBottomBar(color, widget.listingId),
    );
  }

  // ─── Main Info ───────────────────────────────────────────
  Widget _buildMainInfo(Map<String, dynamic> bike, Color color, bool isNew) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(bike['condition'] as String? ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(bike['name'] as String? ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: BikerColors.black,
              )),
          const SizedBox(height: 8),
          Text(bike['price'] as String? ?? 'Price N/A', // Handle missing price
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: color,
              )),
          const SizedBox(height: 12),
          // Rating + location
          Row(children: [
            const Icon(Icons.star_rounded, color: Color(0xFFF9A825), size: 16),
            Text(bike['rating'] as String? ?? '0',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                )),
            const SizedBox(width: 16),
            const Icon(Icons.location_on_rounded, color: Colors.grey, size: 14),
            Text(bike['location'] as String? ?? 'N/A', // Display location
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ],
      ),
    );
  }

  // ─── Specs Card ──────────────────────────────────────────
  Widget _buildSpecsCard(Map<String, dynamic> bike, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text("Specifications",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: BikerColors.black,
                )),
          ]),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildSpecItem(Icons.calendar_today_rounded, "Year",
                  bike['year'] as String? ?? 'N/A', color),
              _buildSpecItem(Icons.speed_rounded, "Engine",
                  bike['cc'] as String? ?? 'N/A', color),
              _buildSpecItem(Icons.local_gas_station_rounded, "Mileage",
                  bike['mileage'] as String? ?? 'N/A', color),
              _buildSpecItem(Icons.info_outline_rounded, "Condition",
                  bike['condition'] as String? ?? 'N/A', color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 9)),
              Text(value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Seller Card ─────────────────────────────────────────
  Widget _buildSellerCard(Map<String, dynamic> bike, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(
              (bike['seller'] as String? ?? 'S')[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bike['seller'] as String? ?? 'Unknown Seller',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: BikerColors.black,
                    )),
                const Text("Verified Seller ✓",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
                Text(bike['phone'] as String? ?? '+92 300 1234567',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final phone = bike['phone'] as String? ?? '';
              if (phone.isNotEmpty) {
                final url =
                    Uri.parse('sms:${phone.replaceAll(RegExp(r'\s+'), '')}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Could not launch messaging app.')),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No contact number available.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.chat_rounded, size: 14),
            label: const Text("Chat"),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Map<String, dynamic> bike, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text("Description",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: BikerColors.black,
                )),
          ]),
          const SizedBox(height: 10),
          Text(
              bike['description'] as String? ??
                  "No description available.", // Display description
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                height: 1.6,
              )),
        ],
      ),
    );
  }

  // ─── Bottom Bar ──────────────────────────────────────────
  Widget _buildBottomBar(Color color, String id) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Buy button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => _showBuyDialog(color, id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Buy Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(Color color, String id) async {
    Map<String, dynamic>? data;

    // Check if the item is static or needs to be fetched from Firestore
    if (id.startsWith('static_')) {
      data = _getStaticData(id);
    } else {
      final doc =
          await FirebaseFirestore.instance.collection('listings').doc(id).get();
      data = doc.data() as Map<String, dynamic>?;
    }

    if (data == null || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Purchase",
            style: TextStyle(
                fontWeight: FontWeight.w900, color: BikerColors.black)),
        content: Text(
            "Contact seller to finalize purchase of ${data!['name']}?",
            style: const TextStyle(color: Colors.grey)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text("Cancel", style: TextStyle(color: BikerColors.blue)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final phone = data!['phone'] as String? ?? '';
              if (phone.isNotEmpty) {
                final url =
                    Uri.parse('tel:${phone.replaceAll(RegExp(r'\s+'), '')}');
                if (await canLaunchUrl(url))
                  await launchUrl(url);
                else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch dialer.')),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No contact number available.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Contact Seller",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
