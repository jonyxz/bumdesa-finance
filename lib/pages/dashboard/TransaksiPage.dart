import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/components/list_item.dart';
import 'package:bumdesa_finance/components/styles.dart';

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
  }

  void addTransaksi(Transaksi transaksi) {
    setState(() {
      transaksiList.insert(0, transaksi);
    });
  }

  void deleteTransaksi(String id) async {
    await _firestore.collection('transaksi').doc(id).delete();
    setState(() {
      transaksiList.removeWhere((transaksi) => transaksi.id == id);
    });
  }

  void showDetail(Transaksi transaksi) {
    Navigator.pushNamed(context, '/detail', arguments: transaksi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('Daftar Transaksi',
              style: headerStyle(level: 3, dark: false)),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('transaksi')
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada transaksi'));
            }

            transaksiList = snapshot.data!.docs
                .map((doc) => Transaksi.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: transaksiList.length,
              itemBuilder: (context, index) {
                return ListItem(
                  transaksi: transaksiList[index],
                  akun: widget.akun,
                  onDetail: () => showDetail(transaksiList[index]),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, size: 35, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/add', arguments: {
            'akun': widget.akun,
          }).then((result) {
            if (result != null && result is Transaksi) {
              if (!transaksiList
                  .any((transaksi) => transaksi.id == result.id)) {
                addTransaksi(result);
              }
            }
          });
        },
      ),
    );
  }
}
