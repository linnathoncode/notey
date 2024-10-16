import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/theme/theme_provider.dart';
import 'package:notey/themes/dark_theme.dart';
import 'package:notey/themes/light_theme.dart';
import 'package:notey/views/dev_menu_view.dart';
import 'package:notey/views/login_view.dart';
import 'package:notey/views/notes/create_or_update_note_view.dart';
import 'package:notey/views/notes/notes_view.dart';
import 'package:notey/views/notes/search_view.dart';
import 'package:notey/views/register_view.dart';
import 'package:notey/views/verify_email_view.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initializeTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Notey',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            routes: {
              loginRoute: (context) => const LoginView(),
              registerRoute: (context) => const RegisterView(),
              notesRoute: (context) => const NotesView(),
              devmenuRoute: (context) => const DevMenuView(),
              verifyRoute: (context) => const VerifyEmailView(),
              homepageRoute: (context) => const HomeScreen(),
              createOrUpdateNoteRoute: (context) =>
                  const CreateOrUpdateNoteView(),
              searchRoute: (context) => const SearchView(),
            },
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
