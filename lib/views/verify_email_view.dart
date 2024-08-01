import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Verify email'),
        ),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Image.asset('assets/email.webp', height: 250),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                'Verify your email address',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 28,
                    fontWeight: FontWeight.w600),
              ),
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
                      Colors.blueGrey,
                      Color.fromARGB(255, 134, 170, 188)
                    ])),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 30, right: 30),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 15)),
                  child: const Text("Send email verification!"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
