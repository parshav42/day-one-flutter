
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'login.dart'; // Ensure this import points to the file where LoginPage is defined
import 'firebase_options.dart'; // Import the generated Firebase options
 // Ensure this import points to the file where LoginPage is defined

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      routes: {
        '/': (context) => LoginPage(),

        // '/home': (context) => HomePage(), // Placeholder for home page

      },
    );
  }
}