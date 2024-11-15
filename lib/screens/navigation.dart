import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade300,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        items: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.history,
            label: 'Cuti',
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.qr_code_scanner,
            label: 'Scan Absensi',
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.business,
            label: 'Dinas Luar Kota',
            isActive: currentIndex == 3,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          if (isActive)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              width: 45, // Reduced width for a smaller highlight
              height: 45, // Reduced height for a smaller highlight
            ),
          Icon(
            icon,
            size: isActive ? 26 : 22, // Smaller icon size
            color: isActive ? Colors.white : Colors.grey.shade300,
          ),
        ],
      ),
      label: label,
    );
  }
}
