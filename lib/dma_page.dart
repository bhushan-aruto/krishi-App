import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_park_assist/app_theme.dart';
import 'package:smart_park_assist/globals.dart' as globals;
import 'package:smart_park_assist/chcekout_page.dart';

class DMASectionPage extends StatefulWidget {
  const DMASectionPage({super.key});

  @override
  State<DMASectionPage> createState() => _DMASectionPageState();
}

class _DMASectionPageState extends State<DMASectionPage> {
  List<dynamic> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String token = globals.token;

      if (token.isEmpty) {
        _redirectToLogin();
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String farmerId = decodedToken['id'];

      final response = await http.get(
        Uri.parse('http://34.93.40.82:8080/farmer/get/category/$farmerId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _sections = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        _showError("Failed to fetch sections. Please try again.");
      }
    } catch (e) {
      _showError("Something went wrong. Please try again later.");
    }
  }

  void _redirectToLogin() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Direct Market Access",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 3, 197, 68),
                  ),
                ),
              ),
            )
          : _sections.isEmpty
              ? const Center(
                  child: Text(
                    "🌾 No category sections available!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 3, 197, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.network(
                                    section['banner_image_url'] ?? '',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                section['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutPage(
                                        sectionId: section['id'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text("Checkout"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 3, 197, 68),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
