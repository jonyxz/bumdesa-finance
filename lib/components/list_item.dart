import 'package:flutter/material.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:intl/intl.dart';

class ListItem extends StatelessWidget {
  final Transaksi transaksi;
  final Akun akun;
  final bool isUserTransaction;
  final VoidCallback onDelete;

  const ListItem({
    super.key,
    required this.transaksi,
    required this.akun,
    required this.isUserTransaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: ListTile(
        leading: Icon(
          transaksi.jenisTransaksi == 'Debet'
              ? Icons.add_circle
              : Icons.remove_circle,
          color:
              transaksi.jenisTransaksi == 'Debet' ? Colors.green : Colors.red,
        ),
        title: Text(
          transaksi.label,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        subtitle: Text(
          'Rp ${transaksi.jumlah.toStringAsFixed(2)}\n${DateFormat('dd MMM yyyy').format(transaksi.createdAt.toDate())}',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        trailing: isUserTransaction
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
