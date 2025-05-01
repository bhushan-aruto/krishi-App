import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF1B5E20); // Strong forest green
  static const Color secondaryGreen = Color(0xFF2E7D32); // Slightly lighter
  static const Color accentGreen = Color(0xFF66BB6A); // Vibrant accent
  static const Color lightGreen = Color(0xFFA5D6A7); // Light green shade
  static const Color background = Colors.white; // Clean white background
  static const Color gradientStart = Color(0xFF1B5E20); // Forest green
  static const Color gradientEnd = Color(0xFFE8F5E9); // Light leafy green
  static const Color white = Colors.white;
  static const primaryColor = Color.fromARGB(255, 3, 197, 68);

  // Gold tones
  static const Color gold = Color(0xFFFFD700);
  static const Color lightGold = Color(0xFFFFE57F);

  // Other
  static const Color cardBackground = Colors.white;
  static const Color error = Colors.redAccent;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color buttonText = Colors.white;
  static const Color divider = Colors.grey;
}

class AppGradients {
  static const LinearGradient greenWhite = LinearGradient(
    colors: [AppColors.accentGreen, AppColors.accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whiteToGreen = LinearGradient(
    colors: [AppColors.white, AppColors.primaryGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Custom Text Styles (Premium Typography)
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Montserrat', // Use a premium font like Montserrat
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -1.2,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -1,
  );
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'OpenSans', // Use a clean, readable font like Open Sans
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.5, // Improved line height for readability
  );
  static const TextStyle bodyText2 = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    letterSpacing: 0.5,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
  static const TextStyle formField = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );
  static const TextStyle formFieldHint = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
  static const TextStyle errorText = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    letterSpacing: 0.2,
  );
}

// Custom Button Styles
class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 23, 179, 33),
    foregroundColor: AppColors.buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    textStyle: AppTextStyles.buttonText,
    elevation: 5,
    shadowColor: const Color.fromARGB(255, 32, 173, 42).withOpacity(0.4),
    animationDuration: const Duration(milliseconds: 200),
    // Add hover/tap effects if needed (using MaterialStateProperty)
  );

  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(
        255, 23, 179, 33), // Make Secondary same as Primary
    foregroundColor: AppColors.buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    textStyle: AppTextStyles.buttonText,
    elevation: 5,
    shadowColor: const Color.fromARGB(255, 32, 173, 42).withOpacity(0.4),
    animationDuration: const Duration(milliseconds: 200),
  );

  static ButtonStyle outline = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryGreen,
    side: const BorderSide(color: AppColors.primaryGreen, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    textStyle: AppTextStyles.buttonText,
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return const Color.fromARGB(255, 2, 116, 10)
              .withOpacity(0.1); // Light green hover
        }
        if (states.contains(MaterialState.pressed)) {
          return const Color.fromARGB(255, 15, 129, 23)
              .withOpacity(0.2); // Slightly darker green press
        }
        return null; // Use the default value.
      },
    ),
  );

  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.primaryGreen,
    textStyle: AppTextStyles.buttonText.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500), // Lighter weight for text buttons
    padding: EdgeInsets.zero, // Remove padding for text buttons
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return AppColors.accentGreen.withOpacity(0.1);
        }
        if (states.contains(MaterialState.pressed)) {
          return AppColors.accentGreen.withOpacity(0.2);
        }
        return null;
      },
    ),
  );
}

// Custom Input Decoration for Form Fields
class AppInputDecorations {
  static InputDecoration formFieldDecoration(String labelText,
      {String? hintText, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: AppTextStyles.formFieldHint, // Label uses the hint style.
      hintText: hintText,
      hintStyle: AppTextStyles.formFieldHint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon,
              color: AppColors.primaryGreen, size: 18) // Reduced icon size
          : null,
      filled: true,
      fillColor:
          AppColors.cardBackground, // Background color for the input field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide.none, // No border, we'll use a shadow for emphasis
      ),
      focusedBorder: OutlineInputBorder(
        // Style when the field is focused
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        // Style when there's an error
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      floatingLabelBehavior: FloatingLabelBehavior.auto, // Animate label
      // Add a subtle shadow to the input field
    );
  }
}
