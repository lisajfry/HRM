import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';



class AbsenScreen extends StatefulWidget {
  @override
  _AbsenScreenState createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  String? _jamMasuk;
  String? _jamKeluar;
  File? _image;
  File? _submittedImage;
  String? _location;
  bool _absenMasukDone = false;
  bool _isLoading = false; // Untuk indikator loading
  final ImagePicker _picker = ImagePicker();

  final String baseUrl = "http://192.168.200.51:8000/api/riwayat-absensi?id_user"; // Sesuaikan URL
  

  // Fungsi untuk mendapatkan waktu saat ini
  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute}:${now.second}";
  }

  // Fungsi untuk mengubah string lokasi menjadi LatLng
  LatLng _getLatLngFromString(String locationString) {
    var latLng = locationString.split(',');
    return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
  }

  // Fungsi untuk meminta izin kamera
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  // Fungsi untuk mengambil gambar
  Future<void> _pickImage() async {
    await _requestCameraPermission();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mendapatkan lokasi
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Layanan lokasi tidak aktif.")));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Izin lokasi ditolak permanen.")));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "${position.latitude},${position.longitude}";
    });
  }

  // Fungsi untuk mengirim data absen masuk
  Future<void> _submitAbsenMasuk() async {
    if (_location == null || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pastikan Anda telah mengambil lokasi dan foto.")));
      return;
    }

    List<String> latLng = _location!.split(',');
    double latitude = double.parse(latLng[0]);
    double longitude = double.parse(latLng[1]);

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/masuk'));
    request.fields['id_user'] = '1'; // Ganti dengan ID user yang sesuai
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    var mimeType = lookupMimeType(_image!.path)!.split('/');
    request.files.add(await http.MultipartFile.fromPath(
      'foto_masuk',
      _image!.path,
      contentType: MediaType(mimeType[0], mimeType[1]),
    ));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
        setState(() {
          _jamMasuk = jsonResponse['data']['jam_masuk'];
          _absenMasukDone = true;
          _submittedImage = _image;
          _image = null;
        });
      } else {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  // Fungsi untuk mengirim data absen keluar
  Future<void> _submitAbsenKeluar() async {
    if (_location == null || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pastikan Anda telah mengambil lokasi dan foto.")));
      return;
    }

    List<String> latLng = _location!.split(',');
    double latitude = double.parse(latLng[0]);
    double longitude = double.parse(latLng[1]);

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/keluar'));
    request.fields['id_user'] = '1'; // Ganti dengan ID user yang sesuai
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    var mimeType = lookupMimeType(_image!.path)!.split('/');
    request.files.add(await http.MultipartFile.fromPath(
      'foto_keluar',
      _image!.path,
      contentType: MediaType(mimeType[0], mimeType[1]),
    ));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
        setState(() {
          _jamKeluar = jsonResponse['data']['jam_keluar'];
          _image = null;
        });
      } else {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  // Fungsi untuk melakukan absen masuk
  Future<void> _absenMasukAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    await _getLocation();
    await _pickImage();

    if (_location != null && _image != null) {
      await _submitAbsenMasuk();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Fungsi untuk melakukan absen keluar
  Future<void> _absenKeluarAndSubmit() async {
    setState(() {
      _isLoading = true;
    });

    await _getLocation();
    await _pickImage();

    if (_location != null && _image != null) {
      await _submitAbsenKeluar();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Absen Kehadiran"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Absen Masuk",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _absenMasukDone
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Jam Masuk: $_jamMasuk"),
                            const SizedBox(height: 10),
                            _submittedImage != null
                                ? Image.file(
                                    _submittedImage!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Text("Foto belum diambil."),
                            const SizedBox(height: 10),
                            _location != null
                                ? Column(
                                    children: [
                                      Text("Lokasi: $_location"),
                                      SizedBox(
                                        height: 300,
                                        child: FlutterMap(
  options: MapOptions(
    initialCenter: _getLatLngFromString(_location!), // Use initialCenter
    initialZoom: 15.0,
  ),
  children: [
    TileLayer(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c'],
    ),
    MarkerLayer(
      markers: [
        Marker(
          point: _getLatLngFromString(_location!),
          width: 80.0,
          height: 80.0,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      ],
    ),
  ],
),


                                      ),
                                    ],
                                  )
                                : Text("Lokasi belum diambil."),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _absenMasukAndSubmit,
                          child: Text("Absen Masuk"),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _absenKeluarAndSubmit,
                    child: Text("Absen Keluar"),
                  ),
                ],
              ),
            ),
    );
  }
}
