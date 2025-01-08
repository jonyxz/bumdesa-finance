import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/models/saldo.dart';
import 'package:bumdesa_finance/components/styles.dart';

class HomePage extends StatefulWidget {
  final Akun akun;
  const HomePage({super.key, required this.akun});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  double saldoTerkini = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getSaldoTerkini();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Home', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Terkini',
                    style: headerStyle(level: 3),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rp ${saldoTerkini.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Tambahkan widget lain yang ingin ditampilkan di home
                ],
              ),
            ),
    );
  }
}
