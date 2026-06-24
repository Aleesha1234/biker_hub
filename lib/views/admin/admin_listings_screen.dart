import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_services.dart';

class AdminListingsScreen extends StatelessWidget {
  const AdminListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AdminService();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text("Manage Listings",
            style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getAllListings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: BikerColors.blue));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("No listings found",
                  style: TextStyle(color: Colors.white38)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return _buildListingTile(context, data, docs[i].id, service);
            },
          );
        },
      ),
    );
  }

  Widget _buildListingTile(
    BuildContext context,
    Map<String, dynamic> data,
    String id,
    AdminService service,
  ) {
    final color = const Color(0xFFE65100);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.motorcycle_rounded, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'] as String? ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
                Text(data['price'] as String? ?? 'N/A',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
                Text(data['location'] as String? ?? '',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: const Color(0xFF1A1A2E),
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
            onSelected: (val) async {
              if (val == 'delete') {
                await service.deleteListing(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Listing deleted",
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ));
                }
              } else if (val == 'feature') {
                await service.updateListing(id, {'featured': true});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Marked featured!",
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.green,
                  ));
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'feature',
                child: Row(children: [
                  Icon(Icons.star_rounded, color: Color(0xFFF9A825), size: 16),
                  SizedBox(width: 8),
                  Text('Mark Featured', style: TextStyle(color: Colors.white)),
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
    );
  }
}
