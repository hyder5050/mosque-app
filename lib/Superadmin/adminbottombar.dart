import 'package:find_masjid/Superadmin/adminHomepage.dart';
import 'package:find_masjid/Superadmin/adminMosquelist.dart'; 
import 'package:find_masjid/Superadmin/adminsetting.dart';
import 'package:find_masjid/widget/custom/appcolor.dart';
import 'package:flutter/material.dart';

class Admin_bottom_bar extends StatefulWidget {
  const Admin_bottom_bar({super.key});

  @override
  State<Admin_bottom_bar> createState() => _Admin_bottom_barState();
}

class _Admin_bottom_barState extends State<Admin_bottom_bar> {
  int _currentIndex = 0;
  late final PageController _pageController;

  late final List<Widget> _pages;

  final List<NavItem> _navItems = const [
    NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Map',
    ),
    NavItem(
      icon: Icons.mosque_outlined,
      activeIcon: Icons.mosque_rounded,
      label: 'Mosques',
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = const [Adminhomepage(), AdminMosquelist(), Adminsetting()];
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16, // manual spacing instead of SafeArea
            child: _FloatingBottomBar(
              navItems: _navItems,
              currentIndex: _currentIndex,
              onTap: _onTap,
            ),
          ),
        ],
      ),

      // 🔥 FLOATING PILL BOTTOM BAR

      // bottomNavigationBar: SafeArea(
      //   minimum: const EdgeInsets.only(bottom: 12),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16),
      //     child: _FloatingBottomBar(
      //       navItems: _navItems,
      //       currentIndex: _currentIndex,
      //       onTap: _onTap,
      //     ),
      //   ),
      // ),
    );
  }
}

/* ----------------------------- */
/*        FLOATING BAR           */
/* ----------------------------- */

class _FloatingBottomBar extends StatelessWidget {
  final List<NavItem> navItems;
  final int currentIndex;
  final Function(int) onTap;

  const _FloatingBottomBar({
    required this.navItems,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: AppColor.primaryGradient,
        borderRadius: BorderRadius.circular(40), // pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) => _FloatingNavItem(
            item: navItems[index],
            isSelected: currentIndex == index,
            onTap: () => onTap(index),
          ),
        ),
      ),
    );
  }
}

 
class _FloatingNavItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- */
/*        MODEL                  */
/* ----------------------------- */

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}