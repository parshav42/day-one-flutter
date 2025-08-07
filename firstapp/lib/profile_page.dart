import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              radius: 50,
              child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 20),
            Text("Name: ${user?.displayName ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Email: ${user?.email ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
