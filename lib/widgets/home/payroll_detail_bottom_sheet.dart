import 'package:flutter/material.dart';

import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';

/// T.C. Hazine E-Bordro Özeti BottomSheet bileşeni (`%100 const StatelessWidget`).
class PayrollDetailBottomSheet extends StatelessWidget {
  final ProfileModel profile;

  const PayrollDetailBottomSheet({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppPaddings.bottomSheetPadding.add(
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: colorScheme.primary,
                        size: AppPaddings.iconLg,
                      ),
                      AppPaddings.hGapSm,
                      Expanded(
                        child: Text(
                          'T.C. Hazine E-Bordro Özeti',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              '${profile.fullName} • ${profile.unvan} (${profile.kurumSicilNo})',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              profile.institutionName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppPaddings.vGapMd,
            const Divider(),
            AppPaddings.vGapSm,
            _PayrollRow(
              label: 'Brüt Taban Aylık & Gösterge',
              value: ProfileModel.formatCurrency(
                profile.estimatedGrossSalary,
                showDecimals: true,
              ),
            ),
            AppPaddings.vGapXs,
            _PayrollRow(
              label: 'Seyyanen İlave Ödeme & Tazminat',
              value:
                  '+${ProfileModel.formatCurrency(profile.estimatedSeyyanenBonus, showDecimals: true)}',
            ),
            AppPaddings.vGapXs,
            _PayrollRow(
              label: 'Gelir / Damga Vergisi & SGK Kesintisi',
              value:
                  '-${ProfileModel.formatCurrency(profile.estimatedTaxDeduction, showDecimals: true)}',
              isNegative: true,
            ),
            AppPaddings.vGapSm,
            const Divider(),
            AppPaddings.vGapSm,
            Container(
              padding: AppPaddings.cardPaddingCompact,
              decoration: BoxDecoration(
                color: ext.subtleCardBg,
                borderRadius: AppPaddings.radiusMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Ayın 15\'inde Yatacak Net Maaş',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AppPaddings.hGapSm,
                  Text(
                    ProfileModel.formatCurrency(
                      profile.estimatedNetSalary,
                      showDecimals: true,
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: ext.approvedGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _PayrollRow({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AppPaddings.hGapSm,
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isNegative ? ext.rejectedRed : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
