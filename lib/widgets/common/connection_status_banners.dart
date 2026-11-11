import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../theme/app_theme.dart';

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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  padding: AppPaddings.chipPadding,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
