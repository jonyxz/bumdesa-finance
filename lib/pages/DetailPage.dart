import 'package:flutter/material.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatelessWidget {
  final Transaksi transaksi;

  const DetailPage({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Transaksi', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jenis Transaksi: ${transaksi.jenisTransaksi}',
                style: TextStyle(fontSize: 18, color: accentColor)),
            const SizedBox(height: 10),
            Text('Jumlah: Rp ${transaksi.jumlah.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, color: accentColor)),
            const SizedBox(height: 10),
            Text(
                'Saldo Terkini: Rp ${transaksi.saldoTerkini.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, color: accentColor)),
            const SizedBox(height: 10),
            Text('Deskripsi: ${transaksi.label}',
                style: TextStyle(fontSize: 18, color: accentColor)),
            const SizedBox(height: 10),
            Text(
                'Tanggal: ${DateFormat('dd MMM yyyy').format(transaksi.createdAt.toDate())}',
                style: TextStyle(fontSize: 18, color: accentColor)),
          ],
        ),
      ),
    );
  }
}
