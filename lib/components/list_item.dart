import 'package:flutter/material.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:intl/intl.dart';
import 'package:bumdesa_finance/components/styles.dart';

class ListItem extends StatelessWidget {
  final Transaksi transaksi;
  final Akun akun;
  final VoidCallback onDetail;

  const ListItem({
    super.key,
    required this.transaksi,
    required this.akun,
    required this.onDetail,
  });

  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      color: secondaryColor,
      child: ListTile(
        leading: Icon(
          transaksi.jenisTransaksi == 'Debet'
              ? Icons.add_circle
              : Icons.remove_circle,
          color:
              transaksi.jenisTransaksi == 'Debet' ? successColor : dangerColor,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatCurrency(transaksi.jumlah),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor),
            ),
            const SizedBox(height: 2),
            Text(
              transaksi.label,
              style: TextStyle(fontSize: 14, color: greyColor),
            ),
            Text(
              DateFormat('dd MMM yyyy').format(transaksi.createdAt.toDate()),
              style: TextStyle(fontSize: 12, color: greyColor),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.menu, color: primaryColor),
          onPressed: onDetail,
        ),
      ),
    );
  }
}
