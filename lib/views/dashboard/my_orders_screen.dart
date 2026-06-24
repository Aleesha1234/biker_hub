import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'cart_screen.dart'; // To access orderHistory

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded),
            SizedBox(width: 10),
            Text("MY ORDERS",
                style:
                    TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        backgroundColor: BikerColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: orderHistory.isEmpty
          ? const Center(
              child: Text("No orders placed yet",
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                final order = orderHistory[index];
                final DateTime orderDate = order['orderDate'];
                final DateTime deliveryDate = order['deliveryDate'];
                final List items = order['items'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BikerColors.greyLt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order #${orderHistory.length - index}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text("Processing",
                                style: TextStyle(
                                    color: BikerColors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 14, color: BikerColors.blue),
                                const SizedBox(width: 8),
                                Text("${item['name']} (x${item['qty']})",
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      _buildDetailRow("Placed On:",
                          "${orderDate.day}/${orderDate.month}/${orderDate.year}"),
                      _buildDetailRow("Delivery Date:",
                          "${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount:",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text("PKR ${order['total']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: BikerColors.blue,
                                  fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
