import 'package:flutter/material.dart';
import 'package:notey/components/button.dart';
import 'package:notey/constants/routes.dart';

class DevMenuView extends StatelessWidget {
  const DevMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Dev Menu"),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8),
              child: customButton(
                context: context,
                buttonText: 'Notes View',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: customButton(
                context: context,
                buttonText: 'Login View',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: customButton(
                context: context,
                buttonText: 'Register View',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: customButton(
                context: context,
                buttonText: 'Verify Email View',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyRoute,
                    (route) => false,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: customButton(
                context: context,
                buttonText: 'New Note View',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    createOrUpdateNoteRoute,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
