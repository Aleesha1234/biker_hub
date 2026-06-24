import 'package:flutter/material.dart';
// Agar aapka folder structure: lib/utils/app_theme.dart hai
import '../utils/app_theme.dart';
// Agar aapka folder structure: lib/services/auth_service.dart hai
import '../services/auth_service.dart';
// Navigation paths
import 'auth/login_screen.dart' hide BikerColors;
import 'dashboard/dashboard_screen.dart';
import 'admin/admin_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  String _selectedRole = 'user';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate that passwords match
    if (_passCtrl.text != _confirmCtrl.text) {
      _showSnack("Passwords do not match", Colors.redAccent);
      return;
    }

    if (!_agreeTerms) {
      _showSnack("Please accept terms & conditions", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService().registerUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "Success") {
      _showSnack("Welcome to Bikers Hub!", BikerColors.blue);

      final target = _selectedRole == 'admin'
          ? const AdminDashboard()
          : const DashboardScreen();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => target),
        (route) => false,
      );
    } else {
      _showSnack(result ?? "Registration failed", Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.white,
      appBar: AppBar(
        backgroundColor: BikerColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: BikerColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildField(
                      controller: _nameCtrl,
                      hint: "Full Name",
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? "Enter your name" : null),
                  const SizedBox(height: 15),
                  _buildField(
                      controller: _emailCtrl,
                      hint: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.isEmpty) return "Enter your email";
                        if (!v.contains('@')) return "Enter a valid email";
                        return null;
                      }),
                  const SizedBox(height: 15),
                  _buildField(
                      controller: _phoneCtrl,
                      hint: "Phone",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v!.isEmpty) return "Enter your phone";
                        if (v.length < 10) return "Enter a valid phone number";
                        return null;
                      }),
                  const SizedBox(height: 15),
                  _buildRoleDropdown(),
                  const SizedBox(height: 15),
                  _buildField(
                    controller: _passCtrl,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscurePass,
                    validator: (v) {
                      if (v!.isEmpty) return "Enter a password";
                      if (v.length < 6)
                        return "Password must be at least 6 characters";
                      return null;
                    },
                    toggleObscure: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  const SizedBox(height: 15),
                  _buildField(
                    controller: _confirmCtrl,
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscureConfirm,
                    validator: (v) =>
                        v!.isEmpty ? "Please confirm your password" : null,
                    toggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 20),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 25),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Create Account",
            style: TextStyle(
                color: BikerColors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        Text("Join the community", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: BikerColors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: BikerColors.blue),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: BikerColors.lightGrey,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      dropdownColor: BikerColors.white,
      style: const TextStyle(color: BikerColors.black, fontSize: 15),
      decoration: InputDecoration(
        hintText: "Select Role",
        prefixIcon: const Icon(Icons.badge_outlined, color: BikerColors.blue),
        filled: true,
        fillColor: BikerColors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
      ),
      items: const [
        DropdownMenuItem(
          value: 'user',
          child: Text("User", style: TextStyle(color: BikerColors.black)),
        ),
        DropdownMenuItem(
          value: 'admin',
          child: Text("Admin", style: TextStyle(color: BikerColors.black)),
        ),
      ],
      onChanged: (v) {
        if (v != null) {
          setState(() {
            _selectedRole = v;
          });
        }
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: BikerColors.blue,
            side: const BorderSide(color: BikerColors.grey, width: 1.5)),
        const Text("I agree to terms & conditions",
            style: TextStyle(
                fontSize: 12,
                color: BikerColors.black,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: BikerColors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("REGISTER NOW",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        child: const Text("Already have an account? Login",
            style: TextStyle(color: BikerColors.blue)),
      ),
    );
  }
}
