import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';

/// Yöntem B: Sadece Admin (Başmüfettiş) ve Manager (Kurum Mutemedi) rollerinin
/// ana sayfada bakiye kartının hemen altında gördüğü özel kırmızı/vurgulu Teftiş Kurulu Kartı.
class AdminDashboardCard extends StatelessWidget {
  const AdminDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        if (!state.activeProfile.isAdminOrManager) {
          return const SizedBox.shrink();
        }

        final pendingCount = state.pendingRequests.length;
        final isAdmin = state.activeProfile.isAdmin;
        final cubit = context.read<BankCubit>();

        return Padding(
          padding: AppPaddings.pageHorizontal,
          child: Container(
            padding: AppPaddings.cardPadding,
            decoration: BoxDecoration(
              color: ext.adminCardBg,
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
                  children: [
                    Icon(
                      isAdmin ? Icons.gpp_maybe : Icons.verified_user,
                      color: ext.onAdminCard,
                      size: AppPaddings.iconLg,
                    ),
                    AppPaddings.hGapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdmin
                                ? 'Teftiş Kurulu Paneli (Bekleyen $pendingCount kredi onayı var)'
                                : 'Kurum Mutemedi Paneli ($pendingCount bekleyen avans)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: ext.onAdminCard,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            isAdmin
                                ? 'Bakanlık Başmüfettişi Tanrı Modu (God Mode) Yetkileri Aktif'
                                : 'Mutemetlik Onay Havuzu ve Ayın 15\'i Toplu Maaş Dağıtım Yetkisi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ext.onAdminCard.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: AppPaddings.badgePadding,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: AppPaddings.radiusSm,
                      ),
                      child: Text(
                        isAdmin ? AppStrings.godModeBadge : 'MUTEMET',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                AppPaddings.vGapMd,
                Wrap(
                  spacing: AppPaddings.sm,
                  runSpacing: AppPaddings.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          cubit.openManagementPanel(subTabIndex: 0),
                      style: FilledButton.styleFrom(
                        backgroundColor: ext.onAdminCard,
                        foregroundColor: ext.adminCardBg,
                        padding: AppPaddings.buttonPaddingCompact,
                      ),
                      icon: const Icon(
                        Icons.rule_folder_outlined,
                        size: AppPaddings.iconSm,
                      ),
                      label: Text('Onay Bekleyenler ($pendingCount)'),
                    ),
                    if (isAdmin)
                      FilledButton.icon(
                        onPressed: () =>
                            cubit.openManagementPanel(subTabIndex: 1),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                          padding: AppPaddings.buttonPaddingCompact,
                        ),
                        icon: const Icon(
                          Icons.supervisor_account,
                          size: AppPaddings.iconSm,
                        ),
                        label: const Text('Tanrı Modu: Memurlar'),
                      ),
                    FilledButton.icon(
                      onPressed: cubit.distributeMonthlySalaries,
                      style: FilledButton.styleFrom(
                        backgroundColor: ext.approvedGreen,
                        foregroundColor: colorScheme.onPrimary,
                        padding: AppPaddings.buttonPaddingCompact,
                      ),
                      icon: const Icon(
                        Icons.play_circle_outline,
                        size: AppPaddings.iconSm,
                      ),
                      label: const Text('Ayın 15\'i Toplu Maaş Dağıt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
