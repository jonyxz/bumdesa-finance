import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/components/list_item.dart';

import '../../components/styles.dart';

class TransaksiPage extends StatefulWidget {
  final Akun akun;

  TransaksiPage({required this.akun});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final _firestore = FirebaseFirestore.instance;
  List<Transaksi> transaksiList = [];

  @override
  void initState() {
    super.initState();
    getTransaksiList();
  }

  Future<void> getTransaksiList() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('transaksi').get();
    setState(() {
      transaksiList = querySnapshot.docs
          .map((doc) => Transaksi.fromFirestore(doc))
          .toList();
    });
  }

  void addTransaksi(Transaksi transaksi) {
    setState(() {
      transaksiList.add(transaksi);
    });
  }

  void deleteTransaksi(String id) async {
    await _firestore.collection('transaksi').doc(id).delete();
    setState(() {
      transaksiList.removeWhere((transaksi) => transaksi.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Transaksi'),
      ),
      body: ListView.builder(
        itemCount: transaksiList.length,
        itemBuilder: (context, index) {
          return ListItem(
            transaksi: transaksiList[index],
            akun: widget.akun,
            isUserTransaction:
                transaksiList[index].createdBy == widget.akun.uid,
            onDelete: () => deleteTransaksi(transaksiList[index].id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, size: 35, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/add', arguments: {
            'akun': widget.akun,
          });
        },
      ),
    );
  }
}
