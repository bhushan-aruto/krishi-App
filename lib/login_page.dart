import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException

import 'app_theme.dart';
import 'signup_page.dart';
import 'former_page.dart';
import 'buyer_page.dart';
import 'globals.dart'
    as globals; // Import the globals file to access the global variable

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

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

  Future<void> _handleLogin(BuildContext context, String userType) async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError("Email and password must not be empty.");
      setState(() => _isLoading = false);
      return;
    }

    final url = userType == 'farmer'
        ? Uri.parse("https://agriconnect.vsensetech.in/farmer/login")
        : Uri.parse("https://agriconnect.vsensetech.in/buyer/login");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      print("Token received: ${data['token']}");

      if (response.statusCode == 200 && data['token'] != null) {
        // Set the token in the global variable
        globals.token = data['token'];

        if (userType == 'farmer') {
          _navigateTo(context, const FormerPage());
        } else {
          _navigateTo(context, const BuyerPage());
        }
      } else {
        _showError(data['message'] ?? "Invalid credentials or server error.");
      }
    } on SocketException {
      _showError("No Internet connection. Please check your network.");
    } on TimeoutException {
      _showError("Request timed out. Please try again.");
    } catch (e) {
      _showError("Unexpected error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 500),
        child: page,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 30),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'AgriConnect',
                    textStyle: AppTextStyles.heading1
                        .copyWith(color: AppColors.primaryGreen),
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
                    _buildLoginForm(context, 'farmer'),
                    _buildLoginForm(context, 'buyer'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: AppTextStyles.bodyText2),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          duration: const Duration(milliseconds: 500),
                          child: const SignUpPage(),
                        ),
                      );
                    },
                    style: AppButtonStyles.text,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, String userType) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: AppInputDecorations.formFieldDecoration(
              'Email Address',
              prefixIcon: FontAwesomeIcons.envelope,
            ),
            style: AppTextStyles.formField,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            decoration: AppInputDecorations.formFieldDecoration(
              'Password',
              prefixIcon: FontAwesomeIcons.lock,
            ),
            style: AppTextStyles.formField,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed:
                _isLoading ? null : () => _handleLogin(context, userType),
            style: userType == 'farmer'
                ? AppButtonStyles.primary
                : AppButtonStyles.secondary,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Login as ${userType[0].toUpperCase()}${userType.substring(1)}'),
          ),
        ],
      ),
    );
  }
}
