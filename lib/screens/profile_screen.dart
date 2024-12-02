import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/api/api_service.dart'; // Pastikan jalur ini benar
import 'package:hrm/screens/signin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? karyawanData;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  File? _avatar;
  List<Map<String, dynamic>> jabatanList = [];

  String getJabatanNama(int? jabatanId) {
  if (jabatanId == null || jabatanList.isEmpty) {
    return 'Jabatan tidak tersedia';
  }

  final jabatan = jabatanList.firstWhere(
    (j) => j['id'] == jabatanId,
    orElse: () => {'jabatan': 'Jabatan tidak tersedia'},
  );

  return jabatan['jabatan'];
}

  

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
    _fetchKaryawanData();
  }


  

  Future<void> _loadSavedAvatar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAvatar = prefs.getString('avatar_path');


    

    if (savedAvatar != null) {
      setState(() {
        if (savedAvatar.startsWith('http')) {
          _avatar = null;
          karyawanData = {'avatar': savedAvatar};
        } else {
          _avatar = File(savedAvatar);
        }
      });
    }
  }

  Future<void> _uploadAvatar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) {
      _showMessage('No token found', isError: true);
      return;
    }

    if (_avatar == null) {
      _showMessage('No image selected', isError: true);
      return;
    }

    try {
      final response = await ApiService.postMultipartRequest(
        'profile/upload-avatar',
        _avatar!,
        token,
      );

      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody.body);
        if (responseData['avatar_url'] != null && responseData['avatar_url'] is String) {
          final avatarUrl = responseData['avatar_url'];
          prefs.setString('avatar_path', avatarUrl);

          _showMessage('Avatar uploaded successfully');
          _fetchKaryawanData();
        } else {
          _showMessage('Invalid avatar URL returned by server', isError: true);
        }
      } else {
        _showMessage('Failed to upload avatar: ${responseBody.body}', isError: true);
      }
    } catch (e) {
      _showMessage('Error uploading avatar: $e', isError: true);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('avatar_path', pickedFile.path);
    }
  }

   Future<void> _logout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');

  if (token == null) {
    _showMessage('No token found', isError: true);
    return;
  }

  try {
    // Menggunakan Map<String, dynamic> untuk body
    final body = {'token': token}; // Pastikan body adalah Map<String, dynamic>

    final response = await ApiService.postRequest('logout', {'Authorization': 'Bearer $token'}, body);

    if (response.statusCode == 200) {
      await prefs.remove('access_token'); // Hanya hapus token
      _showMessage('Logged out successfully');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
    } else {
      _showMessage('Failed to log out: ${response.body}', isError: true);
    }
  } catch (e) {
    _showMessage('Error logging out: $e', isError: true);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showUpdateDialog,
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : karyawanData != null
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Section
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _avatar != null
                        ? FileImage(_avatar!)
                        : karyawanData?['avatar'] != null && karyawanData!['avatar'].isNotEmpty
                            ? NetworkImage('${ApiService.baseUrl}storage/${karyawanData!['avatar']}')
                            : const AssetImage('assets/images/profile.png') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20), // Spacing
                // Contact Information Section
                _buildContactInfo(), // Memanggil widget contact info
              ],
            ),
          )
        : const Center(child: Text('Karyawan not found')),

    );
  }

  Widget _buildContactInfo() {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
  children: [
    const Icon(Icons.work, color: Colors.blue), // Icon untuk Jabatan
    const SizedBox(width: 10),
    Expanded(
      child: Text(
        'Jabatan: ${getJabatanNama(karyawanData?['jabatan_id'])}',
        style: const TextStyle(fontSize: 16),
      ),
    ),
  ],
),

          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.assignment_ind, color: Colors.blue), // Icon for NIP
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'NIP: ${karyawanData?['nip'] ?? 'NIP tidak tersedia'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.assignment_ind, color: Colors.blue), // Icon for NIK
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'NIK: ${karyawanData?['nik'] ?? 'NIK tidak tersedia'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue), // Icon for Name
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Name: ${karyawanData?['nama_karyawan'] ?? 'Nama Karyawan tidak tersedia'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.blue), // Icon for Email
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Email: ${karyawanData?['email'] ?? 'Email tidak tersedia'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue), // Icon for Phone
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Phone: ${karyawanData?['no_handphone'] ?? 'No telepon tidak tersedia'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.home, color: Colors.green), // Icon for Address
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Address: ${karyawanData?['alamat'] ?? 'Alamat tidak tersedia'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Future<void> _fetchKaryawanData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');

  if (token == null) {
    _showMessage('Token is missing', isError: true);
    setState(() {
      isLoading = false;
    });
    return;
  }

  try {
    // Header untuk permintaan
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await ApiService.getRequest('profile', headers);
    final jabatanResponse = await ApiService.getRequest('jabatan', headers); // Ambil data jabatan

    if (response.statusCode == 200 && jabatanResponse.statusCode == 200) {
  final profileData = json.decode(response.body)['profile'];
  final jabatanData = json.decode(jabatanResponse.body);

  setState(() {
    karyawanData = profileData;
    jabatanList = List<Map<String, dynamic>>.from(jabatanData); // Gantikan list default
    isLoading = false;
  });

    } else {
      _showMessage('Failed to fetch profile or jabatan data', isError: true);
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    _showMessage('Error fetching data: $e', isError: true);
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> _updateProfile(Map<String, String> updatedData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');
if (token == null) {
  _showMessage('Token is missing', isError: true);
  setState(() {
    isLoading = false;
  });
  return;
}


    try {
      final response = await ApiService.putRequest('profile/update', updatedData, token);

      if (response.statusCode == 200) {
        _showMessage('Profile updated successfully');
        _fetchKaryawanData();
      } else {
        _showMessage('Failed to update profile', isError: true);
      }
    } catch (e) {
      _showMessage('Error updating profile: $e', isError: true);
    }
  }

  Future<void> _showUpdateDialog() async {
    final Map<String, String> updatedData = {
      'nama_karyawan': karyawanData?['nama_karyawan'] ?? '',
      'email': karyawanData?['email'] ?? '',
      'no_handphone': karyawanData?['no_handphone'] ?? '',
      'alamat': karyawanData?['alamat'] ?? '',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => updatedData['nama_karyawan'] = value,
                  controller: TextEditingController(text: updatedData['nama_karyawan']),
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  onChanged: (value) => updatedData['email'] = value,
                  controller: TextEditingController(text: updatedData['email']),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  onChanged: (value) => updatedData['no_handphone'] = value,
                  controller: TextEditingController(text: updatedData['no_handphone']),
                  decoration: const InputDecoration(labelText: 'No Telepon'),
                ),
                TextField(
                  onChanged: (value) => updatedData['alamat'] = value,
                  controller: TextEditingController(text: updatedData['alamat']),
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.pop(context);
                _updateProfile(updatedData);
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}