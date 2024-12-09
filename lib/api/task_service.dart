import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrm/model/task.dart';

class TaskService {
  final String apiUrl = 'http://192.168.200.33:8000/api';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<List<Task>> getTasks() async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/tasks'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Task.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.body}');
    }
  }

  Future<void> addTask(Task task) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'judul_proyek': task.judulProyek,
        'kegiatan': task.kegiatan,
        'tgl_mulai': task.tglMulai,
        'tgl_selesai': task.tglSelesai,
        'batas_penyelesaian': task.batasPenyelesaian,
        'status': task.status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add task: ${json.decode(response.body)['message'] ?? response.body}');
    }
  }

  Future<void> updateTask(Task task) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.put(
      Uri.parse('$apiUrl/tasks/${task.idTugas}'), // Mengganti id menjadi idTugas
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'judul_proyek': task.judulProyek,
        'kegiatan': task.kegiatan,
        'tgl_mulai': task.tglMulai,
        'tgl_selesai': task.tglSelesai,
        'batas_penyelesaian': task.batasPenyelesaian,
        'status': task.status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${json.decode(response.body)['message'] ?? response.body}');
    }
  }

  Future<void> deleteTask(int idTugas) async {  // Mengganti id menjadi idTugas
    String? token = await getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Pastikan Anda sudah login.');
    }

    final response = await http.delete(
      Uri.parse('$apiUrl/tasks/$idTugas'),  // Mengganti id menjadi idTugas
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }
}
