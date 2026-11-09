import 'package:flutter/material.dart';

/// SADECE BU KLASÖRDE (`lib/theme/`) RENK KODU OLUR!
/// Halkbank / Kamu Bankası Güven Paleti (Aydınlık) ve Merkez Bankası Gece Paleti (Koyu).
class AppColors {
  const AppColors._();

  // Aydınlık Tema (Kamu & Halkbank Güven Paleti)
  static const Color lightPrimary = Color(0xFF005BAA);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFDBEAFE);
  static const Color lightOnPrimaryContainer = Color(0xFF0A2540);
  static const Color lightSecondary = Color(0xFFD97706);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFFEF3C7);
  static const Color lightOnSecondaryContainer = Color(0xFF78350F);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEFF6FF);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF475569);
  static const Color lightOutline = Color(0xFFCBD5E1);
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // Koyu Tema (Merkez Bankası Gece Paleti)
  static const Color darkPrimary = Color(0xFF38BDF8);
  static const Color darkOnPrimary = Color(0xFF082F49);
  static const Color darkPrimaryContainer = Color(0xFF1E293B);
  static const Color darkOnPrimaryContainer = Color(0xFFF1F5F9);
  static const Color darkSecondary = Color(0xFFFBBF24);
  static const Color darkOnSecondary = Color(0xFF451A03);
  static const Color darkSecondaryContainer = Color(0xFF3B2F1E);
  static const Color darkOnSecondaryContainer = Color(0xFFFDE68A);
  static const Color darkSurface = Color(0xFF0B0F19);
  static const Color darkSurfaceContainer = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF334155);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFF450A0A);

  // MemurBankThemeExtension Özel Durum & Teftiş Renkleri (Light)
  static const Color lightAdminCardBg = Color(0xFFB91C1C);
  static const Color lightOnAdminCard = Color(0xFFFFFFFF);
  static const Color lightApprovedGreen = Color(0xFF059669);
  static const Color lightPendingAmber = Color(0xFFD97706);
  static const Color lightRejectedRed = Color(0xFFDC2626);
  static const Color lightHeaderGradientStart = Color(0xFF004E8B);
  static const Color lightHeaderGradientEnd = Color(0xFF0077CC);
  static const Color lightSubtleCardBg = Color(0xFFEDF5FC);
  static const Color lightShadowColor = Color(0x14004E8B);

  // MemurBankThemeExtension Özel Durum & Teftiş Renkleri (Dark)
  static const Color darkAdminCardBg = Color(0xFF991B1B);
  static const Color darkOnAdminCard = Color(0xFFFEE2E2);
  static const Color darkApprovedGreen = Color(0xFF10B981);
  static const Color darkPendingAmber = Color(0xFFF59E0B);
  static const Color darkRejectedRed = Color(0xFFEF4444);
  static const Color darkHeaderGradientStart = Color(0xFF0C2D48);
  static const Color darkHeaderGradientEnd = Color(0xFF145374);
  static const Color darkSubtleCardBg = Color(0xFF162032);
  static const Color darkShadowColor = Color(0x40000000);
}
