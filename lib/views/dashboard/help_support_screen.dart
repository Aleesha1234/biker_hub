import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_rounded),
            SizedBox(width: 10),
            Text("HELP & SUPPORT",
                style:
                    TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        backgroundColor: BikerColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you today?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: BikerColors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Find answers to frequently asked questions or contact our support team directly.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Frequently Asked Questions"),
            const SizedBox(height: 10),
            _buildFAQTile("How do I book a mechanic?",
                "You can book a mechanic by going to the 'Mechanic' tab, choosing a workshop, and contacting them directly via call or visit."),
            _buildFAQTile("How can I sell my bike?",
                "Navigate to the 'Market' tab. You can browse listings there, and to sell, you can contact our admin team for verification and listing."),
            _buildFAQTile("What is the DIY Garage?",
                "The DIY Garage provides step-by-step video tutorials to help you maintain and fix your bike yourself at home."),
            _buildFAQTile("Is there an emergency service?",
                "Yes, use the 'SOS' tab on the home screen for emergency roadside assistance and live location sharing with emergency contacts."),
            const SizedBox(height: 30),
            _buildSectionTitle("Contact Support"),
            const SizedBox(height: 15),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Email Us",
              subtitle: "support@bikerhub.com",
              color: BikerColors.blue,
              onTap: () {},
            ),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: "Call Us",
              subtitle: "+92 300 1234567",
              color: BikerColors.blue,
              onTap: () {},
            ),
            _buildContactCard(
              icon: Icons.chat_outlined,
              title: "Live WhatsApp Chat",
              subtitle: "Average response time: 5 mins",
              color: const Color(0xFF25D366),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: BikerColors.blue,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BikerColors.greyLt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(question,
            style: const TextStyle(
                color: BikerColors.black,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer,
                style: const TextStyle(
                    color: BikerColors.black, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
