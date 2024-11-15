import 'package:flutter/material.dart';
import 'package:hrm/api/payroll_service.dart';
import 'home_screen.dart'; // Import halaman HomeScreen

class PayrollScreen extends StatefulWidget {
  @override
  _PayrollScreenState createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  Map<String, dynamic>? payrollData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayrollData();
  }

  void fetchPayrollData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await PayrollService().fetchPayrollSummary();
      setState(() {
        payrollData = data;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigasi ke HomeScreen saat tombol back ditekan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Ganti dengan HomeScreen Anda
        );
        return false; // Jangan biarkan halaman ini pop
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Menggunakan Navigator.pushReplacement untuk kembali ke HomeScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()), // Ganti dengan HomeScreen Anda
              );
            },
          ),
          title: Text('Payroll Summary'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : payrollData == null
                ? Center(child: Text('Tidak ada data'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assessment, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Payroll Summary',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2)),
                            dataRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.grey.shade50),
                            columns: [
                              DataColumn(
                                  label: Text(
                                'Kategori',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                'Jumlah',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              )),
                            ],
                            rows: [
                              DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      Icon(Icons.event, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Izin'),
                                    ],
                                  )),
                                  DataCell(Text(
                                    payrollData!['izin_count'].toString(),
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      Icon(Icons.location_city,
                                          color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Dinas Luar Kota'),
                                    ],
                                  )),
                                  DataCell(Text(
                                    payrollData!['dinas_luar_kota_count']
                                        .toString(),
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      Icon(Icons.beach_access,
                                          color: Colors.purple),
                                      SizedBox(width: 8),
                                      Text('Cuti'),
                                    ],
                                  )),
                                  DataCell(Text(
                                    payrollData!['cuti_count'].toString(),
                                    style: TextStyle(
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Kehadiran'),
                                    ],
                                  )),
                                  DataCell(Text(
                                    payrollData!['kehadiran_count'].toString(),
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      Icon(Icons.timer,
                                          color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Lembur (jam)'),
                                    ],
                                  )),
                                  DataCell(Text(
                                    payrollData!['lembur_count'].toString(),
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
