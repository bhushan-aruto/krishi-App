
import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure correct import for LoginPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriConnect',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(), // ✅ Launch the LoginPage
    );
  }
}
