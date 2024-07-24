import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notey/views/login_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notey',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 163, 5, 5)),
        useMaterial3: true,
      ),
      home: const RegisterView(),
    ),
  );
}

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
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.indigo,
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
                            .createUserWithEmailAndPassword(
                                email: email, password: password);
                        print(userCredential);
                      } on FirebaseException catch (e) {
                        String errorMessage;
                        switch (e.code) {
                          case 'email-already-in-use':
                            errorMessage =
                                'The email address is already in use.';
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(errorMessage),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ));
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
              ))
        ],
      ),
    );
  }
}
