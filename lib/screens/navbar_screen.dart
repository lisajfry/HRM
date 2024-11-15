import 'package:flutter/material.dart';
import 'package:hrm/screens/home_screen.dart';
import 'package:hrm/screens/izin_screen.dart';
import 'package:hrm/screens/absensi_screen.dart';
import 'package:hrm/screens/dinas_luar_kota_screen.dart';
import 'package:hrm/screens/profile_screen.dart';
import 'package:hrm/screens/navigation.dart'; // Import CustomBottomNavigationBar

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({Key? key}) : super(key: key);

  @override
  _NavbarScreenState createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int _selectedIndex = 0;

  // List of pages corresponding to each navigation item
  final List<Widget> _pages = [
    HomeScreen(),          // Index 0: Home Screen
    IzinScreen(),          // Index 1: Izin Screen
    AbsensiScreen(),       // Index 2: Absensi Screen
    DinasLuarKotaScreen(), // Index 3: Dinas Luar Kota Screen
    ProfileScreen(),       // Index 4: Profile Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Dashboard'),
      ),
      body: _pages[_selectedIndex], // Display the selected page based on index
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
