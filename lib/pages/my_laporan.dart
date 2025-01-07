import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bumdesa_finance/components/list_item.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/components/styles.dart';

class MyLaporan extends StatefulWidget {
  final Akun akun;
  const MyLaporan({super.key, required this.akun});

  @override
  State<MyLaporan> createState() => _MyLaporanState();
}

class _MyLaporanState extends State<MyLaporan> {
  final _firestore = FirebaseFirestore.instance;

  List<Transaksi> listTransaksi = [];

  @override
  void initState() {
    super.initState();
    getTransaksi();
  }

  void getTransaksi() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('transaksi')
          .where('user_id', isEqualTo: widget.akun.uid)
          .get();

      setState(() {
        listTransaksi = querySnapshot.docs
            .map((doc) => Transaksi.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Transaksi Saya', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: listTransaksi.isEmpty
            ? const Center(child: Text('Tidak ada transaksi'))
            : ListView.builder(
                itemCount: listTransaksi.length,
                itemBuilder: (context, index) {
                  return ListItem(
                    transaksi: listTransaksi[index],
                    akun: widget.akun,
                    isUserTransaction:
                        listTransaksi[index].userId == widget.akun.uid,
                  );
                },
              ),
      ),
    );
  }
}
