import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'globals.dart' as globals;

import 'app_theme.dart';
import 'package:smart_park_assist/login_page.dart';
import 'package:smart_park_assist/dma_page.dart';
import 'package:smart_park_assist/iot_page.dart';
import 'package:smart_park_assist/femp_page.dart';
import 'package:smart_park_assist/bag_page.dart';

class FormerPage extends StatelessWidget {
  const FormerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardSpacing = 20.0;
    final double sidePadding = 20.0;

    final double cardWidth = (screenWidth - sidePadding * 2 - cardSpacing) / 2;
    final double cardHeight = cardWidth > 0 ? cardWidth : 0;

    if (globals.token.isEmpty) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const LoginPage(),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'AgriConnect',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        elevation: 6,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'images/krishisevak.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSquareCard(
                  context: context,
                  title: 'DMA',
                  icon: FontAwesomeIcons.shop,
                  iconColor: Colors.orangeAccent,
                  width: cardWidth,
                  height: cardHeight,
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const DMASectionPage(),
                    ),
                  ),
                ),
                _buildSquareCard(
                  context: context,
                  title: 'FEMP',
                  icon: FontAwesomeIcons.indianRupeeSign,
                  iconColor: Colors.greenAccent,
                  width: cardWidth,
                  height: cardHeight,
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const FempPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSquareCard(
              context: context,
              title: 'IOT',
              icon: FontAwesomeIcons.microchip,
              iconColor: Colors.lightBlueAccent,
              width: screenWidth - sidePadding * 2,
              height: cardHeight,
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  child: const IotPage(),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const BagPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
                backgroundColor: Colors.deepOrangeAccent,
                shadowColor: Colors.orange,
                elevation: 10,
              ),
              child: const Icon(
                FontAwesomeIcons.bagShopping,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    width = width > 0 ? width : 0;
    height = height > 0 ? height : 0;

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 2, // Reduced from 6 to 2 for a lighter shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(width: 1.2, color: Colors.black12),
        ),
        color: AppColors.cardBackground,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 30, color: iconColor),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTextStyles.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
