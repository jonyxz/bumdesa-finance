import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/models/saldo.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final Akun akun;
  const HomePage({super.key, required this.akun});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  double saldoTerkini = 0.0;
  double totalKredit = 0.0;
  double totalDebet = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getSaldoTerkini();
    getTotalKreditDebet();
  }

  Future<void> getSaldoTerkini() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> saldoDoc = await _firestore
          .collection('saldo_bumdesa')
          .doc('current_saldo')
          .get();

      if (saldoDoc.exists) {
        setState(() {
          saldoTerkini = Saldo.fromFirestore(saldoDoc).saldo;
          _isLoading = false;
        });
      } else {
        // Jika dokumen saldo tidak ada, buat dokumen baru dengan saldo awal 0
        Saldo initialSaldo = Saldo(saldo: 0.0, updatedAt: Timestamp.now());
        await _firestore
            .collection('saldo_bumdesa')
            .doc('current_saldo')
            .set(initialSaldo.toFirestore());
        setState(() {
          saldoTerkini = initialSaldo.saldo;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getTotalKreditDebet() async {
    try {
      QuerySnapshot<Map<String, dynamic>> transaksiSnapshot =
          await _firestore.collection('transaksi').get();

      double kredit = 0.0;
      double debet = 0.0;

      for (var doc in transaksiSnapshot.docs) {
        Transaksi transaksi = Transaksi.fromFirestore(doc);
        if (transaksi.jenisTransaksi == 'Kredit') {
          kredit += transaksi.jumlah;
        } else if (transaksi.jenisTransaksi == 'Debet') {
          debet += transaksi.jumlah;
        }
      }

      setState(() {
        totalKredit = kredit;
        totalDebet = debet;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Home', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Selamat datang di Bumdesa Finance.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Divider(color: primaryColor),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Nama: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'BUMDes Sejahtera Randugunting',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Lokasi: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Desa Randugunting, Kec Bergas',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: secondaryColor,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 78.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Saldo Terkini',
                            style: headerStyle(level: 3),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Rp ${formatCurrency(saldoTerkini)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Card(
                          color: secondaryColor,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total Debet',
                                  style: headerStyle(level: 3),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Rp ${formatCurrency(totalDebet)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          color: secondaryColor,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total Kredit',
                                  style: headerStyle(level: 3),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Rp ${formatCurrency(totalKredit)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: dangerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
