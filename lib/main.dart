import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/themes/dark_theme.dart';
import 'package:notey/themes/light_theme.dart';
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
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Track the theme mode (light, dark, system)
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notey',
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: HomeScreen(
        onThemeChanged: _toggleTheme,
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => NotesView(
              onThemeChanged: _toggleTheme,
            ),
        devmenuRoute: (context) => const DevMenuView(),
        verifyRoute: (context) => const VerifyEmailView(),
        homepageRoute: (context) => HomeScreen(
              onThemeChanged: _toggleTheme,
            ),
        createOrUpdateNoteRoute: (context) => const CreateOrUpdateNoteView(),
        searchRoute: (context) => const SearchView(),
      },
    );
  }

  // Toggle between light and dark modes
  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }
}

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  const HomeScreen({super.key, required this.onThemeChanged});
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
                return NotesView(
                  onThemeChanged: widget.onThemeChanged,
                );
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
