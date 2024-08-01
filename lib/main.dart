import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notey/views/login_view.dart';
import 'package:notey/views/register_view.dart';
import 'package:notey/views/verify_email_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 163, 5, 5)),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                print('Email is verified');
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
            return const MainPage();
          // return const VerifyEmailView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text("Notey",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
        backgroundColor: const Color.fromARGB(204, 36, 50, 83),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 8),
            child: Center(
              child: Text(
                'Welcome back',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8),
            child: Center(
              child: Text(
                '$userName',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
