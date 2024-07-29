import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: Center(child: Text("Register"))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              elevation: 7.0,
              shadowColor: Color.fromARGB(75, 255, 0, 0),
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
              shadowColor: Color.fromARGB(75, 255, 0, 0),
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
                          .createUserWithEmailAndPassword(
                              email: email, password: password);
                      print(userCredential);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Center(
                            child: Text(
                                "Registered with ${userCredential.user?.email}",
                                style: TextStyle(color: Colors.white)),
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ));
                      }
                    } on FirebaseException catch (e) {
                      String errorMessage;
                      switch (e.code) {
                        case 'email-already-in-use':
                          errorMessage = 'The email address is already in use.';
                          break;
                        case 'invalid-email':
                          errorMessage = 'The email address is not valid.';
                          break;
                        case 'operation-not-allowed':
                          errorMessage =
                              'Email/password accounts are not enabled.';
                          break;
                        case 'weak-password':
                          errorMessage = 'The password is too weak.';
                          break;
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
                  child: const Text("Register"),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 30, right: 30),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 15)),
                )
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login/', (route) => false);
              },
              child: Text('Already registered?')),
        ],
      ),
    );
  }
}
