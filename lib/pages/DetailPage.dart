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
      // Menghapus transaksi dari Firestore
      await _firestore.collection('transaksi').doc(transaksi.id).delete();

      // Mendapatkan saldo terkini
      DocumentSnapshot<Map<String, dynamic>> saldoDoc = await _firestore
          .collection('saldo_bumdesa')
          .doc('current_saldo')
          .get();
      double saldoTerkini = saldoDoc.data()!['saldo'];

      // Mengupdate saldo terkini
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
    // Menavigasi ke halaman update transaksi dengan membawa data transaksi
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () => _updateTransaksi(context),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteTransaksi(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Transaksi:',
              style: headerStyle(level: 4),
            ),
            const SizedBox(height: 5),
            Text(
              transaksi.jenisTransaksi,
              style: TextStyle(fontSize: 18, color: accentColor),
            ),
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
              'Tanggal:',
              style: headerStyle(level: 4),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('dd MMM yyyy, HH:mm')
                  .format(transaksi.createdAt.toDate()),
              style: TextStyle(fontSize: 18, color: accentColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Saldo Terkini:',
              style: headerStyle(level: 4),
            ),
            const SizedBox(height: 5),
            Text(
              'Rp ${transaksi.saldoTerkini.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
