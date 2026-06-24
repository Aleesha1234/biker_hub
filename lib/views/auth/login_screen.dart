import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../register_screen.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_dashboard.dart';
import '../dashboard/notification_screen.dart';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─── Login Handler ───────────────────────────────────────
  // ─── Login Handler ───────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService().loginUser(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "Success") {
      // ── Admin role check ──────────────────────────────
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final role = doc.data()?['role'] ?? 'user';

      if (!mounted) return;

      if (role == 'admin') {
        _showSnack("Welcome Admin!", BikerColors.blue);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        addNotification(
          title: "Login Successful",
          message: "Welcome back to Bikers Hub!",
          icon: Icons.login_rounded,
        );
        _showSnack("Welcome Back!", BikerColors.blue);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } else {
      _showSnack(result ?? "Login failed", BikerColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ─── Forgot Password ─────────────────────────────────────
  void _handleForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ForgotPasswordSheet(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Logo Start ---
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BikerColors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: BikerColors.black, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: BikerColors.black, offset: Offset(3, 3))
                          ],
                        ),
                        child: Image.asset('assets/images/logo.png',
                            width: 80, height: 80),
                      ),
                    ),
                    const SizedBox(height: 20),
// --- Logo End ---

                    // ── Header ──────────────────────────────
                    _buildHeader(),
                    const SizedBox(height: 36),

                    // ── Form Fields ──────────────────────────
                    _buildLabel("Email Address"),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _emailCtrl,
                      hint: "you@example.com",
                      icon: Icons.email_outlined,
                      isPassword: false,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Email is required";
                        if (!v.contains('@')) return "Enter valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Password"),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _passCtrl,
                      hint: "Enter your password",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return "Password is required";
                        if (v.length < 6) return "Min 6 characters";
                        return null;
                      },
                    ),

                    // ── Forgot Password ──────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(
                            foregroundColor: BikerColors.blue),
                        child: const Text("Forgot Password?",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Login Button ─────────────────────────
                    _buildLoginButton(),
                    const SizedBox(height: 28),

                    // ── Divider ──────────────────────────────
                    _buildDivider(),
                    const SizedBox(height: 24),

                    // ── Social Login ─────────────────────────
                    _buildGoogleButton(),
                    const SizedBox(height: 28),

                    // ── Register Link ────────────────────────
                    _buildRegisterLink(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header Widget ───────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo + App name row
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: BikerColors.blue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: BikerColors.blue.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Icon(Icons.motorcycle_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Text("BIKERS HUB",
                style: TextStyle(
                  color: BikerColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                )),
          ],
        ),
        const SizedBox(height: 32),

        // Title
        const Text("Welcome\nBack ",
            style: TextStyle(
              color: BikerColors.black,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1.15,
            )),
        const SizedBox(height: 10),
        const Text("Sign in to continue your ride",
            style: TextStyle(
                color: BikerColors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w400)),
      ],
    );
  }

  // ─── Field Label ─────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
          color: BikerColors.black,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ));
  }

  // ─── Input Field ─────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePass : false,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      style: const TextStyle(
          color: BikerColors.black, fontSize: 15, fontWeight: FontWeight.w500),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: BikerColors.grey.withOpacity(0.7), fontSize: 14),
        prefixIcon: Icon(icon, color: BikerColors.blue, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: BikerColors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              )
            : null,
        filled: true,
        fillColor: BikerColors.greyLt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BikerColors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BikerColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BikerColors.error, width: 2),
        ),
      ),
    );
  }

  // ─── Login Button ────────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _isLoading
          ? Container(
              decoration: BoxDecoration(
                color: BikerColors.blue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            )
          : ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: BikerColors.blue,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: BikerColors.blue.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("LOGIN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      )),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
    );
  }

  // ─── Divider ─────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text("OR",
            style: TextStyle(
                color: BikerColors.grey.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      ),
      const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
    ]);
  }

  // ─── Google Button ───────────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          // Google sign-in — future feature
          _showSnack("Google Sign-in coming soon!", BikerColors.blue);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: BikerColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child:
                  const Icon(Icons.g_mobiledata, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text("Continue with Google",
                style: TextStyle(
                  color: BikerColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  // ─── Register Link ───────────────────────────────────────
  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("New to Bikers Hub?  ",
              style: TextStyle(
                  color: BikerColors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: BikerColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BikerColors.blue.withOpacity(0.3)),
              ),
              child: const Text("Register",
                  style: TextStyle(
                    color: BikerColors.blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Forgot Password Bottom Sheet
// ═══════════════════════════════════════════════════════════════
class _ForgotPasswordSheet extends StatefulWidget {
  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  Future<void> _sendReset() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    // AuthService().sendPasswordReset(_emailCtrl.text.trim());
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 28,
        right: 28,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: BikerColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text("Reset Password",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: BikerColors.black,
              )),
          const SizedBox(height: 6),
          const Text("Enter your email — we'll send a reset link.",
              style: TextStyle(color: BikerColors.grey, fontSize: 14)),
          const SizedBox(height: 24),

          if (!_sent) ...[
            TextFormField(
              controller: _emailCtrl,
              style: const TextStyle(color: BikerColors.black), // Set text color to black
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "your@email.com",
                prefixIcon: const Icon(Icons.email_outlined,
                    color: BikerColors.blue, size: 20),
                filled: true,
                fillColor: BikerColors.greyLt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BikerColors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Send Reset Link",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
              ),
            ),
          ] else ...[
            // Success state
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Reset link sent! Check your email inbox.",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BikerColors.blue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Back to Login",
                    style: TextStyle(
                        color: BikerColors.blue, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
