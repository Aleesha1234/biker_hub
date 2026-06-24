import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers to manage the input text and update the UI
  final TextEditingController _nameController =
      TextEditingController(text: "John Doe");
  final TextEditingController _usernameController =
      TextEditingController(text: "@biker_pro");
  final TextEditingController _bikeController =
      TextEditingController(text: "Yamaha MT-07");
  final TextEditingController _bioController = TextEditingController(
      text: "Passionate about mountain trails and weekend rides.");

  // Local state variables to show updated data immediately to the user
  String _currentName = "John Doe";
  String _currentBike = "Yamaha MT-07";

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bikeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    // Updating the state variables to reflect changes in the UI
    setState(() {
      _currentName = _nameController.text;
      _currentBike = _bikeController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF0D47A1), // Dark Blue background
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.manage_accounts), // Edit Profile Icon
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Updated Data Preview Section (Shows changes to the user)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Profile Info:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1))),
                  Text("Name: $_currentName"),
                  Text("Bike: $_currentBike"),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _buildInputField(
              controller: _nameController,
              label: "Full Name",
              hint: "Enter your full name (e.g., Alex Johnson)",
              icon: Icons.person,
            ),
            _buildInputField(
              controller: _usernameController,
              label: "Username",
              hint: "Choose a unique handle (e.g., @road_warrior)",
              icon: Icons.alternate_email,
            ),
            _buildInputField(
              controller: _bikeController,
              label: "Bike Model",
              hint: "What bike do you ride? (e.g., Ducati Panigale)",
              icon: Icons.motorcycle,
            ),
            _buildInputField(
              controller: _bioController,
              label: "Biker Bio",
              hint: "Share your biking experience or favorite routes",
              icon: Icons.history_edu,
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("SAVE CHANGES",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0D47A1), width: 2),
          ),
        ),
      ),
    );
  }
}
