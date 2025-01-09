import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/components/list_item.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:intl/intl.dart';

class TransaksiPage extends StatefulWidget {
  final Akun akun;

  TransaksiPage({required this.akun});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final _firestore = FirebaseFirestore.instance;
  List<Transaksi> transaksiList = [];
  DateTime? selectedDate;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd MMM yyyy').format(selectedDate!)
                          : 'Semua Tanggal',
                      style: TextStyle(fontSize: 16, color: primaryColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _selectDate(context),
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          selectedDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            Expanded(
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

                  if (selectedDate != null) {
                    transaksiList = transaksiList.where((transaksi) {
                      return transaksi.createdAt
                          .toDate()
                          .isSameDate(selectedDate!);
                    }).toList();
                  }

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
          ],
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

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
