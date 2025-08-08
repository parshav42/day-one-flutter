import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart'; // <-- Import your ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  Uint8List? _selectedImageBytes;
  final picker = ImagePicker();
  late Box productsBox;
  late Box settingsBox;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    productsBox = Hive.box('products');
    settingsBox = Hive.box('settings');

    // Redirect to login if not logged in
    bool isLoggedIn = settingsBox.get('isLoggedIn', defaultValue: false);
    if (!isLoggedIn || user == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/');
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _selectedImageBytes = await picked.readAsBytes();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠ No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to pick image: $e')),
      );
    }
  }

  void _addProduct() {
    if (nameController.text.trim().isEmpty || _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠ Please enter a name and select an image')),
      );
      return;
    }

    productsBox.add({
      'name': nameController.text.trim(),
      'imageBytes': _selectedImageBytes,
      'timestamp': DateTime.now().toIso8601String(),
    });

    nameController.clear();
    _selectedImageBytes = null;
    setState(() {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Product added successfully!')),
    );
  }

  void _deleteProduct(int index) {
    productsBox.deleteAt(index);
    setState(() {});
  }

  void _logout() {
    settingsBox.put('isLoggedIn', false);
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void _showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Product Name",
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick Product Image"),
            ),
            const SizedBox(height: 8),
            if (_selectedImageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_selectedImageBytes!, height: 150, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = productsBox.values.toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("My Store", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()), // <-- Navigation
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text("No products added yet", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (ctx, i) {
                final product = products[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(product['imageBytes'], width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateTime.parse(product['timestamp'])
                        .toLocal()
                        .toString()
                        .split('.')[0]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(products.length - 1 - i),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        label: const Text("Add Product"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
