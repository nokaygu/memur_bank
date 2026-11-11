import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';

/// Bakanlık Başmüfettişi Tanrı Modu (God Mode) ve Kurum Mutemedi Sicil Özeti BottomSheet bileşeni (`OfficerGodModeBottomSheet`).
class OfficerGodModeBottomSheet extends StatelessWidget {
  final String officerId;

  const OfficerGodModeBottomSheet({super.key, required this.officerId});

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
        final isViewerAdmin = state.activeProfile.isAdmin;
        final isProtectedTarget =
            officer.id == state.activeProfile.id || officer.isAdmin;

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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${officer.unvan} • Bakiye: ${ProfileModel.formatCurrency(officer.balance, showDecimals: true)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

                if (!isViewerAdmin) ...[
                  // Kurum Mutemedi (Manager) için Salt-Okunur Sicil & Bordro Özeti
                  Container(
                    padding: AppPaddings.cardPadding,
                    decoration: BoxDecoration(
                      color: ext.subtleCardBg,
                      borderRadius: AppPaddings.radiusMd,
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KURUM MUTEMETLİĞİ SİCİL & MAAŞ ÖZETİ',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        AppPaddings.vGapXs,
                        Text(
                          'Kurum: ${officer.institutionName}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'Derece / Kademe: ${officer.derecekademe}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'Maaş IBAN: ${officer.formattedIban}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          'Tahmini Net Maaş: ${ProfileModel.formatCurrency(officer.estimatedNetSalary, showDecimals: true)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPaddings.vGapSm,
                  Container(
                    padding: AppPaddings.cardPaddingCompact,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppPaddings.radiusMd,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_person_outlined,
                          color: colorScheme.onPrimaryContainer,
                          size: AppPaddings.iconMd,
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Text(
                            'Bilgi: Tanrı Modu müdahale yetkileri (Promosyon Gönder, Rol Ata, MASAK Hesap Dondur) yalnızca Bakanlık Başmüfettişi (Admin) rolüne açıktır.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPaddings.vGapMd,
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      padding: AppPaddings.buttonPadding,
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tamam'),
                  ),
                ] else ...[
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

                  // 3. Rol / Unvan Değiştir (Başmüfettiş kendi rolünü düşüremez)
                  OutlinedButton.icon(
                    onPressed: isProtectedTarget
                        ? null
                        : () {
                            cubit.toggleOfficerManagerRole(officer);
                            Navigator.of(context).pop();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: AppPaddings.buttonPadding,
                    ),
                    icon: const Icon(Icons.military_tech_outlined),
                    label: Text(
                      isProtectedTarget
                          ? 'Başmüfettiş (Admin) Rolü Değiştirilemez'
                          : (officer.role == 'user'
                                ? 'Rol / Unvan Değiştir (Müdür / Mutemet Yap)'
                                : 'Rol / Unvan Değiştir (Standart Memur Yap)'),
                    ),
                  ),
                  AppPaddings.vGapSm,

                  // 4. Şüpheli Hesabı Dondur / Bloke Kaldır (Başmüfettiş kendi hesabını donduramaz)
                  FilledButton.icon(
                    onPressed: isProtectedTarget
                        ? null
                        : () {
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
                      isProtectedTarget
                          ? 'Başmüfettiş (Admin) Hesabı Dondurulamaz'
                          : (officer.isFrozen
                                ? 'Hesap Blokesini Kaldır (Aktifleştir)'
                                : 'Şüpheli Hesabı Dondur (MASAK Bloke)'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
