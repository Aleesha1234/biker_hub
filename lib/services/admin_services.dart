import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // add karo

class AdminService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ─── Check Admin Role ──────────────────────────────────
  Future<bool> isAdmin() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  // ─── Get All Users ─────────────────────────────────────
  Stream<QuerySnapshot> getAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── Block / Unblock User ──────────────────────────────
  Future<void> toggleBlockUser(String uid, bool block) async {
    await _db.collection('users').doc(uid).update({
      'isBlocked': block,
      'blockedAt': block ? FieldValue.serverTimestamp() : null,
    });
  }

  // ─── Delete User ───────────────────────────────────────
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
    // Delete user listings too
    final listings =
        await _db.collection('listings').where('uid', isEqualTo: uid).get();
    for (var doc in listings.docs) {
      await doc.reference.delete();
    }
  }

  // ─── Get All Listings ──────────────────────────────────
  Stream<QuerySnapshot> getAllListings() {
    return _db
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── Update Listing ────────────────────────────────────
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _db.collection('listings').doc(id).update(data);
  }

  // ─── Delete Listing ────────────────────────────────────
  Future<void> deleteListing(String id) async {
    await _db.collection('listings').doc(id).delete();
  }

  // ─── Get All Comments ──────────────────────────────────
  Stream<QuerySnapshot> getAllComments() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── Delete Comment / Post ─────────────────────────────
  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }

  // ─── Add DIY Video ─────────────────────────────────────
  Future<void> addDiyVideo({
    required String title,
    required String description,
    required String videoUrl,
    required String category,
    required String duration,
    required String level,
    required List<String> steps,
  }) async {
    await _db.collection('diy_tutorials').add({
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'category': category,
      'duration': duration,
      'level': level,
      'steps': steps,
      'views': 0,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'addedBy': _auth.currentUser?.uid,
    });
  }

  // ─── Delete DIY Video ──────────────────────────────────
  Future<void> deleteDiyVideo(String id) async {
    await _db.collection('diy_tutorials').doc(id).delete();
  }

  // ─── Get All Activities ────────────────────────────────
  Stream<QuerySnapshot> getAllActivities() {
    return _db
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // ─── Log Activity ──────────────────────────────────────
  Future<void> logActivity({
    required String type,
    required String description,
    required String userId,
    String? targetId,
  }) async {
    await _db.collection('activities').add({
      'type': type,
      'description': description,
      'userId': userId,
      'targetId': targetId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ─── Get Stats ─────────────────────────────────────────
  Future<Map<String, int>> getStats() async {
    final users = await _db.collection('users').count().get();
    final listings = await _db.collection('listings').count().get();
    final posts = await _db.collection('posts').count().get();
    final tutorials = await _db.collection('diy_tutorials').count().get();
    return {
      'users': users.count ?? 0,
      'listings': listings.count ?? 0,
      'posts': posts.count ?? 0,
      'tutorials': tutorials.count ?? 0,
    };
  }

  // ─── Get Activities (was empty!) ───────────────────────
  Stream<QuerySnapshot> getActivities() {
    return _db
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

// ─── Get Dashboard Stats (was empty!) ─────────────────
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final users = await _db.collection('users').count().get();
      final listings = await _db.collection('listings').count().get();
      final posts = await _db.collection('posts').count().get();
      final tutorials = await _db.collection('diy_tutorials').count().get();
      return {
        'users': users.count ?? 0,
        'listings': listings.count ?? 0,
        'posts': posts.count ?? 0,
        'tutorials': tutorials.count ?? 0,
      };
    } catch (e) {
      debugPrint('Stats error: $e');
      return {'users': 0, 'listings': 0, 'posts': 0, 'tutorials': 0};
    }
  }

// ─── Get All Posts (was empty!) ────────────────────────
  Stream<QuerySnapshot> getAllPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get real-time count of online users
  Stream<int> getActiveUserCount() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'user') // Count only regular users
        .snapshots()
        .map((snap) => snap.docs
            .length); // In a full implementation, filter by a 'lastSeen' field
  }

  // Get sales data for the last 7 days aggregated by day
  Stream<List<double>> getWeeklySalesData(String category) {
    return _db.collection('orders').snapshots().map((snapshot) {
      List<double> dailyValues = [
        5,
        5,
        5,
        5,
        5,
        5,
        5
      ]; // Baseline for the chart
      final now = DateTime.now();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['orderDate'] as Timestamp?)?.toDate();
        if (timestamp != null && now.difference(timestamp).inDays < 7) {
          int dayIndex = timestamp.weekday - 1; // 0 (Mon) to 6 (Sun)
          final items = data['items'] as List? ?? [];
          for (var item in items) {
            if (item['category'] == category) {
              // Increment the bar height based on units sold (scaled for UI)
              dailyValues[dayIndex] +=
                  (item['qty'] as int? ?? 1).toDouble() * 10;
            }
          }
        }
      }
      return dailyValues
          .map((v) => v > 80 ? 80.0 : v)
          .toList(); // Cap at max chart height
    });
  }

  Future<void> updateDiyVideo(String docId, Map<String, String> map) async {}
}
