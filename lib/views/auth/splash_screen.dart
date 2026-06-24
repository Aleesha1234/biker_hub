import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/app_theme.dart';
import 'login_screen.dart'
    hide BikerColors; // Splash ke baad login par janay ke liye

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // --- Animation Setup ---
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // --- Timer: 3 seconds baad Login Screen par shift hona ---
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.darkBlue, // Deep blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Animated Logo ---
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: BikerColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: BikerColors.black, width: 4),
                  boxShadow: const [
                    BoxShadow(color: BikerColors.black, offset: Offset(6, 6)),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png', // Aapka minimalist logo
                  width: 120,
                  height: 120,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- App Name ---
            const Text(
              "BIKERS HUB",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 10),

            // --- Tagline ---
            const Text(
              "RIDE • REPAIR • REPEAT",
              style: TextStyle(
                color: BikerColors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 60),

            // --- Loading Indicator ---
            const CircularProgressIndicator(
              color: BikerColors.blue,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
