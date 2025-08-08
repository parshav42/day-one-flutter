import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'home.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('products');
  await Hive.openBox('settings');

  final settingsBox = Hive.box('settings');

  // Load login state
  bool isLoggedIn = settingsBox.get('isLoggedIn', defaultValue: false);

  // Sync Hive state with Firebase Auth
  if (FirebaseAuth.instance.currentUser == null) {
    isLoggedIn = false;
    settingsBox.put('isLoggedIn', false);
  } else {
    isLoggedIn = true;
    settingsBox.put('isLoggedIn', true);
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) =>  LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
