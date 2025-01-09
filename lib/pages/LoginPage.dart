import 'package:flutter/material.dart';
import '../components/input_widget.dart';
import '../components/styles.dart';
import '../components/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:bumdesa_finance/services/LocalStorageService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? email;
  String? password;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final isLoggedIn = await checkLoginStatus();
    if (isLoggedIn) {
      final userData = await loadUserData();
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<bool> checkLoginStatus() async {
    final localStorageService = LocalStorageService();
    return await localStorageService.isLoggedIn();
  }

  Future<Map<String, String?>> loadUserData() async {
    final localStorageService = LocalStorageService();
    return await localStorageService.getUserData();
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email!, password: password!);

        // Simpan data pengguna ke SharedPreferences
        await saveUserData(userCredential.user!.uid, email!);

        Navigator.pushReplacementNamed(context, '/dashboard');
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> saveUserData(String userId, String userName) async {
    final localStorageService = LocalStorageService();
    await localStorageService.saveUserData(userId, userName);
  }

  Future<void> logout() async {
    final localStorageService = LocalStorageService();
    await localStorageService.clearUserData();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Login'),
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
                Text('Login', style: headerStyle(level: 1)),
                const SizedBox(height: 50),
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
                      password = value;
                    }),
                    validator: notEmptyValidator,
                    obscureText: true,
                    decoration: customInputDecoration("Password"),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
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
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum memiliki akun? ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Register di sini',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(
                                  context, '/register');
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
