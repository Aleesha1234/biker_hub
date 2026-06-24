import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_services.dart';
import '../../utils/app_theme.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminService service = AdminService();
    final Color adminBlue = const Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: adminBlue,
        foregroundColor: Colors.white,
        title: const Text("Admin Notifications",
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getAllActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text("No new notifications",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildNotificationTile(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> data) {
    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr = timestamp != null
        ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
        : "--:--";

    // Design matching NOTIFCATION.jpeg
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Color(0xFF1E88E5), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("System Notification",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(data['description'] ?? "System activity recorded.",
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 14, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(timeStr,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
