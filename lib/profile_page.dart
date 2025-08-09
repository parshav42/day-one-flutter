import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final picker = ImagePicker();
  final settingsBox = Hive.box('settings');
  User? user = FirebaseAuth.instance.currentUser;
  Uint8List? _localPhotoBytes;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = settingsBox.get(
      'displayName',
      defaultValue: user?.displayName ?? 'N/A',
    );
    _localPhotoBytes = settingsBox.get('photoBytes');

    // Fetch latest name from Firestore
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((doc) {
        if (doc.exists && doc.data()?['name'] != null) {
          setState(() {
            _displayName = doc.data()!['name'];
          });
          settingsBox.put('displayName', _displayName);
        }
      });
    }
  }

  Future<void> _pickImageAndSave() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();

      // Save locally
      settingsBox.put('photoBytes', bytes);
      setState(() {
        _localPhotoBytes = bytes;
      });

      // Save to Firebase Storage and update photoURL in Auth + Firestore
      if (user != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child("profile_pics/${user!.uid}.jpg");
          await storageRef.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final downloadUrl = await storageRef.getDownloadURL();

          // Update Firebase Auth profile
          await user!.updatePhotoURL(downloadUrl);

          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({"photoURL": downloadUrl});

          // Save locally
          settingsBox.put('photoURL', downloadUrl);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to upload photo: $e")),
          );
        }
      }
    }
  }

  Future<void> _updateName() async {
    final nameCtrl = TextEditingController(text: _displayName ?? "");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty) {
                settingsBox.put('displayName', newName);
                setState(() => _displayName = newName);

                if (user != null) {
                  // Update Firebase Auth displayName
                  await user!.updateDisplayName(newName);

                  // Update Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({"name": newName});
                }
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Future<void> _logout() async {
    settingsBox.put('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.indigo),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImageAndSave,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _localPhotoBytes != null
                    ? MemoryImage(_localPhotoBytes!)
                    : (user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null) as ImageProvider?,
                child: (_localPhotoBytes == null && user?.photoURL == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text("Name: ${_displayName ?? 'N/A'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Email: ${user?.email ?? 'N/A'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _updateName, child: const Text("Edit Name")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _logout, child: const Text("Logout")),
          ],
        ),
      ),
    );
  }
}
