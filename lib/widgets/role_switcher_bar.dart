import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

/// Yöntem C: Geliştirici Hızlı Rol Değiştirme (`user` -> `manager` -> `admin`)
/// ve Admin Key ile `reset_memur_bank` RPC tetikleyen kontrol bileşeni.
class RoleSwitcherBar extends StatelessWidget {
  final bool showResetButton;

  const RoleSwitcherBar({super.key, this.showResetButton = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final currentRole = state.activeProfile.role;

        return Container(
          padding: AppPaddings.cardPadding,
          decoration: BoxDecoration(
            color: ext.cardContainerBg,
            borderRadius: AppPaddings.radiusLg,
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.developer_mode,
                        size: AppPaddings.iconMd,
                        color: colorScheme.primary,
                      ),
                      AppPaddings.hGapSm,
                      Text(
                        'Geliştirici Test Araçları (Yöntem C)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: cubit.cycleTestRole,
                    icon: const Icon(
                      Icons.swap_horizontal_circle_outlined,
                      size: AppPaddings.iconSm,
                    ),
                    label: const Text(AppStrings.devRoleSwitchTitle),
                  ),
                ],
              ),
              AppPaddings.vGapSm,
              Row(
                children: [
                  Expanded(
                    child: _RoleOptionButton(
                      label: 'Memur (user)',
                      subtitle: 'Ahmet Yılmaz',
                      isSelected: currentRole == 'user',
                      onTap: () => cubit.switchRoleTo('user'),
                    ),
                  ),
                  AppPaddings.hGapXs,
                  Expanded(
                    child: _RoleOptionButton(
                      label: 'Mutemet (manager)',
                      subtitle: 'Mehmet Kaya',
                      isSelected: currentRole == 'manager',
                      onTap: () => cubit.switchRoleTo('manager'),
                    ),
                  ),
                  AppPaddings.hGapXs,
                  Expanded(
                    child: _RoleOptionButton(
                      label: 'Müfettiş (admin)',
                      subtitle: 'Kemal Bey',
                      isSelected: currentRole == 'admin',
                      onTap: () => cubit.switchRoleTo('admin'),
                    ),
                  ),
                ],
              ),
              if (showResetButton) ...[
                AppPaddings.vGapMd,
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : cubit.resetDatabaseAndReload,
                  style: FilledButton.styleFrom(
                    backgroundColor: ext.rejectedRed,
                    foregroundColor: colorScheme.onError,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text(AppStrings.resetDbButtonLabel),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RoleOptionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppPaddings.radiusMd,
      child: Container(
        padding: AppPaddings.allSm,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: AppPaddings.radiusMd,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppPaddings.vGapXxs,
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary.withValues(alpha: 0.85)
                    : colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
