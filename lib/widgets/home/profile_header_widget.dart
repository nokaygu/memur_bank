import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';
import 'atm_qr_bottom_sheet.dart';
import 'payroll_detail_bottom_sheet.dart';

/// Memur Kimlik Başlığı, Vadesiz Maaş Bakiyesi, Hızlı Aksiyonlar (Transfer, Avans, ATM Karekod),
/// Ayın 15'i Maaş Yatış Sayacı (E-Bordro Detaylı) ve Memura Özel %0 Faizli Maaş Avansı Kampanya Kartı.
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  void _openPayrollSheet(BuildContext context, ProfileModel profile) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppPaddings.bottomSheetRadius,
      ),
      builder: (_) => PayrollDetailBottomSheet(profile: profile),
    );
  }

  void _openAtmQrSheet(BuildContext context, ProfileModel profile) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppPaddings.bottomSheetRadius,
      ),
      builder: (_) => AtmQrBottomSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final profile = state.activeProfile;
        final cubit = context.read<BankCubit>();
        final daysLeft = state.daysUntilSalaryDay;
        final progressPercent = (state.salaryCycleProgress * 100).round();

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Üst Kurum & Sicil Rozeti Bandı
              Container(
                padding: AppPaddings.cardPaddingCompact,
                decoration: BoxDecoration(
                  color: ext.subtleCardBg,
                  borderRadius: AppPaddings.radiusMd,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: AppPaddings.rXl,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      child: Text(
                        profile.initials,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AppPaddings.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.fullName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              AppPaddings.hGapSm,
                              Container(
                                padding: AppPaddings.badgePadding,
                                decoration: BoxDecoration(
                                  color: profile.isFrozen
                                      ? ext.rejectedRed
                                      : colorScheme.primaryContainer,
                                  borderRadius: AppPaddings.radiusSm,
                                ),
                                child: Text(
                                  profile.isFrozen
                                      ? 'BLOKE / DONDURULDU'
                                      : profile.role.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: profile.isFrozen
                                        ? colorScheme.onError
                                        : colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            '${profile.unvan} • Sicil No: ${profile.kurumSicilNo} • Derece: ${profile.derecekademe}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (profile.isFrozen) ...[
                AppPaddings.vGapMd,
                Container(
                  padding: AppPaddings.cardPaddingCompact,
                  decoration: BoxDecoration(
                    color: ext.rejectedRed,
                    borderRadius: AppPaddings.radiusMd,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.gpp_bad_outlined,
                        color: colorScheme.onError,
                        size: AppPaddings.iconLg,
                      ),
                      AppPaddings.hGapSm,
                      Expanded(
                        child: Text(
                          'MASAK / TEFTİŞ KURULU TEDBİRİ: Hesabınız Başmüfettişlik tarafından dondurulmuştur. Para transferi ve avans işlemleri kısıtlıdır.',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              AppPaddings.vGapMd,

              // 2. Vadesiz Kamu Maaş Hesabı Kartı
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: ext.shadowColor,
                      blurRadius: AppPaddings.lg,
                      offset: const Offset(0, AppPaddings.xxs),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: AppPaddings.iconMd,
                                color: colorScheme.primary,
                              ),
                              AppPaddings.hGapSm,
                              Expanded(
                                child: Text(
                                  AppStrings.salaryAccountTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: cubit.toggleBalanceVisibility,
                          tooltip: 'Bakiyeyi Gizle/Göster',
                          icon: Icon(
                            state.isBalanceHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: colorScheme.primary,
                            size: AppPaddings.iconMd,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${AppStrings.branchName} • ${profile.formattedIban}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppPaddings.vGapMd,
                    Text(
                      'Kullanılabilir Kamu Maaş Bakiyesi',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppPaddings.vGapXxs,
                    Text(
                      state.isBalanceHidden
                          ? '•••••••• ₺'
                          : ProfileModel.formatCurrency(
                              profile.balance,
                              showDecimals: true,
                            ),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppPaddings.vGapMd,
                    const Divider(),
                    AppPaddings.vGapSm,
                    // Hızlı İşlem Butonları (Para Transferi / ATM Karekod / Maaş Avansı)
                    Wrap(
                      spacing: AppPaddings.sm,
                      runSpacing: AppPaddings.xs,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            cubit.setTransferModeTab(1);
                            cubit.setBottomNavIndex(1);
                          },
                          icon: const Icon(
                            Icons.swap_horiz,
                            size: AppPaddings.iconSm,
                          ),
                          label: const Text('Para Transferi'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _openAtmQrSheet(context, profile),
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            size: AppPaddings.iconSm,
                          ),
                          label: const Text('ATM Karekod'),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            cubit.setTransferModeTab(0);
                            cubit.setBottomNavIndex(1);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                          icon: const Icon(
                            Icons.payments_outlined,
                            size: AppPaddings.iconSm,
                          ),
                          label: const Text('Maaş Avansı'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // 3. ÖZEL MEMUR MODÜLÜ: Ayın 15'i Maaş Yatış Sayacı + E-Bordro Gör
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ext.headerGradientStart, ext.headerGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppPaddings.radiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: ext.shadowColor,
                      blurRadius: AppPaddings.md,
                      offset: const Offset(0, AppPaddings.xxs),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_available,
                                color: colorScheme.secondaryContainer,
                                size: AppPaddings.iconMd,
                              ),
                              AppPaddings.hGapSm,
                              Expanded(
                                child: Text(
                                  AppStrings.salaryCountdownTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppPaddings.hGapSm,
                        Container(
                          padding: AppPaddings.chipPadding,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: AppPaddings.radiusFull,
                          ),
                          child: Text(
                            daysLeft == 0
                                ? 'BUGÜN MAAŞ GÜNÜ!'
                                : '$daysLeft Gün Kaldı',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppPaddings.vGapSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.salaryTargetNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppPaddings.hGapSm,
                        Text(
                          '%$progressPercent Dönem Tamamlandı',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    AppPaddings.vGapSm,
                    ClipRRect(
                      borderRadius: AppPaddings.radiusFull,
                      child: LinearProgressIndicator(
                        value: state.salaryCycleProgress,
                        minHeight: AppPaddings.progressHeight,
                        backgroundColor: colorScheme.onPrimary.withValues(
                          alpha: 0.22,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.secondary,
                        ),
                      ),
                    ),
                    AppPaddings.vGapMd,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tahmini Net Maaş + Seyyanen Fark',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primaryContainer,
                                ),
                              ),
                              Text(
                                ProfileModel.formatCurrency(
                                  profile.estimatedNetSalary,
                                  showDecimals: true,
                                ),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _openPayrollSheet(context, profile),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.onPrimary.withValues(
                              alpha: 0.18,
                            ),
                            foregroundColor: colorScheme.onPrimary,
                            padding: AppPaddings.buttonPaddingCompact,
                          ),
                          icon: const Icon(
                            Icons.receipt_long_outlined,
                            size: AppPaddings.iconSm,
                          ),
                          label: const Text('Bordro Gör'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // 4. Kamu Personeline Özel %0 Faizli Maaş Avansı Kampanya Kartı
              Container(
                padding: AppPaddings.cardPaddingCompact,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.secondary),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: AppPaddings.allSm,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: AppPaddings.radiusMd,
                      ),
                      child: Icon(
                        Icons.percent_rounded,
                        color: colorScheme.onSecondaryContainer,
                        size: AppPaddings.iconLg,
                      ),
                    ),
                    AppPaddings.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEMURA ÖZEL %0 FAİZLİ 15.000 ₺ AVANS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Maaş gününü beklemeden anında çekin, 15\'inde masrafsız mahsup edilsin.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppPaddings.hGapSm,
                    FilledButton(
                      onPressed: () {
                        cubit.setAdvanceAmountInput('15000', fromPreset: true);
                        cubit.setTransferModeTab(0);
                        cubit.setBottomNavIndex(1);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: AppPaddings.buttonPaddingCompact,
                      ),
                      child: const Text('Hemen Kullan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
