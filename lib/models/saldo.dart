import 'package:cloud_firestore/cloud_firestore.dart';

class Saldo {
  final double saldo;
  final Timestamp updatedAt;

  Saldo({
    required this.saldo,
    required this.updatedAt,
  });

  // Factory method to create a Saldo object from a Firestore document
  factory Saldo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Saldo(
      saldo: data['saldo'].toDouble(),
      updatedAt: data['updated_at'],
    );
  }

  // Method to convert a Saldo object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'saldo': saldo,
      'updated_at': updatedAt,
    };
  }
}
