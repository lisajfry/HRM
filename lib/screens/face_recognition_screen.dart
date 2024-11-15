import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final String action;
  final XFile? pickedImage;
  final String time;
  final String date;

  const FaceRecognitionScreen({
    Key? key,
    required this.action,
    required this.pickedImage,
    required this.time,
    required this.date,
  }) : super(key: key);

  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(-6.200000, 106.816666); // Jakarta sebagai default
  LatLng? _currentPosition;
  LatLng _officeLocation = LatLng(-7.635828594663169, 111.54255116931424); // Lokasi kantor
  double _radius = 100.0; // Radius dalam meter
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Jangan lupa untuk menghentikan stream saat widget dihapus
    super.dispose();
  }

  // Memeriksa izin lokasi
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  // Mulai melacak perubahan lokasi
  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best, // Menggunakan akurasi terbaik
        distanceFilter: 10, // Update jika ada perubahan jarak lebih dari 10 meter
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _initialPosition = _currentPosition!;
        // Pindahkan kamera ke lokasi terbaru
        mapController.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _submitAttendance(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');
  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token tidak ditemukan. Silakan login kembali.')),
    );
    return;
  }

  final profileResponse = await ApiService.getRequest(
    'profile',
    {'Authorization': 'Bearer $token'},
  );

  if (profileResponse.statusCode == 200) {
    final karyawanData = json.decode(profileResponse.body)['profile'];
    final String idKaryawan = karyawanData['id'].toString();
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(now);
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      print('Failed to get location: $e');
    }

    // Validasi jarak user dengan kantor
    double distance = Geolocator.distanceBetween(
      position!.latitude,
      position.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );

    if (distance > _radius) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda berada di luar jangkauan kantor. Absensi gagal.')),
      );
      return; // Gagal absen
    }

    // Jika dalam radius, lanjutkan proses absensi
    double? latitude = position.latitude;
    double? longitude = position.longitude;

    final endpoint = widget.action == 'Clock In' ? 'absensi/masuk' : 'absensi/keluar';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Mengirimkan waktu yang sesuai untuk Clock In atau Clock Out
    final body = {
      'id_karyawan': idKaryawan,
      'tanggal': formattedDate,
      if (widget.action == 'Clock In') 'jam_masuk': formattedTime,
      if (widget.action == 'Clock Out') 'jam_keluar': formattedTime,
      if (widget.action == 'Clock In') 'foto_masuk': await getFileAsBase64(widget.pickedImage?.path),
      if (widget.action == 'Clock Out') 'foto_keluar': await getFileAsBase64(widget.pickedImage?.path),
      if (widget.action == 'Clock In') 'latitude_masuk': latitude,
      if (widget.action == 'Clock In') 'longitude_masuk': longitude,
      if (widget.action == 'Clock Out') 'latitude_keluar': latitude,
      if (widget.action == 'Clock Out') 'longitude_keluar': longitude,
    };

    final attendanceResponse = await ApiService.postRequest(endpoint, headers, body);

    if (attendanceResponse.statusCode == 201 || attendanceResponse.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absensi berhasil dicatat')),
      );
      _showData(context, body);
    } else {
      print('Response body: ${attendanceResponse.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencatat absensi')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat data karyawan')),
    );
  }
}

  Future<String?> getFileAsBase64(String? filePath) async {
    if (filePath == null) return null;
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  void _showData(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Data Absensi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: data.entries.map((entry) {
                return Text('${entry.key}: ${entry.value != null ? entry.value : 'null'}');
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Catat Kehadiran'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Pindahkan Google Map ke atas gambar
            _buildGoogleMap(),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.pickedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(widget.pickedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(child: Text('Face Recognition Placeholder')),
            ),
            SizedBox(height: 20),
            Text(
              widget.action == 'Clock In'
                  ? 'Jam Masuk: ${widget.time}'
                  : 'Jam Keluar: ${widget.time}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitAttendance(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              ),
              child: Text(widget.action, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildGoogleMap() {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15,
        ),
        markers: _currentPosition != null
            ? {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: _currentPosition!,  // Lokasi user
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),  // Warna biru untuk lokasi user
                  infoWindow: InfoWindow(title: 'Lokasi Anda'),
                ),
                Marker(
                  markerId: MarkerId('officeLocation'),
                  position: _officeLocation,  // Lokasi kantor
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),  // Warna merah untuk kantor
                  infoWindow: InfoWindow(title: 'Kantor'),
                ),
              }
            : {},
        circles: {
          Circle(
            circleId: CircleId("radius"),
            center: _officeLocation,  // Lokasi kantor
            radius: _radius,  // Radius dalam meter
            fillColor: Colors.blueAccent.withOpacity(0.5),  // Warna lingkaran
            strokeColor: Colors.blueAccent,  // Warna garis lingkaran
            strokeWidth: 2,  // Ketebalan garis lingkaran
          ),
        },
      ),
    );
  }
}
