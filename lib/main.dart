import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/views/dev_menu_view.dart';
import 'package:notey/views/login_view.dart';
import 'package:notey/views/notes_view.dart';
import 'package:notey/views/register_view.dart';
import 'package:notey/views/verify_email_view.dart';

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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        devmenuRoute: (context) => const DevMenuView(),
        verifyRoute: (context) => const VerifyEmailView(),
        homepageRoute: (context) => const HomePage(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
