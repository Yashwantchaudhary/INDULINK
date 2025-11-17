import 'package:flutter/material.dart';

class ResponsiveUtils {
  final BuildContext context;
  final Size screenSize;

  ResponsiveUtils(this.context) : screenSize = MediaQuery.of(context).size;

  bool get isMobile => screenSize.width < 600;
  bool get isTablet => screenSize.width >= 600 && screenSize.width < 1200;
  bool get isDesktop => screenSize.width >= 1200;

  double getResponsiveFontSize(double baseSize) {
    if (isDesktop) return baseSize * 1.2;
    if (isTablet) return baseSize * 1.1;
    return baseSize;
  }

  double getResponsivePadding(double basePadding) {
    if (isDesktop) return basePadding * 1.5;
    if (isTablet) return basePadding * 1.2;
    return basePadding;
  }

  double getResponsiveIconSize(double baseSize) {
    if (isDesktop) return baseSize * 1.2;
    if (isTablet) return baseSize * 1.1;
    return baseSize;
  }

  double getResponsiveHeight(double baseHeight) {
    if (isDesktop) return baseHeight * 1.2;
    if (isTablet) return baseHeight * 1.1;
    return baseHeight;
  }

  double getResponsiveBorderRadius(double baseRadius) {
    return baseRadius;
  }
}