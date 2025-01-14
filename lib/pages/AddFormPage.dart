import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/models/saldo.dart';
import 'package:intl/intl.dart';

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
  DateTime? tanggal = DateTime.now();

  Future<void> saveTransaksi(Akun akun) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          throw Exception('User not found');
        }
        String userName = userDoc.data()!['nama'];

        double saldoTerkini = await getSaldoTerkini();

        double saldoBaru;
        if (jenisTransaksi == 'Debet') {
          saldoBaru = saldoTerkini + jumlah!;
        } else {
          saldoBaru = saldoTerkini - jumlah!;
        }

        // Menyimpan transaksi ke Firestore
        Transaksi transaksi = Transaksi(
          id: '',
          createdBy: userName,
          jenisTransaksi: jenisTransaksi!,
          jumlah: jumlah!,
          saldoTerkini: saldoBaru,
          label: deskripsi!,
          createdAt: Timestamp.fromDate(tanggal!),
        );

        await _firestore.collection('transaksi').add(transaksi.toFirestore());

        await updateSaldo(saldoBaru);

        Navigator.pop(context, transaksi);
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
      Saldo initialSaldo = Saldo(saldo: 0.0, updatedAt: Timestamp.now());
      await _firestore
          .collection('saldo_bumdesa')
          .doc('current_saldo')
          .set(initialSaldo.toFirestore());
      return initialSaldo.saldo;
    }
  }

  String formatRupiah(double value) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(value);
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            Text('Tambah Transaksi', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
        backgroundColor: primaryColor,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            tanggal != null
                                ? DateFormat('dd MMM yyyy, HH:mm')
                                    .format(tanggal!)
                                : '',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Jumlah'),
                                keyboardType: TextInputType.number,
                                initialValue: jumlah?.toString(),
                                onChanged: (value) => setState(
                                    () => jumlah = double.tryParse(value)),
                                validator: (value) => value!.isEmpty
                                    ? 'Jumlah tidak boleh kosong'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              jumlah != null ? formatRupiah(jumlah!) : '',
                              style: TextStyle(
                                fontSize: 16,
                                color: jenisTransaksi == 'Debet'
                                    ? primaryColor
                                    : dangerColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Deskripsi'),
                          onChanged: (value) =>
                              setState(() => deskripsi = value),
                          validator: (value) => value!.isEmpty
                              ? 'Deskripsi tidak boleh kosong'
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
