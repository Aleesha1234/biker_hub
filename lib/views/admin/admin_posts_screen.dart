import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_services.dart';
import 'admin_dashboard.dart';
import 'admin_users_screen.dart';
import 'admin_edit_profile_screen.dart';
import 'admin_diy_screen.dart';
import 'admin_activity_screen.dart';
import 'admin_notification_screen.dart';
import '../register_screen.dart';
import '../auth/login_screen.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  int _selectedIndex = 2; // Products index

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _sellerController = TextEditingController();

  String _selectedCategory = 'Bike';
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();

  // Shared static data with MarketTab
  final List<Map<String, dynamic>> _staticData = [
    {
      'id': 'static_b1',
      'name': 'Yamaha YZF R6',
      'description':
          'Mint condition Yamaha R6, professionally maintained. Performance exhaust installed.',
      'likes': 120,
      'comments': 15,
      'type': 'Used',
      'location': 'Lahore',
      'contact': '03001234567',
      'image': 'assets/images/bike1.jpeg',
      'category': 'Bike',
    },
    {
      'id': 'static_b2',
      'name': 'Honda CBR 1000RR',
      'description':
          'Brand new Honda Fireblade. Zero meter, full warranty included.',
      'likes': 250,
      'comments': 42,
      'type': 'New',
      'location': 'Karachi',
      'contact': '03217654321',
      'image': 'assets/images/bike2.jpeg',
      'category': 'Bike',
    },
    {
      'id': 'static_b3',
      'name': 'Kawasaki Ninja H2',
      'description': 'Supercharged beast. Exceptional performance.',
      'likes': 400,
      'comments': 88,
      'type': 'New',
      'location': 'Islamabad',
      'contact': '03331122334',
      'image': 'assets/images/bike3.jpeg',
      'category': 'Bike',
    },
    {
      'id': 'static_b4',
      'name': 'Suzuki GSX-R1000',
      'description': 'Track ready Gixxer. Well maintained.',
      'likes': 180,
      'comments': 25,
      'type': 'Used',
      'location': 'Faisalabad',
      'contact': '03456677889',
      'image': 'assets/images/bike4.jpeg',
      'category': 'Bike',
    },
    {
      'id': 'static_b5',
      'name': 'BMW S1000RR',
      'description': 'German engineering at its finest.',
      'likes': 320,
      'comments': 50,
      'type': 'New',
      'location': 'Multan',
      'contact': '03129988776',
      'image': 'assets/images/bike5.jpeg',
      'category': 'Bike',
    },
    {
      'id': 'static_b6',
      'name': 'Ducati Panigale V4',
      'description': 'Italian masterpiece. Unmatched aesthetics.',
      'likes': 500,
      'comments': 105,
      'type': 'New',
      'location': 'Lahore',
      'contact': '03210000000',
      'image': 'assets/images/bike6.jpeg',
      'category': 'Bike',
    },
    {
      'id': 'static_a1',
      'name': 'MT Stinger Helmet',
      'description': 'DOT approved aerodynamic helmet with dual visor.',
      'likes': 45,
      'comments': 8,
      'type': 'New',
      'location': 'Accessories',
      'contact': 'Bikers Hub',
      'image': 'assets/accessories/acc1.jpeg',
      'category': 'Accessory',
    },
  ];

  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF0D1B2A);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E9F2);
  static const Color _accent = Color(0xFF1E88E5);

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
        // Already here
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
    final service = AdminService();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        backgroundColor: const Color(0xFF1E88E5), // Dashboard Blue
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.inventory_2_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Manage Products",
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
        stream: service.getAllListings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          final docs = snapshot.data!.docs;
          final allItems = [
            ..._staticData,
            ...docs
                .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allItems.length,
            itemBuilder: (_, i) {
              final data = allItems[i];
              return _buildProductTile(context, data, data['id'], service);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductModal(context, service),
        backgroundColor: _accent,
        tooltip: "Add Product",
        child: const Icon(Icons.add, color: Colors.white),
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

  Future<void> _pickImage(StateSetter setModalState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setModalState(() {
        _pickedImagePath = image.path;
      });
    }
  }

  void _showAddProductModal(BuildContext context, AdminService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add New Product",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _pickImage(setModalState),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: _pickedImagePath == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    size: 40, color: _textSecondary),
                                SizedBox(height: 8),
                                Text("Add Product Picture (Local)",
                                    style: TextStyle(color: _textSecondary)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(_pickedImagePath!),
                                  fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField("Product Name", _nameController,
                      Icons.shopping_bag_outlined),
                  _buildField("Description", _descriptionController,
                      Icons.description_outlined,
                      maxLines: 3),
                  _buildField("Location", _locationController,
                      Icons.location_on_outlined),
                  _buildField("Contact Number", _contactController,
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  _buildField("Price (e.g. PKR 50,000)", _priceController,
                      Icons.payments_outlined),
                  _buildField(
                      "Year", _yearController, Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number),
                  _buildField("CC", _ccController, Icons.speed_outlined),
                  _buildField(
                      "Mileage", _mileageController, Icons.route_outlined),
                  _buildField(
                      "Seller Name", _sellerController, Icons.person_outline),
                  const SizedBox(height: 16),
                  const Text("Category",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: ['Bike', 'Accessory']
                            .map((t) => DropdownMenuItem(
                                value: t,
                                child:
                                    Text(t == 'Accessory' ? 'Accessories' : t)))
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => _selectedCategory = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('listings')
                            .add({
                          'name': _nameController.text,
                          'description': _descriptionController.text,
                          'location': _locationController.text,
                          'contact': _contactController.text,
                          'price': _priceController.text,
                          'year': _yearController.text,
                          'cc': _ccController.text,
                          'mileage': _mileageController.text,
                          'seller': _sellerController.text,
                          'category': _selectedCategory,
                          'image': _pickedImagePath,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        await FirebaseFirestore.instance
                            .collection('activities')
                            .add({
                          'description':
                              'Admin added a new product: ${_nameController.text}',
                          'timestamp': FieldValue.serverTimestamp(),
                          'type': 'add_product'
                        });
                        if (context.mounted) Navigator.pop(context);
                        _nameController.clear();
                        _descriptionController.clear();
                        _locationController.clear();
                        _contactController.clear();
                        _priceController.clear();
                        _yearController.clear();
                        _ccController.clear();
                        _mileageController.clear();
                        _sellerController.clear();
                        setState(() {
                          _pickedImagePath = null;
                        });
                      },
                      child: const Text("Post Product",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
      String hint, TextEditingController controller, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: _textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textSecondary),
          prefixIcon: Icon(icon, size: 20, color: _textSecondary),
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildProductTile(
    BuildContext context,
    Map<String, dynamic> data,
    String productId,
    AdminService service,
  ) {
    final name = data['name'] as String? ?? 'Untitled Product';
    final description =
        data['description'] as String? ?? 'No description available.';
    final likes = data['likes'] ?? 0;
    final comments = data['comments'] ?? 0;
    final category = data['category'] as String? ?? 'Bike';
    final location = data['location'] as String? ?? 'Local';
    final contact = data['contact'] as String? ?? 'No Contact';
    final imagePath = data['image'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // Delete button
                IconButton(
                  onPressed: () =>
                      _confirmDelete(context, productId, name, service),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 20),
                  tooltip: "Delete Product",
                ),
              ],
            ),
          ),

          if (imagePath != null && imagePath.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildProductImage(imagePath, category),
              ),
            ),

          // ── Content ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              description,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: _textSecondary),
                const SizedBox(width: 4),
                Text(location,
                    style:
                        const TextStyle(color: _textSecondary, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.phone_outlined,
                    size: 14, color: _textSecondary),
                const SizedBox(width: 4),
                Text(contact,
                    style:
                        const TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),

          // ── Footer ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                // Likes
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 13, color: Colors.red),
                      const SizedBox(width: 5),
                      Text("$likes",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Comments
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 13, color: _accent),
                      const SizedBox(width: 5),
                      Text("$comments",
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String path, String category) {
    const double h = 180;
    const fit = BoxFit.cover;
    final placeholder = Container(
      height: h,
      width: double.infinity,
      color: _bg,
      child: const Icon(Icons.image_not_supported_outlined,
          color: _textSecondary, size: 40),
    );

    // 1. Full Asset Path
    if (path.startsWith('assets/')) {
      return Image.asset(path,
          height: h,
          width: double.infinity,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder);
    }
    // 2. Network URL (Cloud Storage)
    if (path.startsWith('http')) {
      return Image.network(path,
          height: h,
          width: double.infinity,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder);
    }
    // 3. Filename Only (Maps to folder based on category)
    if (!path.contains('/') && !path.contains('\\')) {
      final folder = category.toLowerCase() == 'accessory'
          ? 'assets/accessories/'
          : 'assets/images/';
      return Image.asset('$folder$path',
          height: h,
          width: double.infinity,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder);
    }
    // 4. Local File Path (Picked images)
    try {
      final file = File(path);
      return Image.file(file,
          height: h,
          width: double.infinity,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder);
    } catch (_) {
      return placeholder;
    }
  }

  void _confirmDelete(BuildContext context, String productId,
      String productName, AdminService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Product?",
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: const Text(
          "This product will be deleted permanently.",
          style: TextStyle(color: _textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(
                    color: _textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.deleteListing(productId);
              await FirebaseFirestore.instance.collection('activities').add({
                'description': 'Admin deleted product: $productName',
                'timestamp': FieldValue.serverTimestamp(),
                'type': 'delete_product'
              });
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
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
}
