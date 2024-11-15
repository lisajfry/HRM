import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hrm/screens/absensi_screen.dart';
import 'package:hrm/screens/profile_screen.dart';
import 'package:hrm/screens/izin_screen.dart';
import 'package:hrm/screens/rekap_absensi.dart';
import 'package:hrm/screens/dinas_luar_kota_screen.dart';
import 'package:hrm/screens/payroll_screen.dart';
import 'package:hrm/screens/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Set default to "Home"

  final List<Widget> _screens = [
    HomeScreenContent(),
    IzinScreen(),
    AbsensiScreen(),
    DinasLuarKotaScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget terpisah untuk konten dashboard
class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(  // Membuat body menjadi scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                items: [
                  Image.asset('assets/images/example1.png', fit: BoxFit.cover),
                  Image.asset('assets/images/example2.png', fit: BoxFit.cover),
                  Image.asset('assets/images/example3.png', fit: BoxFit.cover),
                ],
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLayananItem('Absensi', Icons.qr_code, context),
                      _buildLayananItem('Payroll', Icons.attach_money, context),
                      _buildLayananItem('Riwayat Absensi', Icons.description, context),
                      _buildLayananItem('Kinerja', Icons.task, context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,  // Pastikan grafik tetap sesuai ukuran
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 5, color: Colors.blue),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 3, color: Colors.green),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 4, color: Colors.red),
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(toY: 2, color: Colors.orange),
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(toY: 6, color: Colors.purple),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayananItem(String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Absensi') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AbsensiScreen()),
          );
        } else if (title == 'Payroll') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PayrollScreen()),
          );
        } else if (title == 'Riwayat Absensi') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RekapAbsensiScreen()),
          );
        } else if (title == 'Dinas Luar Kota') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DinasLuarKotaScreen()),
          );
        }
      },
      child: Column(
        children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
