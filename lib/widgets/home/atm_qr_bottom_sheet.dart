import 'package:flutter/material.dart';

import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';

/// Ortak Kamu ATM Karekod (QR) nakit çekim BottomSheet bileşeni (`%100 const StatelessWidget`).
class AtmQrBottomSheet extends StatelessWidget {
  final ProfileModel profile;

  const AtmQrBottomSheet({super.key, required this.profile});

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
                  child: Text(
                    'Ortak Kamu ATM Karekod (QR) İşlemi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              'Halkbank, Ziraat ve VakıfBank Ortak Kamu ATM\'lerinden kartsız nakit çekim için karekodunuz hazırdır.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AppPaddings.vGapLg,
            Center(
              child: Container(
                padding: AppPaddings.allLg,
                decoration: BoxDecoration(
                  color: ext.subtleCardBg,
                  borderRadius: AppPaddings.radiusXl,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: AppPaddings.qrCodeBoxSize,
                  color: colorScheme.primary,
                ),
              ),
            ),
            AppPaddings.vGapMd,
            Text(
              'Referans: KAMU-ATM-${profile.kurumSicilNo} • 90 Saniye Geçerli',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            AppPaddings.vGapLg,
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(padding: AppPaddings.buttonPadding),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
