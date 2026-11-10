import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

/// AppBar ve Profil ekranlarında o anki bağlantı durumunu (`Canlı Bulut` / `Yerel Demo`)
/// kompakt ve anlaşılır şekilde gösteren durum rozeti (`%100 const StatelessWidget`).
class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final isOffline = state.isUsingFallback;
        final badgeBg = isOffline ? ext.pendingAmber : ext.approvedGreen;

        return Tooltip(
          message: isOffline
              ? 'Yerel Fallback (Demo) Modu Aktif'
              : 'Supabase Canlı Bulut Veritabanı Bağlı',
          child: Container(
            padding: AppPaddings.badgePadding,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: AppPaddings.radiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOffline
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_done_outlined,
                  size: AppPaddings.iconXs,
                  color: colorScheme.onPrimary,
                ),
                AppPaddings.hGapXxs,
                Text(
                  isOffline ? 'Yerel Demo' : 'Canlı Bulut',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
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

/// Uygulama yerel Fallback (Demo) modunda çalışırken ekranların en üstünde (AppBar altında)
/// kalıcı olarak gösterilen uyarı bandı (`%100 const StatelessWidget`).
class FallbackModeStickyBanner extends StatelessWidget {
  const FallbackModeStickyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        if (!state.isUsingFallback) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<BankCubit>();

        return Container(
          width: double.infinity,
          padding: AppPaddings.pinnedHeaderPadding,
          decoration: BoxDecoration(
            color: ext.pendingAmber,
            border: Border(bottom: BorderSide(color: colorScheme.outline)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: AppPaddings.iconMd,
                color: colorScheme.onSecondary,
              ),
              AppPaddings.hGapSm,
              Expanded(
                child: Text(
                  '⚠️ YEREL FALLBACK (DEMO) MODU AKTİF — Supabase bağlantısı bulunamadı, işlemler geçici yerel bellek üzerinde çalışıyor.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AppPaddings.hGapSm,
              FilledButton.tonalIcon(
                onPressed: state.isLoading
                    ? null
                    : cubit.retrySupabaseConnection,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: AppPaddings.buttonPaddingCompact,
                ),
                icon: const Icon(Icons.sync, size: AppPaddings.iconXs),
                label: const Text('Yeniden Bağlan'),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
                      : () => _confirmAndResetDatabase(context, cubit),
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
