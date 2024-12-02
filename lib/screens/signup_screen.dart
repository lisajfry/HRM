import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hrm/screens/signin_screen.dart';
import 'package:hrm/theme/theme.dart';
import 'package:hrm/widgets/custom_scaffold.dart';
import 'package:hrm/api/api_service.dart'; // Pastikan jalur impor sesuai dengan struktur project-mu
import 'package:device_info_plus/device_info_plus.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController _namaKaryawanController = TextEditingController();
    final TextEditingController _nipController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHandphoneController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<String?> _getDeviceCode() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.id; // Gunakan androidInfo.id sebagai pengganti androidId
}


void _showAlertDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> _register() async { 
  // Validasi input
  if (_formSignupKey.currentState!.validate() && agreePersonalData) {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Dapatkan device code
      String? deviceCode = await _getDeviceCode();

      // Data yang akan dikirim ke server
      final body = {
        'nama_karyawan': _namaKaryawanController.text,
        'nip': _nipController.text,
        'nik': _nikController.text, 
        'email': _emailController.text,
        'no_handphone': _noHandphoneController.text,
        'alamat': _alamatController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'device_code': deviceCode ?? 'unknown', // Kirim device_code
      };

      // Header untuk permintaan
      final headers = {
        'Content-Type': 'application/json',
      };

      // Panggil API register menggunakan ApiService
      final response = await ApiService.postRequest('register', headers, body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        // Jika registrasi berhasil, tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful'),
          ),
        );

        // Arahkan ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      } else {
        // Menangani error jika registrasi gagal
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String error = responseData['error'] ?? 'Registration failed';

        // Cek jika perangkat sudah terdaftar pada akun lain
        if (error.contains('linked to another device')) {
          _showAlertDialog('Registration Failed', 'This account is already linked to another device.');
        }
        // Cek jika perangkat sudah terdaftar untuk karyawan lain
        else if (error.contains('Perangkat ini sudah terdaftar untuk karyawan lain')) {
          _showAlertDialog('Registration Failed', 'Perangkat ini sudah terdaftar untuk karyawan lain.');
        }
        // Menampilkan error lain
        else {
          _showAlertDialog('Registration Failed', error);
        }
      }
    } catch (e) {
      // Tangani error jika request gagal
      setState(() {
        isLoading = false;
      });
      _showAlertDialog('Error', 'Terjadi kesalahan. Coba lagi nanti.');
    }
  } else if (!agreePersonalData) {
    // Jika pengguna belum setuju dengan pengolahan data pribadi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please agree to the processing of personal data'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;  // Ambil ukuran layar untuk menyesuaikan padding

    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                screenSize.width * 0.05, // padding kiri-kanan dinamis
                50.0, // padding atas
                screenSize.width * 0.05, // padding kiri-kanan dinamis
                20.0, // padding bawah
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      TextFormField(
                        controller: _namaKaryawanController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan Nama Karyawan';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Nama Karyawan'),
                          hintText: 'Nama Karyawan',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _nipController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan No Induk Pegawai';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('No Induk Pegawai'),
                          hintText: 'No Induk Pegawai',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _nikController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan No Induk Kependudukan';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('No Induk Kependudukan'),
                          hintText: 'No Induk Kependudukan',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _noHandphoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan No Handphone';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('No Handphone'),
                          hintText: 'Masukkan No Handphone',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan Alamat';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Alamat'),
                          hintText: 'Masukkan Alamat',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !showPassword,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          icon: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),

                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm Password is required';
                          } else if (value.length < 6) {
                            return 'Confirm Password must be at least 6 characters';
                          } else if (value != _passwordController.text) {
                            return 'Password does not match';
                          }
                          return null; 
                        },
                        decoration: InputDecoration(
                          label: const Text('Confirm Password'),
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                            icon: Icon(
                              showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                          ),
                          const Text(
                            'Saya setuju dengan pemrosesan Data',
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
