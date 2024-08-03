import 'package:flutter/material.dart';

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
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Colors.red,
                        Color.fromARGB(255, 234, 91, 81)
                      ])),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/notes/', (route) => false);
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 30, right: 30),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15)),
                    child: const Text("Notes View"),
                  ),
                ],
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
                          gradient: LinearGradient(colors: [
                        Colors.red,
                        Color.fromARGB(255, 234, 91, 81)
                      ])),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login/', (route) => false);
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 30, right: 30),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15)),
                    child: const Text("Login View"),
                  ),
                ],
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
                          gradient: LinearGradient(colors: [
                        Colors.red,
                        Color.fromARGB(255, 234, 91, 81)
                      ])),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/register/', (route) => false);
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 30, right: 30),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15)),
                    child: const Text("Register View"),
                  ),
                ],
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
                          gradient: LinearGradient(colors: [
                        Colors.red,
                        Color.fromARGB(255, 234, 91, 81)
                      ])),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/verify/', (route) => false);
                    },
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 30, right: 30),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15)),
                    child: const Text("Verify Email View"),
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
