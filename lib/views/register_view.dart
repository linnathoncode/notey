import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_exceptions.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/utilities/colors.dart';
import 'package:notey/utilities/show_snack_bar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  String errorMessage = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Register")),
        backgroundColor: kPrimaryColor,
        foregroundColor: kAccentColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: kPrimaryColor,
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
                      errorStyle: TextStyle(color: kErrorColor),
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
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: kPrimaryColor,
                        blurRadius: 7.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    obscureText: true,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _password,
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: kErrorColor),
                      hintText: "Enter your password",
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: kPrimaryColor,
                        blurRadius: 7.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    obscureText: true,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: _confirmPassword,
                    decoration: const InputDecoration(
                      errorStyle: TextStyle(color: kErrorColor),
                      hintText: "Confirm your password",
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _password.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
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
                          gradient: LinearGradient(
                            colors: [kPrimaryColor, kSecondaryColor],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final email = _email.text;
                          final password = _password.text;
                          try {
                            await AuthService.firebase()
                                .createUser(email: email, password: password);
                            // devtools.log(userCredential.toString());
                            final user = AuthService.firebase().currentUser;
                            if (context.mounted) {
                              showInformationSnackBar(
                                  context, "Registered as ${user?.email}");
                              await Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                verifyRoute,
                                (route) => false,
                              );
                            }
                          } on EmailAlreadyInuserAuthException {
                            errorMessage =
                                'The email address is already in use.';
                          } on InvalidEmailAuthException {
                            errorMessage = 'The email address is not valid.';
                          } on OperationNotAllowedAuthException {
                            errorMessage =
                                'Email/password accounts are not enabled.';
                          } on WeakPasswordAuthException {
                            errorMessage = 'The password is too weak.';
                          } on NetworkRequestFailedException {
                            errorMessage = 'Network error';
                          } on GenericAuthException catch (e) {
                            errorMessage = e.toString();
                          }
                          if (context.mounted && errorMessage != "") {
                            showErrorSnackBar(context, errorMessage);
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 30, right: 30),
                        foregroundColor: kAccentColor,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Already registered?',
                  style: TextStyle(color: kSecondaryColor),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      backgroundColor: kBackgroundColor,
    );
  }
}
