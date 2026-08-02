import 'package:flutter/material.dart';

extension OnboardingSpacing on BuildContext {
  double get onboardingShortSide => MediaQuery.of(this).size.shortestSide;

  double get onboardingPadding => onboardingShortSide * 0.06;
  double get onboardingSpacingSmall => onboardingShortSide * 0.02;
  double get onboardingSpacingMedium => onboardingShortSide * 0.04;
  double get onboardingSpacingLarge => onboardingShortSide * 0.08;

  double get onboardingIconDiameter => onboardingShortSide * 0.2;
  double get onboardingButtonPadding => onboardingShortSide * 0.04;
  double get onboardingBorderRadius => onboardingShortSide * 0.03;
  double get onboardingIndicatorHeight => onboardingShortSide * 0.012;
  double get onboardingSpinnerSize => onboardingShortSide * 0.055;
  double get onboardingSmallIconSize => onboardingShortSide * 0.045;
  double get onboardingMessageFontSize =>
      Theme.of(this).textTheme.bodyLarge?.fontSize ?? 14;
}
