import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hrm/screens/face_recognition_screen.dart'; 
import 'package:hrm/utils/utils.dart'; 
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:hrm/screens/lembur_screen.dart'; 
import 'package:hrm/model/TotalLembur.dart'; 
import 'package:provider/provider.dart';


// Fungsi untuk membangun bagian profil
Widget buildProfileSection(Map<String, dynamic> karyawanData, DateTime currentDateTime) {
  return Row(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundImage: karyawanData['avatar'] != null && karyawanData['avatar'].isNotEmpty
            ? NetworkImage(karyawanData['avatar'])
            : AssetImage('assets/profile.jpg') as ImageProvider,
      ),
      SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(karyawanData['nama_karyawan'] ?? 'Nama tidak tersedia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(getFormattedDateTime(currentDateTime)),
          ],
        ),
      ),
    ],
  );
}

// Fungsi untuk membangun segmentasi absensi
Widget buildAttendanceSegment() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Expanded(
        child: Column(
          children: [
            Text('Absen Masuk'),
          ],
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text('Absen Keluar'),
          ],
        ),
      ),
    ],
  );
}

// Fungsi untuk membangun tombol aksi
Widget buildActionButtons(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.camera);
            if (pickedFile != null) {
              String currentTime = DateFormat('HH:mm').format(DateTime.now());
              String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceRecognitionScreen(
                    action: 'Clock In',
                    time: currentTime,
                    date: currentDate,
                  ),
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Clock In'),
              Icon(Icons.arrow_right),
            ],
          ),
        ),
      ),
      SizedBox(width: 10),
        ],
  );
}
  /*Widget buildAttendanceSummary(BuildContext context) {
  final totalLembur = Provider.of<TotalLemburProvider>(context).totalLembur; // Mengambil total lembur dari provider
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard('Total Hadir', '20', Icons.check_circle_outline, Colors.blue, context),
          _buildInfoCard('Total Izin', '2', Icons.description_outlined, Colors.blue, context),
          _buildInfoCard('Total Lembur', totalLembur.toString(), Icons.access_time, Colors.blue, context), // Gunakan total lembur dari provider
          _buildInfoCard('Total Alfa', '0', Icons.remove_circle_outline, Colors.blue, context),
        ],
      ),
    ),
  );
}
*/

// Fungsi untuk membangun kartu informasi
Widget _buildInfoCard(String title, String count, IconData icon, Color iconColor, BuildContext context) {
  return GestureDetector(
    onTap: () {
      if (title == 'Total Lembur') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LemburScreen()), // Navigasi ke LemburScreen
        );
      }
    },
    child: Column(
      children: [
        Icon(icon, size: 30, color: iconColor),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
