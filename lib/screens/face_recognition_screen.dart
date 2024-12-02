import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/model/absen.dart';
import 'package:hrm/api/absensi_service.dart';
import 'package:hrm/utils/utils.dart';
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
  LatLng _officeLocation = LatLng(-7.63682815361972, 111.54260480768411); // Lokasi kantor
  double _radius = 400.0; // Radius dalam meter
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
        print('Current Position: $_currentPosition');
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






// Update the 'handleAbsenMasuk' function
Future<void> handleAbsenMasuk() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');
  
  print('Token: $token'); // Debug Token

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token tidak ditemukan. Silakan login kembali.'))
    );
    return;
  }

  

  // Waktu sekarang
  final DateTime now = DateTime.now();
  final String formattedTime = DateFormat('HH:mm:ss').format(now);
  final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  print('Waktu sekarang: $formattedTime | Tanggal: $formattedDate'); // Debug Waktu

  // Lokasi pengguna
  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    print('Lokasi saat ini: ${position.latitude}, ${position.longitude}'); // Debug Lokasi
  } catch (e) {
    print('Gagal mendapatkan lokasi: $e');
  }

  // Validasi jarak
  double distance = Geolocator.distanceBetween(
    position!.latitude,
    position.longitude,
    _officeLocation.latitude,
    _officeLocation.longitude,
  );
  print('Jarak ke kantor: $distance meter'); // Debug Jarak

  if (distance > _radius) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anda berada di luar jangkauan kantor. Absensi gagal.'))
    );
    return;
  }

  // Tentukan data untuk dikirim ke AbsensiService
  final Map<String, dynamic> absensiData = {
    'tanggal': formattedDate,
    'jam_masuk': formattedTime,
    'foto_masuk': await getFileAsBase64(widget.pickedImage?.path),
    'lokasi_masuk': {
      'latitude': position.latitude,
      'longitude': position.longitude,
    },
  };

  print('Absensi Data: $absensiData'); // Debug Data

  // Panggil AbsensiService untuk absen masuk
  try {
    final absensiService = AbsensiService();
    // Panggil absensiService.absenMasuk dengan data absensi
    Absensi absensi = await absensiService.absenMasuk(absensiData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Absensi berhasil dicatat: ${absensi.tanggal}')),
    );
     _showData(context, {
      'Tanggal': absensi.tanggal,
      'Jam Masuk': absensi.jamMasuk,
    });
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mencatat absensi')),
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
  widget.action == 'Clock In' ? 'Jam Masuk: ${widget.time}' : '',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleAbsenMasuk(),
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
