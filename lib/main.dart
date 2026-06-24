import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'utils/app_theme.dart';
import 'views/auth/splash_screen.dart';
import 'views/auth/login_screen.dart'; // Add this
import 'views/admin/admin_dashboard.dart'; // Add path accordingly
import 'views/dashboard/dashboard_screen.dart'; // Add path accordingly

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BikersHub());
}

class BikersHub extends StatelessWidget {
  const BikersHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bikers Hub',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Yahan hum FutureBuilder use karenge jo check karega user logged in hai ya nahi
      home: const AuthWrapper(),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Authentication Error: ${snapshot.error}")),
          );
        }


        if (!snapshot.hasData) {
          return const LoginScreen();
        }

    
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, docSnapshot) {
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (docSnapshot.hasData && docSnapshot.data!.exists) {
              final role = docSnapshot.data!['role'] as String? ?? 'user';
              if (role == 'admin') {
                return const AdminDashboard();
              }
              return const DashboardScreen();
            }

            // Fallback agar data na mile
            return const LoginScreen();
          },
        );
      },
    );
  }
}
