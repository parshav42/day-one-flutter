import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellowAccent,
      
      appBar: AppBar(
        title: Text('Welcome to My First App'),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          color: const Color.fromARGB(255, 39, 8, 212),
          padding: EdgeInsets.all(16.0),
          child: Text('Hello, World!'),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.pinkAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ],
        ),
      ),
      
    );
  }
}