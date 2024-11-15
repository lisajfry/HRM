import 'package:flutter/material.dart';
import 'package:hrm/model/dinasluarkota.dart';
import 'package:hrm/api/dinasluarkota_service.dart';

class DinasLuarKotaForm extends StatefulWidget {
  final DinasLuarKota? dinas;

  DinasLuarKotaForm({this.dinas});

  @override
  _DinasLuarKotaFormState createState() => _DinasLuarKotaFormState();
}

class _DinasLuarKotaFormState extends State<DinasLuarKotaForm> {
  final _formKey = GlobalKey<FormState>();

  late int idKaryawan;
  late DateTime tglBerangkat;
  late DateTime tglKembali;
  late String kotaTujuan;
  late String keperluan;
  late double biayaTransport;
  late double biayaPenginapan;
  late double uangHarian;

  @override
  void initState() {
    super.initState();
    if (widget.dinas != null) {
      idKaryawan = widget.dinas!.idKaryawan;
      tglBerangkat = widget.dinas!.tglBerangkat;
      tglKembali = widget.dinas!.tglKembali;
      kotaTujuan = widget.dinas!.kotaTujuan;
      keperluan = widget.dinas!.keperluan;
      biayaTransport = widget.dinas!.biayaTransport;
      biayaPenginapan = widget.dinas!.biayaPenginapan;
      uangHarian = widget.dinas!.uangHarian;
    } else {
      idKaryawan = 0; // Atur ke idKaryawan login
      tglBerangkat = DateTime.now();
      tglKembali = DateTime.now();
      kotaTujuan = '';
      keperluan = '';
      biayaTransport = 0.0;
      biayaPenginapan = 0.0;
      uangHarian = 0.0;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isDeparture ? tglBerangkat : tglKembali,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isDeparture) {
          tglBerangkat = pickedDate;
        } else {
          tglKembali = pickedDate;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DinasLuarKota dinas = DinasLuarKota(
        id: widget.dinas?.id ?? 0,
        idKaryawan: idKaryawan,
        tglBerangkat: tglBerangkat,
        tglKembali: tglKembali,
        kotaTujuan: kotaTujuan,
        keperluan: keperluan,
        biayaTransport: biayaTransport,
        biayaPenginapan: biayaPenginapan,
        uangHarian: uangHarian,
        totalBiaya: (biayaTransport + biayaPenginapan + uangHarian),
      );

      try {
        if (widget.dinas == null) {
          await DinasLuarKotaService().addDinasLuarKota(dinas);
        } else {
          await DinasLuarKotaService().updateDinasLuarKota(dinas);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah data dinas luar kota: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dinas == null ? 'Tambah Dinas Luar Kota' : 'Edit Dinas Luar Kota'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Tanggal Berangkat'),
                    controller: TextEditingController(
                      text: "${tglBerangkat.year}-${tglBerangkat.month.toString().padLeft(2, '0')}-${tglBerangkat.day.toString().padLeft(2, '0')}",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal berangkat wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Tanggal Kembali'),
                    controller: TextEditingController(
                      text: "${tglKembali.year}-${tglKembali.month.toString().padLeft(2, '0')}-${tglKembali.day.toString().padLeft(2, '0')}",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal kembali wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              TextFormField(
                initialValue: widget.dinas?.kotaTujuan ?? '',
                decoration: InputDecoration(labelText: 'Kota Tujuan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kota tujuan wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  kotaTujuan = value!;
                },
              ),
              TextFormField(
                initialValue: widget.dinas?.keperluan ?? '',
                decoration: InputDecoration(labelText: 'Keperluan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Keperluan wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  keperluan = value!;
                },
              ),
              TextFormField(
                initialValue: widget.dinas?.biayaTransport.toString() ?? '',
                decoration: InputDecoration(labelText: 'Biaya Transport'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Biaya transport wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  biayaTransport = double.parse(value!);
                },
              ),
              TextFormField(
                initialValue: widget.dinas?.biayaPenginapan.toString() ?? '',
                decoration: InputDecoration(labelText: 'Biaya Penginapan'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Biaya penginapan wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  biayaPenginapan = double.parse(value!);
                },
              ),
              TextFormField(
                initialValue: widget.dinas?.uangHarian.toString() ?? '',
                decoration: InputDecoration(labelText: 'Uang Harian'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Uang harian wajib diisi';
                  }
                  return null;
                },
                onSaved: (value) {
                  uangHarian = double.parse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.dinas == null ? 'Tambah' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
