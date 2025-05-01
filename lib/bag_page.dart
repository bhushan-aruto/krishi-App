import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'globals.dart' as globals;

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  List<Map<String, dynamic>> bagItems = [];
  bool _isLoading = true;

  Map<String, bool> _orderLoading = {};

  Future<void> fetchBagItems() async {
    try {
      final token = globals.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No token found. Please log in again.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final tokenParts = globals.token.split('.');
      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))));
      final farmerId = payload['id'];

      final response = await http.get(
        Uri.parse(
            'https://agriconnect.vsensetech.in/farmer/get/orders/$farmerId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          bagItems = data.map((item) {
            return {
              "order_id": item["order_id"],
              "buyer_name": item["buyer_name"],
              "buyer_phone": item["buyer_phone"],
              "buyer_email": item["buyer_email"],
              "buyer_address": item["buyer_address"],
              "item_name": item["item_name"],
              "item_unit": item["item_unit"],
              "item_price": item["item_price"],
              "total_qty": item["total_qty"],
              "total_price": item["total_price"],
            };
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load orders.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteOrder(String orderId) async {
    setState(() {
      _orderLoading[orderId] = true;
    });

    try {
      final token = globals.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No token found. Please log in again.'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final response = await http.delete(
        Uri.parse(
            'https://agriconnect.vsensetech.in/farmer/delete/order/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(responseJson['message'] ?? 'Order deleted successfully.'),
          backgroundColor: Colors.green,
        ));

        fetchBagItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseJson['message'] ?? 'Failed to delete order.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _orderLoading[orderId] = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBagItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bag',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 3, 197, 68)),
              ),
            )
          : bagItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your Bag is Empty',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20, // optional: adjust as needed
                      fontWeight:
                          FontWeight.bold, // optional: for better visibility
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchBagItems,
                  color: const Color.fromARGB(255, 3, 197, 68),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: bagItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final orderId = item['order_id'];

                        return Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.black12, width: 1.2),
                          ),
                          margin: const EdgeInsets.only(bottom: 20),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['item_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 3, 197, 68),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Name: ${item['buyer_name']}"),
                                Text("Phone: ${item['buyer_phone']}"),
                                Text("Email: ${item['buyer_email']}"),
                                Text("Address: ${item['buyer_address']}"),
                                Text("Quantity: ${item['total_qty']}"),
                                Text("Unit: ${item['item_unit']}"),
                                Text("Price: ₹${item['item_price']}"),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _orderLoading[orderId] == true
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Color.fromARGB(
                                                        255, 3, 197, 68)),
                                            strokeWidth:
                                                3, // Make the indicator smaller
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            deleteOrder(orderId);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 3, 197, 68),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: const Text(
                                            'Done',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
