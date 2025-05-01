import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'app_theme.dart';
import 'package:flutter/services.dart'; // For input formatter

class CheckoutPage extends StatefulWidget {
  final String sectionId;

  const CheckoutPage({super.key, required this.sectionId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final List<Map<String, dynamic>> _items = [];
  File? _itemImage;
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedUnit = 'kg';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDeleting = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
        'https://agriconnect.vsensetech.in/farmer/get/item/${widget.sectionId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _items.clear();
          for (var item in data) {
            _items.add({
              'id': item['id'],
              'name': item['name'],
              'qty': item['qty'],
              'price': item['price'],
              'unit': item['unit'],
              'image_url': item['image_url'],
              'image': null,
            });
          }
        });
      } else {
        _showSnackbar("Error fetching items: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackbar("Error fetching items: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String itemId) async {
    setState(() => _isDeleting = true);
    final url = Uri.parse(
        'https://agriconnect.vsensetech.in/farmer/delete/item/$itemId');
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);
      _showSnackbar(data['message'] ?? 'Something happened');
      await _fetchItems();
    } catch (e) {
      _showSnackbar("Error: $e");
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(int index) {
    final itemId = _items[index]['id'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteItem(itemId);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _itemImage = File(pickedFile.path));
    }
  }

  Future<void> _submitItem(Function setModalState) async {
    if (_formKey.currentState!.validate()) {
      if (_itemImage == null) {
        _showSnackbar("Please upload an image");
        return;
      }

      setModalState(() => _isSubmitting = true);
      final uri =
          Uri.parse('https://agriconnect.vsensetech.in/farmer/create/item');
      final request = http.MultipartRequest('POST', uri);

      request.fields['variant_id'] = widget.sectionId;
      request.fields['name'] = _nameController.text;
      request.fields['qty'] = _qtyController.text;
      request.fields['price'] = _priceController.text;
      request.fields['unit'] = _selectedUnit;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _itemImage!.path,
        filename: path.basename(_itemImage!.path),
      ));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      setModalState(() => _isSubmitting = false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackbar("Item added successfully");
        Navigator.of(context).pop();
        _fetchItems();
      } else {
        _showSnackbar("Error: $respStr");
      }
    }
  }

  void _showAddForm() {
    _nameController.clear();
    _qtyController.clear();
    _priceController.clear();
    _selectedUnit = 'kg';
    _itemImage = null;
    _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SingleChildScrollView(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(' Add Item',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 3, 197, 68))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.shopping_bag)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Qty', prefixIcon: Icon(Icons.numbers)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter quantity' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: ['kg', 'liter', 'bundle', 'piece']
                          .map((unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => _selectedUnit = value ?? 'kg'),
                      decoration: const InputDecoration(
                          labelText: 'Unit', prefixIcon: Icon(Icons.scale)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          prefixIcon: Icon(Icons.currency_rupee)),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter price' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _pickImage().then((_) => setModalState(() {}));
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Upload Image'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 3, 197, 68)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _itemImage != null
                              ? const Text("✅ Image Selected",
                                  style: TextStyle(color: Colors.green))
                              : const Text("No image uploaded"),
                        ),
                      ],
                    ),
                    if (_itemImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_itemImage!,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color.fromARGB(255, 3, 197, 68)),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _submitItem(setModalState),
                            icon: const Icon(Icons.check),
                            label: const Text('Submit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 3, 197, 68),
                              minimumSize: const Size.fromHeight(45),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            const Text("Checkout Items", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddForm,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                    strokeWidth: 3, color: Color.fromARGB(255, 3, 197, 68)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchItems,
              child: _items.isEmpty
                  ? const Center(
                      child: Text(
                        "No items yet!",
                        style: TextStyle(
                          color: Color.fromARGB(255, 3, 197, 68),
                          fontSize: 20,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (item['image_url'] != null) {
                                      _showFullImage(item['image_url']);
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item['image'] != null
                                        ? Image.file(item['image'],
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover)
                                        : item['image_url'] != null
                                            ? Image.network(item['image_url'],
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover)
                                            : const Icon(Icons.image,
                                                size: 80, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Name: ${item['name']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                          "Qty: ${item['qty']} ${item['unit']}"),
                                      const SizedBox(height: 4),
                                      Text("Price: ₹ ${item['price']}"),
                                    ],
                                  ),
                                ),
                                _isDeleting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color.fromARGB(
                                                255, 3, 197, 68)),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 30),
                                        onPressed: () => _confirmDelete(index),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
