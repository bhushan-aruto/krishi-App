import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'globals.dart' as globals;
import 'package:smart_park_assist/login_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuyerPage extends StatefulWidget {
  const BuyerPage({super.key});

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _items;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _items = fetchItems();
    });
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final response = await http
          .get(Uri.parse('https://agriconnect.vsensetech.in/buyer/get/items'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return {
            'id': item['id'],
            'variant_id': item['variant_id'],
            'name': item['name'],
            'image': item['image_url'],
            'unit': item['unit'],
            'price': item['price'],
            'qty': item['qty'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  void _showBuyForm(Map<String, dynamic> item) {
    int qty = 0;
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🛒 Buy Item - ${item['name']}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 197, 68))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Qty: ', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (qty > 0) {
                            setState(() => qty--);
                          }
                        },
                      ),
                      Text('$qty', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => qty++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Shipping Address',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (qty <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select quantity greater than 0')),
                        );
                        return;
                      }

                      if (addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter shipping address')),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final tokenParts = globals.token.split('.');
                        final payload = json.decode(utf8.decode(base64Url
                            .decode(base64Url.normalize(tokenParts[1]))));
                        final buyerId = payload['id'];

                        final response = await http.post(
                          Uri.parse(
                              'https://agriconnect.vsensetech.in/buyer/place/order'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${globals.token}',
                          },
                          body: jsonEncode({
                            'buyer_id': buyerId,
                            'item_id': item['id'],
                            'qty': qty.toString(),
                            'address': addressController.text,
                          }),
                        );

                        Navigator.pop(context); // Close loading
                        Navigator.pop(context); // Close bottom sheet

                        if (response.statusCode == 201) {
                          _loadItems(); // Refresh items
                          final responseBody = json.decode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Order placed successfully: ${responseBody['message']}'),
                              backgroundColor:
                                  const Color.fromARGB(255, 3, 197, 68),
                            ),
                          );
                        } else {
                          final responseBody = json.decode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to place order: ${responseBody['message']}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(context); // Close loading
                        Navigator.pop(context); // Close bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_cart_checkout,
                        color: Colors.white),
                    label: const Text('Buy',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 197, 68),
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriConnect', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        elevation: 6,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              icon: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child:
                    Icon(Icons.person, size: 28, color: AppColors.primaryGreen),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  globals.token = '';
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const LoginPage(),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadItems();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No items found"));
            } else {
              final items = snapshot.data!;
              final filteredItems = items.where((item) {
                final query = _searchQuery.toLowerCase();
                return item['name'].toLowerCase().contains(query) ||
                    item['price'].toString().contains(query);
              }).toList();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search by name or price...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 3, 197, 68),
                                width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 3, 197, 68),
                                width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 3, 197, 68),
                                width: 2),
                          ),
                        ),
                      ),
                    ),
                    filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text("No matching items",
                                style: TextStyle(color: Colors.white70)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final pricePerUnit =
                                  "₹${item['price']} / ${item['unit']}";

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: item['image'] != null
                                          ? Image.network(
                                              item['image'],
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  'images/fruit_placeholder.png',
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              'images/fruit_placeholder.png',
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            pricePerUnit,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Available Quantity: ${item['qty']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () =>
                                                    _showBuyForm(item),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 3, 197, 68),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: const [
                                                    Icon(Icons.shopping_cart,
                                                        color: Colors.white),
                                                    SizedBox(width: 8),
                                                    Text('Buy',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
