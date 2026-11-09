import 'package:flutter/material.dart';

import '../constants/app_paddings.dart';
import 'app_colors.dart';

/// MemurBank özel tema uzantısı (`MemurBankThemeExtension`).
/// Tüm ekranlar ve bileşenler özel durum/teftiş renklerine yalnızca bu extension
/// ve `Theme.of(context).colorScheme` üzerinden erişir.
@immutable
class MemurBankThemeExtension extends ThemeExtension<MemurBankThemeExtension> {
  final Color adminCardBg;
  final Color onAdminCard;
  final Color approvedGreen;
  final Color pendingAmber;
  final Color rejectedRed;
  final Color headerGradientStart;
  final Color headerGradientEnd;
  final Color subtleCardBg;
  final Color cardContainerBg;
  final Color shadowColor;

  const MemurBankThemeExtension({
    required this.adminCardBg,
    required this.onAdminCard,
    required this.approvedGreen,
    required this.pendingAmber,
    required this.rejectedRed,
    required this.headerGradientStart,
    required this.headerGradientEnd,
    required this.subtleCardBg,
    required this.cardContainerBg,
    required this.shadowColor,
  });

  static const MemurBankThemeExtension light = MemurBankThemeExtension(
    adminCardBg: AppColors.lightAdminCardBg,
    onAdminCard: AppColors.lightOnAdminCard,
    approvedGreen: AppColors.lightApprovedGreen,
    pendingAmber: AppColors.lightPendingAmber,
    rejectedRed: AppColors.lightRejectedRed,
    headerGradientStart: AppColors.lightHeaderGradientStart,
    headerGradientEnd: AppColors.lightHeaderGradientEnd,
    subtleCardBg: AppColors.lightSubtleCardBg,
    cardContainerBg: AppColors.lightSurfaceContainer,
    shadowColor: AppColors.lightShadowColor,
  );

  static const MemurBankThemeExtension dark = MemurBankThemeExtension(
    adminCardBg: AppColors.darkAdminCardBg,
    onAdminCard: AppColors.darkOnAdminCard,
    approvedGreen: AppColors.darkApprovedGreen,
    pendingAmber: AppColors.darkPendingAmber,
    rejectedRed: AppColors.darkRejectedRed,
    headerGradientStart: AppColors.darkHeaderGradientStart,
    headerGradientEnd: AppColors.darkHeaderGradientEnd,
    subtleCardBg: AppColors.darkSubtleCardBg,
    cardContainerBg: AppColors.darkSurfaceContainer,
    shadowColor: AppColors.darkShadowColor,
  );

  @override
  MemurBankThemeExtension copyWith({
    Color? adminCardBg,
    Color? onAdminCard,
    Color? approvedGreen,
    Color? pendingAmber,
    Color? rejectedRed,
    Color? headerGradientStart,
    Color? headerGradientEnd,
    Color? subtleCardBg,
    Color? cardContainerBg,
    Color? shadowColor,
  }) {
    return MemurBankThemeExtension(
      adminCardBg: adminCardBg ?? this.adminCardBg,
      onAdminCard: onAdminCard ?? this.onAdminCard,
      approvedGreen: approvedGreen ?? this.approvedGreen,
      pendingAmber: pendingAmber ?? this.pendingAmber,
      rejectedRed: rejectedRed ?? this.rejectedRed,
      headerGradientStart: headerGradientStart ?? this.headerGradientStart,
      headerGradientEnd: headerGradientEnd ?? this.headerGradientEnd,
      subtleCardBg: subtleCardBg ?? this.subtleCardBg,
      cardContainerBg: cardContainerBg ?? this.cardContainerBg,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  MemurBankThemeExtension lerp(
    ThemeExtension<MemurBankThemeExtension>? other,
    double t,
  ) {
    if (other is! MemurBankThemeExtension) {
      return this;
    }
    return MemurBankThemeExtension(
      adminCardBg: Color.lerp(adminCardBg, other.adminCardBg, t)!,
      onAdminCard: Color.lerp(onAdminCard, other.onAdminCard, t)!,
      approvedGreen: Color.lerp(approvedGreen, other.approvedGreen, t)!,
      pendingAmber: Color.lerp(pendingAmber, other.pendingAmber, t)!,
      rejectedRed: Color.lerp(rejectedRed, other.rejectedRed, t)!,
      headerGradientStart: Color.lerp(
        headerGradientStart,
        other.headerGradientStart,
        t,
      )!,
      headerGradientEnd: Color.lerp(
        headerGradientEnd,
        other.headerGradientEnd,
        t,
      )!,
      subtleCardBg: Color.lerp(subtleCardBg, other.subtleCardBg, t)!,
      cardContainerBg: Color.lerp(cardContainerBg, other.cardContainerBg, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      error: AppColors.lightError,
      onError: AppColors.lightOnError,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightSurface,
      extensions: const <ThemeExtension<dynamic>>[
        MemurBankThemeExtension.light,
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurfaceContainer,
        elevation: 0,
        margin: AppPaddings.zero,
        shape: RoundedRectangleBorder(borderRadius: AppPaddings.radiusLg),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding: AppPaddings.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: AppPaddings.radiusMd,
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppPaddings.radiusMd,
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppPaddings.radiusMd,
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 1.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurfaceContainer,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutline,
        thickness: 0.8,
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.darkOnSecondaryContainer,
      error: AppColors.darkError,
      onError: AppColors.darkOnError,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      extensions: const <ThemeExtension<dynamic>>[MemurBankThemeExtension.dark],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurfaceContainer,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurfaceContainer,
        elevation: 0,
        margin: AppPaddings.zero,
        shape: RoundedRectangleBorder(borderRadius: AppPaddings.radiusLg),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: AppPaddings.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: AppPaddings.radiusMd,
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppPaddings.radiusMd,
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppPaddings.radiusMd,
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceContainer,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutline,
        thickness: 0.8,
      ),
    );
  }
}
