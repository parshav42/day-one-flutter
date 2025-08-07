import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  File? _selectedImage;
  final picker = ImagePicker();
  late Box productsBox;

  @override
  void initState() {
    super.initState();
    productsBox = Hive.box('products');
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _addProduct() {
    if (nameController.text.isEmpty || _selectedImage == null) return;
    final newProduct = {
      'name': nameController.text,
      'imagePath': _selectedImage!.path,
      'timestamp': DateTime.now().toIso8601String(),
    };
    productsBox.add(newProduct);
    nameController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = productsBox.values.toList().reversed.toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Store", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[800],
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Product name input
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Product Name",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Image picker
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Product Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, height: 150),
                ),
              const SizedBox(height: 12),

              // Add Product
              ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const Text("Your Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 12),
              if (products.isEmpty)
                const Text("No products added yet"),
              ListView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, i) {
                  final product = products[i];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(product['imagePath']), width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(DateTime.parse(product['timestamp']).toLocal().toString().split('.')[0]),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
