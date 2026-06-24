import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'market_tab.dart';
import 'mechanic_tab.dart';
import 'diy_tab.dart';
import 'sos_tab.dart';
import 'community_tab.dart';
import 'profile_tab.dart';
import '../../utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // ─── All Tabs ──────────────────────────────────────────
  final List<Widget> _pages = const [
    HomeTab(),
    MarketTab(),
    MechanicTab(),
    CommunityTab(),
    ProfileTab(),
  ];

  // ─── Nav Items ─────────────────────────────────────────
  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, "Home"),
    _NavItem(Icons.storefront_rounded, Icons.storefront_outlined, "Market"),
    _NavItem(Icons.build_circle, Icons.build_circle_outlined, "Mechanic"),
    _NavItem(Icons.people_rounded, Icons.people_outline, "Community"),
    _NavItem(Icons.person_rounded, Icons.person_outline, "Profile"),
  ];

  void _onTabTap(int index) {
    // SOS button — special action
    if (index == 2) {
      _showQuickMenu(context);
      return;
    }
    setState(() => _currentIndex = index);
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BikerColors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // ── Floating Action Button (SOS) ──────────────────
      floatingActionButton: _buildSOSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Nav ────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── SOS Floating Button ───────────────────────────────
  Widget _buildSOSButton() {
    return GestureDetector(
      onTap: () => _showQuickMenu(context),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: BikerColors.blue,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: BikerColors.blue.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text("More",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Navigation Bar ─────────────────────────────
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: BikerColors.white,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // First 2 tabs
            _buildNavItem(0),
            _buildNavItem(1),

            // Center gap for FAB
            const SizedBox(width: 62),

            // Last 2 tabs
            _buildNavItem(2),
            _buildNavItem(3),
          ],
        ),
      ),
    );
  }

  // ─── Single Nav Item ───────────────────────────────────
  Widget _buildNavItem(int index) {
    // Map visible index to actual page index
    // 0→Home, 1→Market, gap, 2→Community, 3→Profile
    final pageIndex = index >= 2 ? index + 1 : index;
    // But we only have 4 items so remap:
    // navIndex 0 = page 0 (Home)
    // navIndex 1 = page 1 (Market)
    // navIndex 2 = page 3 (Community)
    // navIndex 3 = page 4 (Profile)
    final actualPage = [0, 1, 3, 4][index];
    final isSelected = _currentIndex == actualPage;
    final item = [
      _navItems[0], // Home
      _navItems[1], // Market
      _navItems[3], // Community
      _navItems[4], // Profile
    ][index];

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = actualPage),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 40 : 0,
                    height: isSelected ? 32 : 0,
                    decoration: BoxDecoration(
                      color: BikerColors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? BikerColors.blue : BikerColors.black,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // Label
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? BikerColors.blue : BikerColors.black,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Quick Menu (More options) ─────────────────────────
  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: BikerColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Quick Access",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BikerColors.black,
                )),
            const SizedBox(height: 20),

            // Grid of quick actions
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildQuickAction(
                  icon: Icons.build_circle_rounded,
                  label: "Mechanic",
                  color: const Color(0xFF1565C0),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  },
                ),
                _buildQuickAction(
                  icon: Icons.play_circle_rounded,
                  label: "DIY Garage",
                  color: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.pop(context);
                    // DIY tab navigate
                    _navigateTo(context, const DiyTab());
                  },
                ),
                _buildQuickAction(
                  icon: Icons.emergency_rounded,
                  label: "SOS",
                  color: const Color(0xFFD32F2F),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateTo(context, const SosTab());
                  },
                ),
                _buildQuickAction(
                  icon: Icons.map_rounded,
                  label: "Live Map",
                  color: const Color(0xFF00695C),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Quick Action Tile ─────────────────────────────────
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }

  // ─── Navigate to full screen ───────────────────────────
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ─── Nav Item Model ────────────────────────────────────────
class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}
