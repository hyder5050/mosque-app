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

class _Admin_bottom_barState extends State<Admin_bottom_bar> 
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  
  late List<Widget> _pages;

  @override

  void initState() {
    super.initState();

    _pages = [
      const Adminhomepage(),
      const AdminMosquelist(),
      const Adminsetting(),
    ];
    
    _pageController=PageController(initialPage: _currentIndex);
    _animationController = AnimationController(duration: const Duration(milliseconds: 300),
      vsync: this,
      );
  }


  final List<NavItem> _navItems = [
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

  // @override
  // void initState() {
  //   super.initState();
  //   _pageController = PageController(initialPage: _currentIndex);
  //   _animationController = AnimationController(
  //     duration: const Duration(milliseconds: 300),
  //     vsync: this,
  //   );
  //   _animationController.forward();
  // }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: width * 0.04,
          right: width * 0.04,
          bottom: bottomPadding + height * 0.015,
        ),
        // FIX 1: Use fixed height instead of percentage for consistency
        height: 70, // Fixed height that works on all devices
        decoration: BoxDecoration(
          gradient: AppColor.primaryGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        // FIX 2: Use ClipRRect to prevent overflow
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _navItems.length,
              (index) => _NavBarItem(
                item: _navItems[index],
                isSelected: _currentIndex == index,
                onTap: () => _onTap(index),
                width: width,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Navigation Item Model
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// FIXED Navigation Bar Item Widget
class _NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: 8, // FIX 3: Use fixed padding instead of percentage
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.2) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: Colors.white,
              size: isSelected ? 26 : 24, // FIX 4: Fixed icon size
            ),
            const SizedBox(height: 4), // FIX 5: Fixed spacing
            // Label
            Text(
              item.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSelected ? 12 : 11, // FIX 6: Fixed font size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            // FIX 7: Removed indicator dot to save space
            // Or keep it small:
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}