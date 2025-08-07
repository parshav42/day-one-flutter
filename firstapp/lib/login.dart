import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          Image.asset('assets/images/login.png',fit: BoxFit.fitHeight),
        ],
      ),
    );
  }
}

