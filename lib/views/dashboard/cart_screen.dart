import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'notification_screen.dart';

// Simple global cart list to persist data between navigations
List<Map<String, dynamic>> cartItems = [];

// Global list to store successful orders
List<Map<String, dynamic>> orderHistory = [];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime? _selectedDate;

  int get _total => cartItems.fold(0,
      (sum, item) => sum + ((item['priceNum'] as int) * (item['qty'] as int)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("SHOPPING CART",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: BikerColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text("Your cart is empty",
                  style: TextStyle(color: Colors.grey)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
                ),
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BikerColors.greyLt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: BikerColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(item['icon'] as IconData, color: BikerColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(item['price'],
                    style: const TextStyle(
                        color: BikerColors.blue,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(Icons.remove, () {
                setState(() {
                  if (item['qty'] > 1) item['qty']--;
                });
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("${item['qty']}",
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              _qtyBtn(Icons.add, () {
                setState(() => item['qty']++);
              }),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => cartItems.removeAt(index)),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, size: 16, color: BikerColors.black),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min, // Removed to allow SingleChildScrollView to manage height
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount:",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text("PKR $_total",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: BikerColors.blue)),
                ],
              ),
              const Divider(height: 24),
              _buildTextField(_nameCtrl, "Contact Name", Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(
                  _phoneCtrl, "Phone Number", Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(
                  _addressCtrl, "Delivery Address", Icons.location_on_outlined,
                  maxLines: 2),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: BikerColors.greyLt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 20, color: BikerColors.blue),
                      const SizedBox(width: 12),
                      Text(
                          _selectedDate == null
                              ? "Select Delivery Date"
                              : "Delivery Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey
                                  : BikerColors.black,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.payments_outlined, color: BikerColors.blue),
                    SizedBox(width: 10),
                    Text("Payment: Cash on Delivery Only",
                        style: TextStyle(
                            color: BikerColors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BikerColors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: const Text("PLACE ORDER",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      style:
          const TextStyle(color: BikerColors.black), // Set text color to black
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: BikerColors.greyLt,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(days: 3));
    final date = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: BikerColors.blue)),
          child: child!),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all details and select a date")));
      return;
    }

    final orderData = {
      'items': List.from(cartItems),
      'total': _total,
      'orderDate': FieldValue.serverTimestamp(),
      'deliveryDate': Timestamp.fromDate(_selectedDate!),
      'customerName': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
    };

    // Save to order history before clearing the cart
    orderHistory.add(orderData);

    // Persist to Firestore for Admin tracking
    FirebaseFirestore.instance.collection('orders').add(orderData);

    addNotification(
      title: "Order Placed",
      message:
          "Order for PKR $_total has been successfully placed. Expect delivery by ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}.",
      icon: Icons.shopping_bag_rounded,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ORDER IS PLACED! 🎉"),
        content: const Text(
            "Your order has been successfully placed. Our team will contact you soon for confirmation."),
        actions: [
          TextButton(
              onPressed: () {
                setState(() => cartItems.clear());
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"))
        ],
      ),
    );
  }
}
