import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:hrm/api/absensi_service.dart'; // Sesuaikan dengan path yang sesuai


class FaceRecognitionScreen extends StatefulWidget {
  final String action;
  final String time;
  final String date;

  const FaceRecognitionScreen({
    Key? key,
    required this.action,
    required this.time,
    required this.date,
  }) : super(key: key);

  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(-6.200000, 106.816666);
  LatLng? _currentPosition;
  LatLng _officeLocation = LatLng(-7.63680688625805, 111.54267990949353);
  double _radius = 400.0;
  StreamSubscription<Position>? _positionStream;

  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startLocationUpdates();
    _initializeCamera();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _cameraController.dispose();
    super.dispose();
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
              return Text('${entry.key}: ${entry.value}');
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


  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _initialPosition = _currentPosition!;
        mapController.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;
      final XFile photo = await _cameraController.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto berhasil diambil')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto')),
      );
    }
  }

  Future<void> handleAbsenMasuk() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token tidak ditemukan. Silakan login kembali.'))
    );
    return;
  }

  final DateTime now = DateTime.now();
  final String formattedTime = DateFormat('HH:mm:ss').format(now);
  final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
    );
    return;
  }

  double distance = Geolocator.distanceBetween(
    position.latitude,
    position.longitude,
    _officeLocation.latitude,
    _officeLocation.longitude,
  );

  if (distance > _radius) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anda berada di luar jangkauan kantor. Absensi gagal.')),
    );
    return;
  }

  if (_capturedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto tidak tersedia. Ambil foto terlebih dahulu.')),
    );
    return;
  }

  final Map<String, dynamic> absensiData = {
  'tanggal': formattedDate,
  'jam_masuk': formattedTime,
  'foto_masuk': await getFileAsBase64(_capturedImage?.path),
  'latitude_masuk': position.latitude, // Tambahkan latitude
  'longitude_masuk': position.longitude, // Tambahkan longitude
  
};


  try {
    final absensiService = AbsensiService();
    final absensi = await absensiService.absenMasuk(absensiData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Absensi berhasil dicatat: ${absensi.tanggal}')),
    );
    _showData(context, {
  'Tanggal': absensi.tanggal,
  'Jam Masuk': absensi.jamMasuk,
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mencatat absensi: $e')),
    );
  }
}

  Future<String?> getFileAsBase64(String? filePath) async {
    if (filePath == null) return null;
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Catat Kehadiran'),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          _buildGoogleMap(),
          SizedBox(height: 20),
          _buildCameraPreview(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _capturePhoto(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: Colors.orangeAccent,
                ),
                child: Text('Ambil Foto'),
              ),
              ElevatedButton(
                onPressed: () => handleAbsenMasuk(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(widget.action),
              ),
            ],
          ),
        ],
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
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: InfoWindow(title: 'Lokasi Anda'),
                ),
                Marker(
                  markerId: MarkerId('officeLocation'),
                  position: _officeLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(title: 'Kantor'),
                ),
              }
            : {},
        circles: {
          Circle(
            circleId: CircleId("radius"),
            center: _officeLocation,
            radius: _radius,
            fillColor: Colors.blueAccent.withOpacity(0.5),
            strokeColor: Colors.blueAccent,
            strokeWidth: 2,
          ),
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: _capturedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
              ),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
