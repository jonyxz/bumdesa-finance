import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatelessWidget {
  final Transaksi transaksi;

  const DetailPage({super.key, required this.transaksi});

  Future<void> _deleteTransaksi(BuildContext context) async {
    final _firestore = FirebaseFirestore.instance;

    try {
      await _firestore.collection('transaksi').doc(transaksi.id).delete();

      DocumentSnapshot<Map<String, dynamic>> saldoDoc = await _firestore
          .collection('saldo_bumdesa')
          .doc('current_saldo')
          .get();
      double saldoTerkini = saldoDoc.data()!['saldo'];

      if (transaksi.jenisTransaksi == 'Kredit') {
        saldoTerkini += transaksi.jumlah;
      } else if (transaksi.jenisTransaksi == 'Debet') {
        saldoTerkini -= transaksi.jumlah;
      }

      await _firestore
          .collection('saldo_bumdesa')
          .doc('current_saldo')
          .update({'saldo': saldoTerkini});

      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateTransaksi(BuildContext context) async {
    Navigator.pushNamed(context, '/update', arguments: transaksi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Transaksi', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Card(
                color: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('dd MMM yyyy, HH:mm')
                        .format(transaksi.createdAt.toDate()),
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 350,
                child: Card(
                  color: secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            transaksi.jenisTransaksi,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: transaksi.jenisTransaksi == 'Debet'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                        Divider(color: accentColor),
                        const SizedBox(height: 20),
                        Text(
                          'Jumlah:',
                          style: headerStyle(level: 4),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rp ${transaksi.jumlah.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18, color: accentColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Deskripsi:',
                          style: headerStyle(level: 4),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          transaksi.label,
                          style: TextStyle(fontSize: 18, color: accentColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Created By:',
                          style: headerStyle(level: 4),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          transaksi.createdBy,
                          style: TextStyle(fontSize: 18, color: accentColor),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warningColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  icon: Icon(Icons.edit, color: accentColor),
                  label: Text('Edit', style: TextStyle(color: accentColor)),
                  onPressed: () => _updateTransaksi(context),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  icon: Icon(Icons.delete, color: accentColor),
                  label: Text('Hapus', style: TextStyle(color: accentColor)),
                  onPressed: () => _deleteTransaksi(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
