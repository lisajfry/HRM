import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hrm/screens/absensi_screen.dart'; // Import AbsenScreen
import 'package:hrm/screens/profile_screen.dart'; // Import AbsenScreen


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
         ),
     
      body: SingleChildScrollView(
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
                      _buildLayananItem('Rekap Absensi', Icons.description, context),
                      _buildLayananItem('Kinerja', Icons.task, context),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
             
              SizedBox(
                height: 250,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Material(
          shadowColor: Colors.grey,
          elevation: 8,
          child: BottomNavigationBar(
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: 2, // Default is set to "Scan Absensi"
            onTap: (int index) {
              switch (index) {
                case 2: // Index for "Scan Absensi"
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AbsensiScreen()),
                  );
                  break;
                case 4: // Index for "My Profile"
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                  break;
                default:
                  // Add other navigation logic here if needed
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Transaksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner),
                label: 'Scan Absensi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Task',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'My Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(String title, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLayananItem(String title, IconData icon, BuildContext context) {
  return GestureDetector(
    onTap: () {
      if (title == 'Rekap Absensi') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AbsensiScreen()), // Navigasi ke AbsensiScreen
        );
      }
    },
    child: Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

}
