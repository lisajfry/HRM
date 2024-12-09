import 'package:flutter/material.dart';
import 'package:hrm/api/task_service.dart';
import 'package:hrm/model/task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;

  TaskForm({this.task});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulProyekController;
  late TextEditingController _kegiatanController;
  late TextEditingController _tglMulaiController;
  late TextEditingController _tglSelesaiController;
  late TextEditingController _batasPenyelesaianController;
  String? status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulProyekController = TextEditingController(text: widget.task?.judulProyek ?? '');
    _kegiatanController = TextEditingController(text: widget.task?.kegiatan ?? '');
    _tglMulaiController = TextEditingController(text: widget.task?.tglMulai ?? '');
    _tglSelesaiController = TextEditingController(text: widget.task?.tglSelesai ?? '');
    _batasPenyelesaianController = TextEditingController(text: widget.task?.batasPenyelesaian ?? '');
    status = widget.task?.status ?? 'belum dimulai';
  }

  @override
  void dispose() {
    _judulProyekController.dispose();
    _kegiatanController.dispose();
    _tglMulaiController.dispose();
    _tglSelesaiController.dispose();
    _batasPenyelesaianController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        controller.text = formattedDate;
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (DateTime.parse(_tglSelesaiController.text).isBefore(DateTime.parse(_tglMulaiController.text))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tanggal selesai tidak boleh lebih awal dari tanggal mulai')),
        );
        return;
      }

      final task = Task(
        idTugas: widget.task?.idTugas ?? 0,
        judulProyek: _judulProyekController.text,
        kegiatan: _kegiatanController.text,
        tglMulai: _tglMulaiController.text,
        tglSelesai: _tglSelesaiController.text,
        batasPenyelesaian: _batasPenyelesaianController.text,
        status: status!,
      );

      setState(() {
        _isLoading = true;
      });

      try {
        if (widget.task == null) {
          await TaskService().addTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tugas berhasil ditambahkan')),
          );
        } else {
          await TaskService().updateTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tugas berhasil diperbarui')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Tambah Tugas' : 'Edit Tugas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulProyekController,
                decoration: InputDecoration(labelText: 'Judul Proyek'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul proyek tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _kegiatanController,
                decoration: InputDecoration(labelText: 'Kegiatan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kegiatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tglMulaiController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Mulai',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _tglMulaiController),
                  ),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _tglSelesaiController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Selesai',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _tglSelesaiController),
                  ),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: _batasPenyelesaianController,
                decoration: InputDecoration(labelText: 'Batas Penyelesaian'),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status'),
                value: status,
                items: ['belum dimulai', 'dalam progres', 'selesai'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    status = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Status tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : submitForm,
                child: _isLoading ? CircularProgressIndicator() : Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
