import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:notey/constants/routes.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(75, 255, 0, 0),
                      blurRadius: 7.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                  decoration: const InputDecoration(
                    hintText: "Enter your e-mail",
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(75, 255, 0, 0),
                      blurRadius: 7.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Enter your password",
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(75, 255, 0, 0),
                      blurRadius: 7.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red,
                                Color.fromARGB(255, 234, 91, 81)
                              ],
                            ),
                          ),
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
                              devtools.log(userCredential.toString());
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Center(
                                  child: Text(
                                      "Logged in as ${userCredential.user?.email}",
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ));
                              await Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                notesRoute,
                                (route) => false,
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String errorMessage;
                            switch (e.code) {
                              case 'invalid-email':
                                errorMessage =
                                    'The email address is not valid.';
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
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Center(
                                    child: Text(errorMessage,
                                        style: const TextStyle(
                                            color: Colors.white))),
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
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text('Not registered yet?')),
          ],
        ),
      ),
    );
  }
}
