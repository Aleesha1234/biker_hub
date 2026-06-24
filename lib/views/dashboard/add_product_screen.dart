import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = 'Bikes';
  String _selectedCondition = 'New';
  bool _isLoading = false;

  final List<String> _categories = ['Bikes', 'Sports', 'Heavy', 'Accessories'];
  final List<String> _conditions = ['New', 'Used'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.greyLt,
      appBar: AppBar(
        backgroundColor: BikerColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text("Sell Your Bike",
            style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Upload ─────────────────────
              _buildImageUpload(),
              const SizedBox(height: 16),

              // ── Title ────────────────────────────
              _buildLabel("Bike/Product Title"),
              const SizedBox(height: 8),
              _buildField(
                controller: _titleCtrl,
                hint: "e.g. Honda CB 150F 2024",
                icon: Icons.motorcycle_rounded,
                validator: (v) => v!.isEmpty ? "Title required" : null,
              ),
              const SizedBox(height: 14),

              // ── Price ────────────────────────────
              _buildLabel("Price (PKR)"),
              const SizedBox(height: 8),
              _buildField(
                controller: _priceCtrl,
                hint: "e.g. 500000",
                icon: Icons.monetization_on_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Price required" : null,
              ),
              const SizedBox(height: 14),

              // ── Category + Condition ─────────────
              Row(children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Category"),
                    const SizedBox(height: 8),
                    _buildDropdown(_categories, _selectedCategory,
                        (v) => setState(() => _selectedCategory = v!)),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Condition"),
                    const SizedBox(height: 8),
                    _buildDropdown(_conditions, _selectedCondition,
                        (v) => setState(() => _selectedCondition = v!)),
                  ],
                )),
              ]),
              const SizedBox(height: 14),

              // ── Location ─────────────────────────
              _buildLabel("Location"),
              const SizedBox(height: 8),
              _buildField(
                controller: _locationCtrl,
                hint: "e.g. Lahore, Punjab",
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? "Location required" : null,
              ),
              const SizedBox(height: 14),

              // ── Description ──────────────────────
              _buildLabel("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Description required" : null,
                decoration: InputDecoration(
                  hintText: "Describe your bike condition, history...",
                  hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.7), fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: BikerColors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit Button ─────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: _isLoading
                    ? Container(
                        decoration: BoxDecoration(
                          color: BikerColors.blue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _handleSubmit,
                        icon: const Icon(Icons.upload_rounded,
                            color: Colors.white),
                        label: const Text("Post Listing",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BikerColors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BikerColors.blue.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: BikerColors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_photo_alternate_rounded,
                color: BikerColors.blue, size: 28),
          ),
          const SizedBox(height: 10),
          const Text("Add Photos",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: BikerColors.blue,
              )),
          const Text("Tap to upload bike images",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
          color: BikerColors.black,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: BikerColors.black, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
        prefixIcon: Icon(icon, color: BikerColors.blue, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: BikerColors.blue),
          style: const TextStyle(
              color: BikerColors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Listing posted! 🎉",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }
}
