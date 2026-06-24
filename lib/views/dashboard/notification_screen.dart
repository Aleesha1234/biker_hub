import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';

// Helper function to add a notification
void addNotification({
  required String title,
  required String message,
  required IconData icon,
}) {
  FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'message': message,
    'iconCode': icon.codePoint,
    'time': FieldValue.serverTimestamp(),
  });
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_rounded),
            SizedBox(width: 10),
            Text("NOTIFICATIONS",
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        backgroundColor: BikerColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No new notifications",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = docs[index].data() as Map<String, dynamic>;
              final Timestamp? timeStamp = item['time'] as Timestamp?;
              final DateTime time = timeStamp?.toDate() ?? DateTime.now();
              final IconData icon = IconData(
                  item['iconCode'] ?? Icons.notifications.codePoint,
                  fontFamily: 'MaterialIcons');

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BikerColors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: BikerColors.blue, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(item['message'] ?? '',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                height: 1.4)),
                        const SizedBox(height: 8),
                        Text(
                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}