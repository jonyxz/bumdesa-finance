import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:intl/intl.dart';

class UpdateFormPage extends StatefulWidget {
  final Transaksi transaksi;

  const UpdateFormPage({super.key, required this.transaksi});

  @override
  _UpdateFormPageState createState() => _UpdateFormPageState();
}

class _UpdateFormPageState extends State<UpdateFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? jenisTransaksi;
  double? jumlah;
  String? deskripsi;
  DateTime? tanggal;

  @override
  void initState() {
    super.initState();
    jenisTransaksi = widget.transaksi.jenisTransaksi;
    jumlah = widget.transaksi.jumlah;
    deskripsi = widget.transaksi.label;
    tanggal = widget.transaksi.createdAt.toDate();
  }

  String formatRupiah(double value) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(value);
  }

  Future<void> updateTransaksi() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        DocumentSnapshot<Map<String, dynamic>> saldoDoc = await _firestore
            .collection('saldo_bumdesa')
            .doc('current_saldo')
            .get();
        double saldoTerkini = saldoDoc.data()!['saldo'];

        if (widget.transaksi.jenisTransaksi == 'Kredit') {
          saldoTerkini += widget.transaksi.jumlah;
        } else if (widget.transaksi.jenisTransaksi == 'Debet') {
          saldoTerkini -= widget.transaksi.jumlah;
        }

        // Mengupdate transaksi di Firestore
        await _firestore
            .collection('transaksi')
            .doc(widget.transaksi.id)
            .update({
          'jenis_transaksi': jenisTransaksi,
          'jumlah': jumlah,
          'label': deskripsi,
          'created_at': Timestamp.fromDate(tanggal!),
        });

        if (jenisTransaksi == 'Kredit') {
          saldoTerkini -= jumlah!;
        } else if (jenisTransaksi == 'Debet') {
          saldoTerkini += jumlah!;
        }

        await _firestore
            .collection('saldo_bumdesa')
            .doc('current_saldo')
            .update({'saldo': saldoTerkini});

        Navigator.popUntil(
            context, ModalRoute.withName('/dashboard')); // Kembali ke dashboard
      } catch (e) {
        print('Error: $e');
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            Text('Update Transaksi', style: headerStyle(level: 3, dark: false)),
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
                          value: jenisTransaksi,
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
                          initialValue: deskripsi,
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
                            style: buttonStyleV2,
                            onPressed: updateTransaksi,
                            child: Text(
                              'Update',
                              style: headerStyle(level: 3, dark: false),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
