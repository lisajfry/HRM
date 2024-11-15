import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hrm/screens/location_office_screen.dart'; // Update this import
import 'package:hrm/utils/utils.dart';
import 'package:hrm/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';


class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  Map<String, dynamic>? karyawanData;
  bool isLoading = true;
  late DateTime currentDateTime;

  @override
  void initState() {
    super.initState();
    currentDateTime = DateTime.now();
    _fetchKaryawanData();
  }

  Future<void> _fetchKaryawanData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) {
      _showMessage('No token found', isError: true);
      return;
    }

    try {
      final response = await ApiService.getRequest(
        'profile',
        {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          karyawanData = json.decode(response.body)['profile'];
          isLoading = false;
        });
      } else {
        _showMessage('Failed to load user data', isError: true);
      }
    } catch (e) {
      _showMessage('Error loading user data: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Absent'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (karyawanData != null)
                    buildProfileSection(karyawanData!, currentDateTime),
                  SizedBox(height: 20),
                  buildAttendanceSegment(),
                  SizedBox(height: 20),
                  buildActionButtons(context), // Assuming the buttons are here
                  SizedBox(height: 20),
                  buildAttendanceSummary(context),
                ],
              ),
            ),
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationOfficeScreen(), // Update navigation target
              ),
            );
          },
          child: const Text('Clock In'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationOfficeScreen(), // Update navigation target
              ),
            );
          },
          child: const Text('Clock Out'),
        ),
      ],
    );
  }
}
