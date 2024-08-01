import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Login'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              elevation: 7.0,
              shadowColor: const Color.fromARGB(75, 255, 0, 0),
              child: TextField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                controller: _email,
                decoration: const InputDecoration(
                    hintText: "Enter your e-mail",
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              elevation: 7.0,
              shadowColor: const Color.fromARGB(75, 255, 0, 0),
              child: TextField(
                  obscureText: true,
                  obscuringCharacter: "*",
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: _password,
                  decoration: const InputDecoration(
                      hintText: "Enter your password",
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder())),
            ),
          ),
          const SizedBox(height: 30),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Colors.red,
                      Color.fromARGB(255, 234, 91, 81)
                    ])),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      final userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Center(
                            child: Text(
                                "Logged in as ${userCredential.user?.email}",
                                style: const TextStyle(color: Colors.white)),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ));
                      }
                      print(userCredential);
                    } on FirebaseAuthException catch (e) {
                      String errorMessage;
                      print(e.code);
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage = 'The email address is not valid.';
                          break;
                        case 'user-disabled':
                          errorMessage = 'The user has been disabled.';
                          break;
                        case 'user-not-found':
                          errorMessage = 'No user found with this email.';
                          break;
                        case 'wrong-password':
                          errorMessage = 'Incorrect password.';
                          break;
                        case 'invalid-credential':
                          errorMessage = 'Invalid credential.';
                        default:
                          errorMessage = 'An unknown error occurred.';
                      }
                      print("Registration Error: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Center(
                              child: Text(errorMessage,
                                  style: const TextStyle(color: Colors.white))),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 30, right: 30),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 15)),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/register/', (route) => false);
              },
              child: const Text('Not registered yet?')),
        ],
      ),
    );
  }
}
