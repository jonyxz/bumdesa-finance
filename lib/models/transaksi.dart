import 'package:cloud_firestore/cloud_firestore.dart';

class Transaksi {
  final String id;
  final String jenisTransaksi;
  final double jumlah;
  final double saldoTerkini;
  final String label;
  final String createdBy;
  final Timestamp createdAt;

  Transaksi({
    required this.id,
    required this.jenisTransaksi,
    required this.jumlah,
    required this.saldoTerkini,
    required this.label,
    required this.createdBy,
    required this.createdAt,
  });

  // Factory method to create a Transaksi object from a Firestore document
  factory Transaksi.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Transaksi(
      id: doc.id,
      jenisTransaksi: data['jenis_transaksi'],
      jumlah: data['jumlah'].toDouble(),
      saldoTerkini: data['saldo_terkini'].toDouble(),
      label: data['label'],
      createdBy: data['created_by'],
      createdAt: data['created_at'],
    );
  }

  // Method to convert a Transaksi object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'jenis_transaksi': jenisTransaksi,
      'jumlah': jumlah,
      'saldo_terkini': saldoTerkini,
      'label': label,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}
