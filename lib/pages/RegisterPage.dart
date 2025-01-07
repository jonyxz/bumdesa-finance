import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bumdesa_finance/components/styles.dart';
import 'package:bumdesa_finance/components/validators.dart';
import 'package:flutter/gestures.dart';
import 'package:bumdesa_finance/components/input_widget.dart';
import 'package:flutter/services.dart';
import 'package:bumdesa_finance/models/akun.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  String nama = '';
  String email = '';
  String noHP = '';
  String password = '';

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save additional user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'nama': nama,
          'email': email,
          'noHP': noHP,
        });

        // Navigate to login page or dashboard
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        print('Error: $e');
        // Handle error (e.g., show error message)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Text('Register', style: headerStyle(level: 1)),
                Container(
                  child: const Text(
                    'Create your profile to start your journey',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    onChanged: (String value) => setState(() {
                      nama = value;
                    }),
                    validator: notEmptyValidator,
                    decoration: customInputDecoration("Nama"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    onChanged: (String value) => setState(() {
                      email = value;
                    }),
                    validator: notEmptyValidator,
                    decoration: customInputDecoration("Email"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    onChanged: (String value) => setState(() {
                      noHP = value;
                    }),
                    validator: notEmptyValidator,
                    decoration: customInputDecoration("No HP"),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _password,
                    onChanged: (String value) => setState(() {
                      password = value;
                    }),
                    validator: notEmptyValidator,
                    obscureText: true,
                    decoration: customInputDecoration("Password"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    validator: (value) =>
                        passConfirmationValidator(value, _password),
                    obscureText: true,
                    decoration: customInputDecoration("Konfirmasi Password"),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Register'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah memiliki akun? ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Login di sini',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
