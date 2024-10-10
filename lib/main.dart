import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/utilities/colors.dart';
import 'package:notey/views/dev_menu_view.dart';
import 'package:notey/views/login_view.dart';
import 'package:notey/views/notes/create_or_update_note_view.dart';
import 'package:notey/views/notes/notes_view.dart';
import 'package:notey/views/notes/search_view.dart';
import 'package:notey/views/register_view.dart';
import 'package:notey/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notey',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: kPrimaryColor, // Cursor color
          selectionColor:
              kPrimaryColor.withOpacity(0.5), // Highlight selection color
          selectionHandleColor: kPrimaryColor, // Drag handle color
        ),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        devmenuRoute: (context) => const DevMenuView(),
        verifyRoute: (context) => const VerifyEmailView(),
        homepageRoute: (context) => const HomePage(),
        createOrUpdateNoteRoute: (context) => const CreateOrUpdateNoteView(),
        searchRoute: (context) => const SearchView(),
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
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
