import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bumdesa_finance/pages/dashboard/DashboardPage.dart';
import 'package:bumdesa_finance/pages/DetailPage.dart';
import 'package:bumdesa_finance/pages/LoginPage.dart';
import 'package:bumdesa_finance/pages/RegisterPage.dart';
import 'package:bumdesa_finance/pages/SplashPage.dart';
import 'package:bumdesa_finance/pages/AddFormPage.dart';
import 'package:bumdesa_finance/pages/UpdateFormPage.dart';
import 'package:bumdesa_finance/models/transaksi.dart';
import 'package:bumdesa_finance/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: 'Bumdesa Finance',
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => AddFormPage(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/update') {
        final args = settings.arguments as Transaksi;
        return MaterialPageRoute(
          builder: (context) {
            return UpdateFormPage(transaksi: args);
          },
        );
      }
      if (settings.name == '/detail') {
        final args = settings.arguments as Transaksi;
        return MaterialPageRoute(
          builder: (context) {
            return DetailPage(transaksi: args);
          },
        );
      }
      return null;
    },
  ));
}
