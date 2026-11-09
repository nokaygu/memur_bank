import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

/// Kurumsal Açılış Ekranı (`SplashScreen` - `%100 const StatelessWidget`).
/// Senaryo 3: Zengin 3D Perspektifli Madalyon Dönüşü + Çift Eksenli 3B Yörünge Halkaları +
/// Canlı Sistem Kontrol Adımları ve animasyon bitiminde otomatik `LoginScreen` geçişi.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;
    final cubit = context.read<BankCubit>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ext.headerGradientStart, ext.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppPaddings.allXxl,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 2400),
              curve: Curves.easeInOutCubic,
              onEnd: cubit.completeSplash,
              builder: (context, progress, _) {
                // 3D Medalyon açılış eğrisi ve açı hesaplamaları
                final medallionSpinAngle =
                    (1.0 - progress) * math.pi * 2.0; // 360° Y-ekseni dönüşü
                final perspectiveTiltX =
                    math.sin(progress * math.pi) * 0.28; // X-ekseni 3D eğim
                final medallionScale =
                    0.72 + (0.28 * Curves.easeOutBack.transform(progress));
                final outerOrbitAngle = progress * math.pi * 2.5;
                final innerOrbitAngle = -progress * math.pi * 3.0;
                final titleReveal = ((progress - 0.15) / 0.55).clamp(0.0, 1.0);

                final step1Done = progress >= 0.28;
                final step2Done = progress >= 0.62;
                final step3Done = progress >= 0.90;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),

                    // 1. Zengin 3D Perspektif Sahnesi (Çift Yörünge Halkası + 3B Dönen Resmi Madalyon)
                    Center(
                      child: SizedBox(
                        width: AppPaddings.splashOrbitOuterSize,
                        height: AppPaddings.splashOrbitOuterSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Dış 3D Jiroskop / Hazine Güvenlik Yörüngesi
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0018)
                                ..rotateX(1.08)
                                ..rotateY(0.32)
                                ..rotateZ(outerOrbitAngle),
                              child: Container(
                                width: AppPaddings.splashOrbitOuterSize,
                                height: AppPaddings.splashOrbitOuterSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.secondary.withValues(
                                      alpha: 0.55,
                                    ),
                                    width: AppPaddings.xxs,
                                  ),
                                ),
                              ),
                            ),

                            // İç Ters Yönlü 3D KEP Kalkan Yörüngesi
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0018)
                                ..rotateX(-0.95)
                                ..rotateY(-0.42)
                                ..rotateZ(innerOrbitAngle),
                              child: Container(
                                width: AppPaddings.splashOrbitInnerSize,
                                height: AppPaddings.splashOrbitInnerSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.onPrimary.withValues(
                                      alpha: 0.38,
                                    ),
                                    width: AppPaddings.xxs / 2,
                                  ),
                                ),
                              ),
                            ),

                            // Merkezdeki 3D Perspektifli MemurBank Resmi Madalyonu
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0022)
                                ..rotateY(medallionSpinAngle)
                                ..rotateX(perspectiveTiltX)
                                ..scaleByDouble(
                                  medallionScale,
                                  medallionScale,
                                  1.0,
                                  1.0,
                                ),
                              child: Container(
                                padding: AppPaddings.allMd,
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.16,
                                  ),
                                  borderRadius: AppPaddings.radiusXxl,
                                  border: Border.all(
                                    color: colorScheme.secondary,
                                    width: AppPaddings.xxs / 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.secondary.withValues(
                                        alpha:
                                            0.20 +
                                            (0.25 *
                                                math.sin(progress * math.pi)),
                                      ),
                                      blurRadius: AppPaddings.xxl,
                                      spreadRadius: AppPaddings.xxs,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: AppPaddings.radiusXl,
                                  child: Image.asset(
                                    'stitch_ui/memurbank_resmi_logo/screen.png',
                                    width: AppPaddings.logoSplashSize,
                                    height: AppPaddings.logoSplashSize,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.account_balance,
                                          size: AppPaddings.logoSplashSize,
                                          color: colorScheme.onPrimary,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppPaddings.vGapXl,

                    // 2. 3D Derinlikli Kurumsal Başlık
                    Opacity(
                      opacity: titleReveal,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0015)
                          ..rotateX((1.0 - titleReveal) * 0.45),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.appName,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            AppPaddings.vGapXs,
                            Text(
                              AppStrings.appSubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppPaddings.vGapXxl,

                    // 3. Canlı Sistem Kontrol Adımları Kartı (Senaryo 3)
                    Container(
                      padding: AppPaddings.cardPadding,
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.12),
                        borderRadius: AppPaddings.radiusLg,
                        border: Border.all(
                          color: colorScheme.onPrimary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '3D KEP Güvenlik Doğrulaması',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '%${(progress * 100).round()}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.secondaryContainer,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          AppPaddings.vGapSm,
                          ClipRRect(
                            borderRadius: AppPaddings.radiusFull,
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: AppPaddings.progressHeight,
                              backgroundColor: colorScheme.onPrimary.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.secondary,
                              ),
                            ),
                          ),
                          AppPaddings.vGapMd,
                          _SystemCheckStepRow(
                            isDone: step1Done,
                            label: 'Supabase & KEP Güvenlik Tüneli Doğrulanıyor...',
                          ),
                          AppPaddings.vGapXs,
                          _SystemCheckStepRow(
                            isDone: step2Done,
                            label: 'Hazine Kamu Maaş & Avans Protokolleri Yüklendi',
                          ),
                          AppPaddings.vGapXs,
                          _SystemCheckStepRow(
                            isDone: step3Done,
                            label: 'Kamu Personeli Profilleri Hazır',
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppStrings.securityStamp,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemCheckStepRow extends StatelessWidget {
  final bool isDone;
  final String label;

  const _SystemCheckStepRow({required this.isDone, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_checked,
          color: isDone
              ? colorScheme.secondaryContainer
              : colorScheme.onPrimary.withValues(alpha: 0.55),
          size: AppPaddings.iconSm,
        ),
        AppPaddings.hGapSm,
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDone
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimary.withValues(alpha: 0.65),
              fontWeight: isDone ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
