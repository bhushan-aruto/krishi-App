//worked one

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

import 'app_theme.dart';
import 'login_page.dart';

class _CustomTabIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabPainter(this, onChanged);
  }
}

class _CustomTabPainter extends BoxPainter {
  final _CustomTabIndicator decoration;
  _CustomTabPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 229, 255, 0)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(rect.left, rect.bottom - 5, rect.right, rect.bottom),
      const Radius.circular(8),
    );
    canvas.drawRRect(rRect, paint);
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Enter 10-digit number';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 8) return 'At least 8 characters required';
    return null;
  }

  Future<void> _handleSignUp(BuildContext context, String userType) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String endpoint = userType.toLowerCase() == "farmer"
        ? "https://agriconnect.vsensetech.in/farmer/signup"
        : "https://agriconnect.vsensetech.in/buyer/signup";

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": _emailController.text.trim(),
        "full_name": _nameController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "password": _passwordController.text.trim(),
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup successful! Redirecting to login...'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _navigateToLogin(context);
      });
    } else {
      try {
        final message = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An unexpected error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 500),
        child: const LoginPage(),
      ),
    );
  }

  Widget _buildForm(String userType, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: AppInputDecorations.formFieldDecoration(
              'Full Name',
              prefixIcon: FontAwesomeIcons.user,
            ),
            style: AppTextStyles.formField,
            validator: _validateName,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _phoneController,
            decoration: AppInputDecorations.formFieldDecoration(
              'Phone Number',
              prefixIcon: FontAwesomeIcons.phone,
            ),
            style: AppTextStyles.formField,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            decoration: AppInputDecorations.formFieldDecoration(
              'Email Address',
              prefixIcon: FontAwesomeIcons.envelope,
            ),
            style: AppTextStyles.formField,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            decoration: AppInputDecorations.formFieldDecoration(
              'Password',
              prefixIcon: FontAwesomeIcons.lock,
            ),
            style: AppTextStyles.formField,
            validator: _validatePassword,
            obscureText: true,
          ),
          const SizedBox(height: 25),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () => _handleSignUp(context, userType),
                  style: AppButtonStyles.primary,
                  child: Text('Sign Up as ${userType.capitalize()}'),
                ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ", style: AppTextStyles.bodyText2),
              TextButton(
                onPressed: () => _navigateToLogin(context),
                child:
                    const Text('Login', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'AgriConnect',
                        textStyle: AppTextStyles.heading1.copyWith(
                          color: const Color.fromARGB(255, 23, 179, 33),
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: const Duration(milliseconds: 500),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                  const SizedBox(height: 30),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Farmer'),
                      Tab(text: 'Buyer'),
                    ],
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.bodyText1
                        .copyWith(fontWeight: FontWeight.w600),
                    indicator: _CustomTabIndicator(),
                    indicatorSize: TabBarIndicatorSize.label,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildForm("Farmer", context),
                        _buildForm("Buyer", context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringCasing on String {
  String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
