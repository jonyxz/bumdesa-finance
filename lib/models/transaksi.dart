import 'package:cloud_firestore/cloud_firestore.dart';

class Transaksi {
  final String id;
  final String userId;
  final String jenisTransaksi;
  final double jumlah;
  final double saldoTerkini;
  final String label;
  final Timestamp createdAt;

  Transaksi({
    required this.id,
    required this.userId,
    required this.jenisTransaksi,
    required this.jumlah,
    required this.saldoTerkini,
    required this.label,
    required this.createdAt,
  });

  // Factory method to create a Transaksi object from a Firestore document
  factory Transaksi.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Transaksi(
      id: doc.id,
      userId: data['user_id'],
      jenisTransaksi: data['jenis_transaksi'],
      jumlah: data['jumlah'].toDouble(),
      saldoTerkini: data['saldo_terkini'].toDouble(),
      label: data['label'],
      createdAt: data['created_at'],
    );
  }

  // Method to convert a Transaksi object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'jenis_transaksi': jenisTransaksi,
      'jumlah': jumlah,
      'saldo_terkini': saldoTerkini,
      'label': label,
      'created_at': createdAt,
    };
  }
}
