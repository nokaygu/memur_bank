import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';

/// `SliverList.builder` içinde kullanılan memur satırı ve tıklandığında açılan
/// Bakanlık Başmüfettişi Tanrı Modu (God Mode) BottomSheet bileşeni.
class OfficerCardWidget extends StatelessWidget {
  final ProfileModel officer;

  const OfficerCardWidget({super.key, required this.officer});

  String _formatBalance(double value) {
    final whole = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final rev = whole.length - i;
      buffer.write(whole[i]);
      if (rev > 1 && rev % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()} ₺';
  }

  void _openGodModeBottomSheet(BuildContext context) {
    final cubit = context.read<BankCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppPaddings.bottomSheetRadius,
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _OfficerGodModeBottomSheet(officerId: officer.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return Padding(
      padding: AppPaddings.cardMargin,
      child: InkWell(
        onTap: () => _openGodModeBottomSheet(context),
        borderRadius: AppPaddings.radiusLg,
        child: Container(
          padding: AppPaddings.cardPadding,
          decoration: BoxDecoration(
            color: ext.cardContainerBg,
            borderRadius: AppPaddings.radiusLg,
            border: Border.all(
              color: officer.isFrozen ? ext.rejectedRed : colorScheme.outline,
            ),
            boxShadow: [
              BoxShadow(
                color: ext.shadowColor,
                blurRadius: AppPaddings.sm,
                offset: const Offset(0, AppPaddings.xxs),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: AppPaddings.rXl,
                    backgroundColor: officer.isFrozen
                        ? ext.rejectedRed
                        : colorScheme.primaryContainer,
                    foregroundColor: officer.isFrozen
                        ? colorScheme.onError
                        : colorScheme.onPrimaryContainer,
                    child: Text(
                      officer.initials,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: officer.isFrozen
                            ? colorScheme.onError
                            : colorScheme.onPrimaryContainer,
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
                                officer.fullName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AppPaddings.hGapXs,
                            Container(
                              padding: AppPaddings.badgePadding,
                              decoration: BoxDecoration(
                                color: officer.isFrozen
                                    ? ext.rejectedRed
                                    : (officer.isAdmin
                                          ? colorScheme.secondary
                                          : colorScheme.primaryContainer),
                                borderRadius: AppPaddings.radiusSm,
                              ),
                              child: Text(
                                officer.isFrozen
                                    ? 'DONDURULDU'
                                    : officer.role.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: officer.isFrozen
                                      ? colorScheme.onError
                                      : (officer.isAdmin
                                            ? colorScheme.onSecondary
                                            : colorScheme.onPrimaryContainer),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppPaddings.vGapXxs,
                        Text(
                          '${officer.unvan} • Sicil: ${officer.kurumSicilNo}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatBalance(officer.balance),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: officer.isFrozen
                              ? ext.rejectedRed
                              : colorScheme.primary,
                        ),
                      ),
                      AppPaddings.vGapXxs,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: AppPaddings.iconXs,
                            color: colorScheme.secondary,
                          ),
                          AppPaddings.hGapXxs,
                          Text(
                            'Tanrı Modu',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficerGodModeBottomSheet extends StatelessWidget {
  final String officerId;

  const _OfficerGodModeBottomSheet({required this.officerId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final officer = state.profiles.firstWhere(
          (p) => p.id == officerId,
          orElse: () => state.activeProfile,
        );
        final cubit = context.read<BankCubit>();

        return SafeArea(
          child: Padding(
            padding: AppPaddings.bottomSheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: AppPaddings.rXl,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      child: Text(
                        officer.initials,
                        style: theme.textTheme.titleMedium?.copyWith(
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
                          Text(
                            '${officer.fullName} (${officer.kurumSicilNo})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${officer.unvan} • Bakiye: ${officer.balance.toStringAsFixed(0)} ₺',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                AppPaddings.vGapMd,
                const Divider(),
                AppPaddings.vGapSm,
                Text(
                  'BAKANLIK BAŞMÜFETTİŞİ TANRI MODU (GOD MODE) YETKİLERİ',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                AppPaddings.vGapMd,

                // 1. Promosyon Parası Gönder
                FilledButton.icon(
                  onPressed: () {
                    cubit.sendFundsToOfficer(
                      officer: officer,
                      amount: 12500.0,
                      label: 'Kurum Maaş Promosyonu',
                    );
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.card_giftcard_outlined),
                  label: const Text('Promosyon Parası Gönder (+12.500 ₺)'),
                ),
                AppPaddings.vGapSm,

                // 2. Maaş Yatır
                FilledButton.icon(
                  onPressed: () {
                    cubit.sendFundsToOfficer(
                      officer: officer,
                      amount: 45000.0,
                      label: 'Kamu Personeli Maaş Ödemesi',
                    );
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: ext.approvedGreen,
                    foregroundColor: colorScheme.onPrimary,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Maaş Yatır (+45.000 ₺)'),
                ),
                AppPaddings.vGapSm,

                // 3. Rol / Unvan Değiştir (Müdür Yap)
                OutlinedButton.icon(
                  onPressed: () {
                    cubit.toggleOfficerManagerRole(officer);
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.military_tech_outlined),
                  label: Text(
                    officer.role == 'user'
                        ? 'Rol / Unvan Değiştir (Müdür / Mutemet Yap)'
                        : 'Rol / Unvan Değiştir (Standart Memur Yap)',
                  ),
                ),
                AppPaddings.vGapSm,

                // 4. Şüpheli Hesabı Dondur / Bloke Kaldır
                FilledButton.icon(
                  onPressed: () {
                    cubit.toggleOfficerFreeze(officer);
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: officer.isFrozen
                        ? colorScheme.primary
                        : ext.rejectedRed,
                    foregroundColor: colorScheme.onError,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: Icon(
                    officer.isFrozen
                        ? Icons.lock_open_outlined
                        : Icons.ac_unit_outlined,
                  ),
                  label: Text(
                    officer.isFrozen
                        ? 'Hesap Blokesini Kaldır (Aktifleştir)'
                        : 'Şüpheli Hesabı Dondur (MASAK Bloke)',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
