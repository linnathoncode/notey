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
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Color.fromARGB(255, 210, 68, 55),
        foregroundColor: Colors.white,
      ),
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
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                        print(userCredential);
                      } on FirebaseAuthException catch (e) {
                        String errorMessage;
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
                          default:
                            errorMessage = 'An unknown error occurred.';
                        }
                        print("Registration Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(errorMessage),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                    child: const Text("Login"),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 30, right: 30),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15)),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
