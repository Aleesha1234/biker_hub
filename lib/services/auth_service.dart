import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Login ─────────────────────────────────────────────
  Future<String?> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email";
        case 'wrong-password':
          return "Wrong password. Try again";
        case 'invalid-email':
          return "Invalid email address";
        case 'user-disabled':
          return "This account has been disabled";
        case 'too-many-requests':
          return "Too many attempts. Try later";
        default:
          return "Login failed. Please try again";
      }
    } catch (e) {
      return "Something went wrong";
    }
  }

  // ─── Register ──────────────────────────────────────────
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = "",
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Display name set karo
      await cred.user?.updateDisplayName(name);

      // Firestore mein user data save karo
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'rides': 0,
        'friends': 0,
        'listings': 0,
      });

      return "Success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "Email already registered";
        case 'weak-password':
          return "Password is too weak";
        case 'invalid-email':
          return "Invalid email address";
        default:
          return "Registration failed. Try again";
      }
    } catch (e) {
      return "Something went wrong";
    }
  }

  // ─── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Current User ──────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─── Password Reset ────────────────────────────────────
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to send reset email";
    }
  }
}
