
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart'; // Ensure this import points to the file where LoginPage is defined
 // Ensure this import points to the file where LoginPage is defined

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        '/': (context) => LoginPage(),

        '/home': (context) => HomePage(), // Placeholder for home page

      },
    );
  }
}