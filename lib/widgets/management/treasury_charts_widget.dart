import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';

/// Merkez Bankası / Hazine İstatistikleri bileşeni.
/// Bankadaki toplam mevduat hacmi, dağıtılan krediler ve unvan/memur bazlı dağılım grafiklerini gösterir.
class TreasuryChartsWidget extends StatelessWidget {
  const TreasuryChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final totalDeposits = state.totalDepositVolume;
        final approvedCredits = state.totalApprovedCreditVolume;
        final pendingCredits = state.totalPendingCreditVolume;
        final totalPool = totalDeposits + approvedCredits + pendingCredits;
        final depositRatio = totalPool > 0
            ? (totalDeposits / totalPool).clamp(0.1, 0.9)
            : 0.7;

        final maxOfficerBalance = state.profiles.isEmpty
            ? 1.0
            : state.profiles
                  .map((p) => p.balance)
                  .reduce((a, b) => a > b ? a : b);

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Konsolide Hazine & Merkez Bankası Likidite Kartı
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.outline),
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
                                color: colorScheme.primary,
                                size: AppPaddings.iconLg,
                              ),
                              AppPaddings.hGapSm,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'T.C. Hazine & Merkez Bankası Havuzu',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Protokol No: MB-77401-TC • Canlı Telemetri',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppPaddings.hGapSm,
                        Container(
                          padding: AppPaddings.badgePadding,
                          decoration: BoxDecoration(
                            color: ext.approvedGreen.withValues(alpha: 0.15),
                            borderRadius: AppPaddings.radiusFull,
                          ),
                          child: Text(
                            'AKTİF',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ext.approvedGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppPaddings.vGapMd,
                    Text(
                      'TOPLAM KAMU MEVDUAT HACMİ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppPaddings.vGapXxs,
                    Text(
                      ProfileModel.formatCurrency(totalDeposits),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppPaddings.vGapMd,

                    // Mevduat vs Kredi Hacmi Karşılaştırma Kutuları
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: AppPaddings.cardPaddingCompact,
                            decoration: BoxDecoration(
                              color: ext.subtleCardBg,
                              borderRadius: AppPaddings.radiusMd,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dağıtılan Kredi/Avans',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AppPaddings.vGapXxs,
                                Text(
                                  ProfileModel.formatCurrency(approvedCredits),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: ext.approvedGreen,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Container(
                            padding: AppPaddings.cardPaddingCompact,
                            decoration: BoxDecoration(
                              color: ext.subtleCardBg,
                              borderRadius: AppPaddings.radiusMd,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Onay Bekleyen Hacim',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AppPaddings.vGapXxs,
                                Text(
                                  ProfileModel.formatCurrency(pendingCredits),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: ext.pendingAmber,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppPaddings.vGapMd,

                    // Likidite Dağılım Oranı Çubuğu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Mevduat Karşılık Oranı (%${(depositRatio * 100).round()})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppPaddings.hGapXs,
                        Flexible(
                          child: Text(
                            'Kredi/Avans (%${((1 - depositRatio) * 100).round()})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    AppPaddings.vGapXs,
                    ClipRRect(
                      borderRadius: AppPaddings.radiusFull,
                      child: LinearProgressIndicator(
                        value: depositRatio,
                        minHeight: AppPaddings.progressHeight,
                        backgroundColor: colorScheme.secondary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // 2. Memur / Unvan Bazlı Mevduat Sütun Grafiği
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: colorScheme.primary,
                          size: AppPaddings.iconMd,
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Text(
                            'Memur & Unvan Bazlı Mevduat Grafiği',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    AppPaddings.vGapMd,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: state.profiles.map((officer) {
                        final ratio = maxOfficerBalance > 0
                            ? (officer.balance / maxOfficerBalance).clamp(
                                0.15,
                                1.0,
                              )
                            : 0.2;
                        return Expanded(
                          child: Padding(
                            padding: AppPaddings.allXxs,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(officer.balance / 1000).toStringAsFixed(0)}B ₺',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AppPaddings.vGapXs,
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final barWidth =
                                        constraints.maxWidth <
                                            AppPaddings.chartBarWidth
                                        ? constraints.maxWidth
                                        : AppPaddings.chartBarWidth;
                                    return Container(
                                      width: barWidth,
                                      height:
                                          AppPaddings.chartBarMaxHeight * ratio,
                                      decoration: BoxDecoration(
                                        color: officer.isFrozen
                                            ? ext.rejectedRed
                                            : (officer.isAdmin
                                                  ? colorScheme.secondary
                                                  : colorScheme.primary),
                                        borderRadius: AppPaddings.radiusSm,
                                      ),
                                    );
                                  },
                                ),
                                AppPaddings.vGapXs,
                                Text(
                                  officer.fullName.split(' ').first,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  officer.unvan,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
