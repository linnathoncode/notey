import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/utilities/colors.dart';
import 'package:notey/utilities/show_snack_bar.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = AuthService.firebase().currentUser;
      await AuthService.firebase().reload();
      if (user?.isEmailVerified ?? false) {
        timer.cancel();
        if (mounted) {
          showInformationSnackBar(
              context, "Your email has been verified, you can now log in.");
          Navigator.of(context).pushNamedAndRemoveUntil(
            loginRoute,
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Verify email'),
        ),
        backgroundColor: kSecondaryColor,
        foregroundColor: kAccentColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/email.webp', height: 250),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  'Verify your email address',
                  style: TextStyle(
                    color: kFontColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
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
                          colors: [
                            kSecondaryColor,
                            kAccentColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await AuthService.firebase().sendEmailVerification();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                        left: 30,
                        right: 30,
                      ),
                      foregroundColor: kAccentColor,
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    child: const Text("Send email verification!"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
