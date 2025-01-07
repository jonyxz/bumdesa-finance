import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final Akun akun;

  const ProfilePage({super.key, required this.akun});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  String nama = '';
  String role = '';
  String noHP = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Menggunakan UID pengguna yang sedang login
            .get();
        if (userDoc.exists) {
          var userData = userDoc.data();
          setState(() {
            email = userData?['email'] ?? 'Email tidak ditemukan';
            nama = userData?['nama'] ?? 'Nama tidak ditemukan';
            noHP = userData?['noHP'] ?? 'No HP tidak ditemukan';
          });
        } else {
          print('Dokumen tidak ditemukan');
        }
      } else {
        print('Pengguna tidak login');
      }
    } catch (e) {
      print('Error saat mengambil data: $e');
    }
  }

  void keluar(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: secondaryColor,
              child: Icon(Icons.person, size: 50, color: accentColor),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: primaryColor),
                      title: Text(nama,
                          style: TextStyle(fontSize: 18, color: accentColor)),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: primaryColor),
                      title: Text('Email',
                          style: TextStyle(fontSize: 18, color: accentColor)),
                      subtitle: Text(email,
                          style: TextStyle(fontSize: 16, color: accentColor)),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone, color: primaryColor),
                      title: Text('No HP',
                          style: TextStyle(fontSize: 18, color: accentColor)),
                      subtitle: Text(noHP,
                          style: TextStyle(fontSize: 16, color: accentColor)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  keluar(context);
                },
                child: const Text('Logout',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
