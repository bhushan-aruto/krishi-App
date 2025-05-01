// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class FempPage extends StatelessWidget {
//   const FempPage({Key? key}) : super(key: key);

//   final List<Map<String, dynamic>> schemes = const [
//     {
//       "name": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
//       "description":
//           "PM-KISAN provides eligible farmer families with direct income support of ₹6,000 per year in three equal installments to ensure a steady income.",
//       "links": [
//         "https://pmkisan.gov.in",
//         "https://www.youtube.com/watch?v=qule-hr0ByQ"
//       ]
//     },
//     {
//       "name": "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
//       "description":
//           "Offers insurance coverage and financial support to farmers in case of crop failure due to natural calamities, pests, or diseases.",
//       "links": [
//         "https://pmfby.gov.in",
//         "https://www.youtube.com/watch?v=IpNOETFFAFs"
//       ]
//     },
//     {
//       "name": "Kisan Credit Card (KCC) Scheme",
//       "description":
//           "Provides farmers with timely access to affordable credit for farming and allied activities.",
//       "links": [
//         "https://www.myscheme.gov.in/schemes/kcc",
//         "https://www.youtube.com/watch?v=tIp8E2hDXT4"
//       ]
//     },
//     {
//       "name": "e-NAM (National Agriculture Market)",
//       "description":
//           "An online trading platform for agricultural commodities to ensure better price discovery and marketing.",
//       "links": [
//         "https://enam.gov.in",
//         "https://www.youtube.com/watch?v=kI1bJ4G6Df4"
//       ]
//     },
//     {
//       "name": "Rashtriya Krishi Vikas Yojana (RKVY)",
//       "description":
//           "Supports states in increasing public investment in agriculture and allied sectors.",
//       "links": [
//         "https://rkvy.da.gov.in",
//         "https://www.youtube.com/watch?v=sDDNLdMusD4"
//       ]
//     },
//     {
//       "name": "Soil Health Card Scheme",
//       "description":
//           "Provides farmers with information about the nutrient status of their soil to help improve productivity.",
//       "links": [
//         "https://soilhealth.dac.gov.in",
//         "https://www.youtube.com/watch?v=0spY1kKZFFo"
//       ]
//     },
//     {
//       "name": "Paramparagat Krishi Vikas Yojana (PKVY)",
//       "description":
//           "Promotes organic farming through adoption of organic village clusters and certification.",
//       "links": [
//         "https://pgsindia-ncof.gov.in/home.aspx",
//         "https://www.youtube.com/watch?v=SrA41Rbsn-o"
//       ]
//     },
//   ];

//   Future<void> launchLink(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Financial Empowerment',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color.fromARGB(255, 3, 197, 68),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       body: SingleChildScrollView(
//         // Added SingleChildScrollView
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               ...schemes.map((scheme) => _buildSchemeCard(
//                     context,
//                     title: scheme['name'],
//                     description: scheme['description'],
//                     links: List<String>.from(scheme['links']),
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSchemeCard(
//     BuildContext context, {
//     required String title,
//     required String description,
//     required List<String> links,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 20),
//       elevation: 20,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
//                 color: Colors.black87,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 10),
//             Text(
//               description,
//               style: const TextStyle(fontSize: 14, color: Colors.black54),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               alignment: WrapAlignment.center,
//               children: links.map((url) {
//                 IconData icon = FontAwesomeIcons.globe;
//                 Color iconColor = Colors.blue;

//                 if (url.contains("youtube.com")) {
//                   icon = FontAwesomeIcons.youtube;
//                   iconColor = Colors.red;
//                 }

//                 return IconButton(
//                   icon: Icon(icon, color: iconColor, size: 28),
//                   onPressed: () => launchLink(url),
//                   tooltip: 'Open Link',
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FempPage extends StatelessWidget {
  const FempPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> schemes = const [
    {
      "name": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
      "description":
          "PM-KISAN provides eligible farmer families with direct income support of ₹6,000 per year in three equal installments to ensure a steady income.",
      "links": [
        "https://pmkisan.gov.in",
        "https://www.youtube.com/watch?v=qule-hr0ByQ"
      ]
    },
    {
      "name": "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
      "description":
          "Offers insurance coverage and financial support to farmers in case of crop failure due to natural calamities, pests, or diseases.",
      "links": [
        "https://pmfby.gov.in",
        "https://www.youtube.com/watch?v=IpNOETFFAFs"
      ]
    },
    {
      "name": "Kisan Credit Card (KCC) Scheme",
      "description":
          "Provides farmers with timely access to affordable credit for farming and allied activities.",
      "links": [
        "https://www.myscheme.gov.in/schemes/kcc",
        "https://www.youtube.com/watch?v=tIp8E2hDXT4"
      ]
    },
    {
      "name": "e-NAM (National Agriculture Market)",
      "description":
          "An online trading platform for agricultural commodities to ensure better price discovery and marketing.",
      "links": [
        "https://enam.gov.in",
        "https://www.youtube.com/watch?v=kI1bJ4G6Df4"
      ]
    },
    {
      "name": "Rashtriya Krishi Vikas Yojana (RKVY)",
      "description":
          "Supports states in increasing public investment in agriculture and allied sectors.",
      "links": [
        "https://rkvy.da.gov.in",
        "https://www.youtube.com/watch?v=sDDNLdMusD4"
      ]
    },
    {
      "name": "Soil Health Card Scheme",
      "description":
          "Provides farmers with information about the nutrient status of their soil to help improve productivity.",
      "links": [
        "https://soilhealth.dac.gov.in",
        "https://www.youtube.com/watch?v=0spY1kKZFFo"
      ]
    },
    {
      "name": "Paramparagat Krishi Vikas Yojana (PKVY)",
      "description":
          "Promotes organic farming through adoption of organic village clusters and certification.",
      "links": [
        "https://pgsindia-ncof.gov.in/home.aspx",
        "https://www.youtube.com/watch?v=SrA41Rbsn-o"
      ]
    },
  ];

  Future<void> launchLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Empowerment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 197, 68),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ...schemes.map((scheme) => _buildSchemeCard(
                    context,
                    title: scheme['name'],
                    description: scheme['description'],
                    links: List<String>.from(scheme['links']),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<String> links,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2, // Reduced from 20 to 2 for a lighter shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: links.map((url) {
                IconData icon = FontAwesomeIcons.globe;
                Color iconColor = Colors.blue;

                if (url.contains("youtube.com")) {
                  icon = FontAwesomeIcons.youtube;
                  iconColor = Colors.red;
                }

                return IconButton(
                  icon: Icon(icon, color: iconColor, size: 28),
                  onPressed: () => launchLink(url),
                  tooltip: 'Open Link',
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
