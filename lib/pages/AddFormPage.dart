import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/models/saldo.dart';

class AddFormPage extends StatefulWidget {
  const AddFormPage({super.key});

  @override
  _AddFormPageState createState() => _AddFormPageState();
}

class _AddFormPageState extends State<AddFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? jenisTransaksi;
  double? jumlah;
  String? deskripsi;
  DateTime? tanggal;

  Future<void> saveTransaksi(Akun akun) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Mendapatkan saldo terkini
        double saldoTerkini = await getSaldoTerkini();

        // Menghitung saldo baru
        double saldoBaru;
        if (jenisTransaksi == 'Debet') {
          saldoBaru = saldoTerkini + jumlah!; // Debet untuk pemasukan saldo
        } else {
          saldoBaru = saldoTerkini - jumlah!; // Kredit untuk saldo keluar
        }

        // Menyimpan transaksi ke Firestore
        Transaksi transaksi = Transaksi(
          id: '',
          userId: akun.uid,
          jenisTransaksi: jenisTransaksi!,
          jumlah: jumlah!,
          saldoTerkini: saldoBaru,
          label: deskripsi!,
          createdAt: Timestamp.fromDate(tanggal!),
        );

        await _firestore.collection('transaksi').add(transaksi.toFirestore());

        // Memperbarui saldo terkini
        await updateSaldo(saldoBaru);

        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<double> getSaldoTerkini() async {
    DocumentSnapshot<Map<String, dynamic>> saldoDoc =
        await _firestore.collection('saldo_bumdesa').doc('current_saldo').get();

    if (saldoDoc.exists) {
      return Saldo.fromFirestore(saldoDoc).saldo;
    } else {
      // Jika dokumen saldo tidak ada, buat dokumen baru dengan saldo awal 0
      Saldo initialSaldo = Saldo(saldo: 0.0, updatedAt: Timestamp.now());
      await _firestore
          .collection('saldo_bumdesa')
          .doc('current_saldo')
          .set(initialSaldo.toFirestore());
      return initialSaldo.saldo;
    }
  }

  Future<void> updateSaldo(double saldoBaru) async {
    Saldo newSaldo = Saldo(saldo: saldoBaru, updatedAt: Timestamp.now());
    await _firestore
        .collection('saldo_bumdesa')
        .doc('current_saldo')
        .set(newSaldo.toFirestore());
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Tambah Transaksi', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration:
                              InputDecoration(labelText: 'Tipe Transaksi'),
                          items: ['Debet', 'Kredit'].map((e) {
                            return DropdownMenuItem<String>(
                              child: Text(e),
                              value: e,
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => jenisTransaksi = value),
                          validator: (value) => value == null
                              ? 'Tipe transaksi tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Jumlah'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              setState(() => jumlah = double.tryParse(value)),
                          validator: (value) => value!.isEmpty
                              ? 'Jumlah tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Deskripsi'),
                          onChanged: (value) =>
                              setState(() => deskripsi = value),
                          validator: (value) => value!.isEmpty
                              ? 'Deskripsi tidak boleh kosong'
                              : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Tanggal'),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: tanggal ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() => tanggal = pickedDate);
                            }
                          },
                          readOnly: true,
                          controller: TextEditingController(
                              text: tanggal != null
                                  ? tanggal!.toLocal().toString().split(' ')[0]
                                  : ''),
                          validator: (value) => value!.isEmpty
                              ? 'Tanggal tidak boleh kosong'
                              : null,
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: buttonStyle,
                            onPressed: () => saveTransaksi(akun),
                            child: Text('Simpan',
                                style: headerStyle(level: 3, dark: false)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
