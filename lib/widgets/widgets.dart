import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hrm/screens/face_recognition_screen.dart'; // Pastikan jalur ini benar
import 'package:hrm/utils/utils.dart'; // Pastikan jalur ini benar
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 


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
              String currentTime = DateFormat('HH:mm').format(DateTime.now()); // Get the current time
              String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Get the current date

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceRecognitionScreen(
                    action: 'Clock In', // For Clock In button
                    pickedImage: pickedFile,
                    time: currentTime,  // Pass the current time
                    date: currentDate,  // Pass the current date
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
      Expanded(
        child: ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.camera);
            if (pickedFile != null) {
              String currentTime = DateFormat('HH:mm').format(DateTime.now()); // Get the current time
              String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Get the current date

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceRecognitionScreen(
                    action: 'Clock Out', // For Clock Out button
                    pickedImage: pickedFile,
                    time: currentTime,  // Pass the current time
                    date: currentDate,  // Pass the current date
                  ),
                ),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_left),
              Text('Clock Out'),
            ],
          ),
        ),
      ),
    ],
  );
}

  
  Widget buildAttendanceSummary() {
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
          _buildInfoCard('Total Hadir', '20', Icons.check_circle_outline, Colors.blue),
          _buildInfoCard('Total Izin', '2', Icons.description_outlined, Colors.blue),
          _buildInfoCard('Total Sakit', '1', Icons.sick_outlined, Colors.blue),
          _buildInfoCard('Total Alfa', '0', Icons.remove_circle_outline, Colors.blue),
        ],
      ),
    ),
  );
}

Widget _buildInfoCard(String title, String count, IconData icon, Color iconColor) {
  return GestureDetector(
    onTap: () {
      // Aksi ketika card di-tap
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



