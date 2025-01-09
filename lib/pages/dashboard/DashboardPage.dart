import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bumdesa_finance/models/akun.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/pages/dashboard/HomePage.dart';
import 'package:bumdesa_finance/pages/dashboard/TransaksiPage.dart';
import 'package:bumdesa_finance/pages/dashboard/ProfilePage.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  List<Widget> pages = [];

  Akun akun = Akun(
    uid: '',
    docId: '',
    nama: '',
    noHP: '',
    email: '',
    role: '',
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getAkun();
  }

  Future<void> getAkun() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('akun')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();

        if (mounted) {
          setState(() {
            akun = Akun(
              uid: userData['uid'],
              nama: userData['nama'],
              noHP: userData['noHP'],
              email: userData['email'],
              docId: userData['docId'],
              role: userData['role'],
            );
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      });
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      HomePage(akun: akun),
      TransaksiPage(akun: akun),
      ProfilePage(akun: akun),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Bumdes Finance',
            style: headerStyle(level: 1, dark: false)
                .copyWith(color: accentColor)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primaryColor,
        unselectedItemColor: accentColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
