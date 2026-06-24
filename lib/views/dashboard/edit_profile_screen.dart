import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _isLoading = false;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _user?.displayName);
    _emailCtrl = TextEditingController(text: _user?.email);
    // Note: Phone number retrieval depends on how it was stored (e.g., Firestore or Auth)
    _phoneCtrl = TextEditingController(text: _user?.phoneNumber ?? "");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update Display Name
      if (_nameCtrl.text.trim() != _user?.displayName) {
        await _user?.updateDisplayName(_nameCtrl.text.trim());
      }

      // Update Email (Note: Firebase may require recent login for this sensitive action)
      if (_emailCtrl.text.trim() != _user?.email) {
        await _user?.updateEmail(_emailCtrl.text.trim());
      }

      await _user?.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: BikerColors.blue),
        );
        Navigator.pop(context, true); // Return true to trigger UI refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 36),
              _buildField(
                  controller: _nameCtrl,
                  hint: "Full Name",
                  icon: Icons.person_outline),
              const SizedBox(height: 15),
              _buildField(
                  controller: _emailCtrl,
                  hint: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildField(
                  controller: _phoneCtrl,
                  hint: "Phone",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BikerColors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SAVE CHANGES",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              child: const Icon(Icons.edit_note_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Text("EDIT PROFILE",
                style: TextStyle(
                  color: BikerColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                )),
          ],
        ),
        const SizedBox(height: 32),
        const Text("Update\nProfile",
            style: TextStyle(
              color: BikerColors.black,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1.15,
            )),
        const SizedBox(height: 10),
        const Text("Refine your personal information below",
            style: TextStyle(color: BikerColors.grey, fontSize: 15)),
      ],
    );
  }

  Widget _buildField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: BikerColors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: BikerColors.blue),
        filled: true,
        fillColor: BikerColors.lightGrey,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }
}
