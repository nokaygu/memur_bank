import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';

export 'connection_status_banners.dart';

/// Yöntem C: Geliştirici Hızlı Rol Değiştirme (`user` -> `manager` -> `admin`)
/// ve Admin Key ile `reset_memur_bank` RPC tetikleyen kontrol bileşeni.
class RoleSwitcherBar extends StatelessWidget {
  final bool showResetButton;

  const RoleSwitcherBar({super.key, this.showResetButton = true});

  Future<void> _confirmAndResetDatabase(
    BuildContext context,
    BankCubit cubit,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ext.rejectedRed),
            AppPaddings.hGapSm,
            const Expanded(
              child: Text('Veritabanını Sıfırla ve Demo Verileri Kur'),
            ),
          ],
        ),
        content: Text(
          'Bu işlem tüm memur bakiyelerini, yeni eklenen profilleri ve avans başvurularını sıfırlayarak 4 varsayılan memur ve 2 bekleyen avans verisini yeniden kuracaktır. Onaylıyor musunuz?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ext.rejectedRed,
              foregroundColor: colorScheme.onError,
            ),
            icon: const Icon(Icons.restart_alt, size: AppPaddings.iconSm),
            label: const Text('Evet, Sıfırla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.resetDatabaseAndReload();
    }
  }

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
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Icon(
                          Icons.developer_mode,
                          size: AppPaddings.iconMd,
                          color: colorScheme.primary,
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Text(
                            'Geliştirici Test Araçları (Yöntem C)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPaddings.hGapXs,
                  Flexible(
                    flex: 2,
                    child: TextButton.icon(
                      onPressed: cubit.cycleTestRole,
                      style: TextButton.styleFrom(
                        padding: AppPaddings.chipPadding,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.swap_horizontal_circle_outlined,
                        size: AppPaddings.iconSm,
                      ),
                      label: const Text(
                        AppStrings.devRoleSwitchTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              AppPaddings.vGapSm,
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
              ),
              if (showResetButton) ...[
                AppPaddings.vGapMd,
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _confirmAndResetDatabase(context, cubit),
                  style: FilledButton.styleFrom(
                    backgroundColor: ext.rejectedRed,
                    foregroundColor: colorScheme.onError,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text(
                    AppStrings.resetDbButtonLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          mainAxisAlignment: MainAxisAlignment.center,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
