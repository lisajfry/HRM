import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:hrm/screens/face_recognition_screen.dart'; // Pastikan path import ini benar
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocationOfficeScreen extends StatefulWidget {
  @override
  _LocationOfficeScreenState createState() => _LocationOfficeScreenState();
}

class _LocationOfficeScreenState extends State<LocationOfficeScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final LatLng _officeLocation = LatLng(-7.63682815361972, 111.54260480768411); // Lokasi kantor
  bool _isWithinOfficeRange = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _isWithinOfficeRange = _checkIfWithinRange();
    });
  }

  bool _checkIfWithinRange() {
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );
    return distanceInMeters <= 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Kehadiran'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _officeLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('office'),
                      position: _officeLocation,
                      infoWindow: InfoWindow(title: 'Kantor Cabang A'),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    color: Colors.white.withOpacity(0.8),
                    child: Text(
                      'Lokasi Kantor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Kirim Kehadiran',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

 void _submitAttendance() async {
  // Mendapatkan SharedPreferences untuk menyimpan status kehadiran
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasClockedIn = prefs.getBool('hasClockedIn') ?? false;

  // Menentukan apakah ini Clock In atau Clock Out
  final String action = hasClockedIn ? 'Clock Out' : 'Clock In';
  final String time = DateFormat('HH:mm').format(DateTime.now());
  final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final ImagePicker picker = ImagePicker();
  final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

  if (pickedImage != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceRecognitionScreen(
          action: action,
          pickedImage: pickedImage,
          time: time,
          date: date,
        ),
      ),
    );

    // Simpan status Clock In atau Clock Out
    prefs.setBool('hasClockedIn', !hasClockedIn);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Silakan ambil foto untuk face recognition.')),
    );
  }
}
}
