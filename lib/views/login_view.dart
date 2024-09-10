import 'package:flutter/material.dart';
import 'package:notey/components/button.dart';
import 'package:notey/components/text_form_field.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_exceptions.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/utilities/colors.dart';
import 'package:notey/utilities/show_snack_bar.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _password;
  String errorMessage = '';

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
        title: const Center(child: Text('Login')),
        backgroundColor: kPrimaryColor,
        foregroundColor: kAccentColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customTextField(
                    obscureText: false,
                    controller: _email,
                    hintText: 'Enter your e-mail',
                    validatorErrorMessage: 'Please enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: customTextField(
                      obscureText: true,
                      controller: _password,
                      hintText: 'Enter your password',
                      validatorErrorMessage: 'Please enter your password',
                      keyboardType: TextInputType.visiblePassword),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: customButton(
                    buttonText: "Login",
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final email = _email.text;
                        final password = _password.text;
                        final user = AuthService.firebase().currentUser;
                        try {
                          await AuthService.firebase()
                              .logIn(email: email, password: password);
                          await AuthService.firebase().reload();
                          if (user?.isEmailVerified ?? false) {
                            if (context.mounted) {
                              devtools.log(AuthService.firebase()
                                  .currentUser
                                  .toString());
                              showInformationSnackBar(
                                  context, "Logged in as ${user?.email}");
                              await Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                notesRoute,
                                (route) => false,
                              );
                            }
                          } else {
                            if (context.mounted) {
                              await Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                verifyRoute,
                                (route) => false,
                              );
                            }
                          }
                        } on InvalidEmailAuthException {
                          errorMessage = 'The email address is not valid.';
                        } on UserDisabledAuthException {
                          errorMessage = 'The user has been disabled.';
                        } on UserNotFoundAuthException {
                          errorMessage = 'No user found with this email.';
                        } on WrongPasswordAuthException {
                          errorMessage = 'Incorrect password.';
                        } on InvalidCredentialAuthException {
                          errorMessage = 'Invalid credential.';
                        } on NetworkRequestFailedException {
                          errorMessage = 'Network error';
                        } on GenericAuthException catch (e) {
                          errorMessage = errorMessage = e.toString();
                        }

                        if (context.mounted && errorMessage != "") {
                          showErrorSnackBar(context, errorMessage);
                        }
                      }
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute,
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Not registered yet?',
                      style: TextStyle(color: kSecondaryColor),
                    )),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: kBackgroundColor,
    );
  }
}
