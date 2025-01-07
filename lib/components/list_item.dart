import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/components/styles.dart';

class ListItem extends StatefulWidget {
  final Transaksi transaksi;
  final Akun akun;
  final bool isUserTransaction;

  const ListItem({
    super.key,
    required this.transaksi,
    required this.akun,
    required this.isUserTransaction,
  });

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _firestore = FirebaseFirestore.instance;

  void deleteTransaksi() async {
    try {
      await _firestore
          .collection('transaksi')
          .doc(widget.transaksi.id)
          .delete();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: ListTile(
        leading: Icon(
          widget.transaksi.jenisTransaksi == 'Debet'
              ? Icons.remove_circle
              : Icons.add_circle,
          color: widget.transaksi.jenisTransaksi == 'Debet'
              ? Colors.red
              : Colors.green,
        ),
        title: Text(
          widget.transaksi.label,
          style: TextStyle(fontSize: 18, color: accentColor),
        ),
        subtitle: Text(
          'Rp ${widget.transaksi.jumlah.toStringAsFixed(2)}\n${DateFormat('dd MMM yyyy').format(widget.transaksi.createdAt.toDate())}',
          style: TextStyle(fontSize: 16, color: accentColor),
        ),
        trailing: widget.isUserTransaction
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: deleteTransaksi,
              )
            : null,
      ),
    );
  }
}
