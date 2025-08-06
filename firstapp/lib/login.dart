import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 231, 227, 227),
      child: Column(
        children: [
          Image.asset('assets/images/login.png',fit: BoxFit.cover),
        ],
      ),
    );
  }
}

