import 'package:flutter/material.dart';
import 'package:notey/components/button.dart';
import 'package:notey/components/text_form_field.dart';
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
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _confirmPasswordFocus;
  String errorMessage = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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
                child: customTextFormField(
                  focusNodeOne: _emailFocus,
                  focusNodeTwo: _passwordFocus,
                  context: context,
                  obscureText: false,
                  controller: _email,
                  hintText: 'Enter your e-mail',
                  validatorErrorMessage: 'Please enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: customTextFormField(
                  focusNodeOne: _passwordFocus,
                  focusNodeTwo: _confirmPasswordFocus,
                  context: context,
                  obscureText: true,
                  controller: _password,
                  hintText: 'Enter your password',
                  validatorErrorMessage: 'Please enter your password',
                  keyboardType: TextInputType.visiblePassword,
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
                    focusNode: _confirmPasswordFocus,
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
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8),
                child: customButton(
                  buttonText: "Register",
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
                          await Navigator.of(context).pushNamedAndRemoveUntil(
                            verifyRoute,
                            (route) => false,
                          );
                        }
                      } on EmailAlreadyInuserAuthException {
                        errorMessage = 'The email address is already in use.';
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
