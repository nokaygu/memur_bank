import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';
import 'officer_god_mode_bottom_sheet.dart';

/// `SliverList.builder` içinde kullanılan memur satırı bileşeni (`OfficerCardWidget`).
class OfficerCardWidget extends StatelessWidget {
  final ProfileModel officer;

  const OfficerCardWidget({super.key, required this.officer});

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
        child: OfficerGodModeBottomSheet(officerId: officer.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final isViewerAdmin = state.activeProfile.isAdmin;

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
                  color: officer.isFrozen
                      ? ext.rejectedRed
                      : colorScheme.outline,
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
                                                : colorScheme
                                                      .onPrimaryContainer),
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
                            ProfileModel.formatCurrency(officer.balance),
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
                                isViewerAdmin
                                    ? Icons.touch_app_outlined
                                    : Icons.info_outline,
                                size: AppPaddings.iconXs,
                                color: isViewerAdmin
                                    ? colorScheme.secondary
                                    : colorScheme.primary,
                              ),
                              AppPaddings.hGapXxs,
                              Text(
                                isViewerAdmin ? 'Tanrı Modu' : 'Sicil Özeti',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isViewerAdmin
                                      ? colorScheme.secondary
                                      : colorScheme.primary,
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
      },
    );
  }
}
