import 'package:flutter/material.dart';
import 'package:hrm/api/task_service.dart';
import 'package:hrm/model/task.dart';
import 'package:hrm/screens/add_task_screen.dart'; // Halaman untuk tambah atau edit tugas

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();
  late Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    try {
      return await _taskService.getTasks();
    } catch (e) {
      throw Exception('Gagal memuat data tugas: $e');
    }
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      setState(() {
        futureTasks = _fetchTasks(); // Refresh data setelah penghapusan
      });
    } catch (e) {
      print('Gagal menghapus tugas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tugas'),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada tugas tersedia.'));
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final task = snapshot.data![index];
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.judulProyek,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${task.tglMulai} - ${task.batasPenyelesaian}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TaskForm(task: task)),
                                  ).then((_) {
                                    setState(() {
                                      futureTasks = _fetchTasks();
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteTask(task.idTugas);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Kegiatan: ${task.kegiatan}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Status: ${task.status}',
                        style: TextStyle(
                          fontSize: 14,
                          color: task.status == 'selesai' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskForm()),
          ).then((_) {
            setState(() {
              futureTasks = _fetchTasks();
            });
          });
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Tugas',
      ),
    );
  }
}
