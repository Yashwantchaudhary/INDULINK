import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return baseSpacing * 0.8;
    } else if (screenWidth < 600) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.2;
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return baseFontSize * 0.9;
    } else if (screenWidth < 600) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }
}