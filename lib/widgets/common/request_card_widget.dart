import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../models/advance_request_model.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';

export 'transaction_item_widget.dart';

/// `SliverList.builder` içinde kullanılan avans/kredi talebi kartı.
/// Yönetici (`manager`) veya Başmüfettiş (`admin`) için bekleyen taleplerde
/// Yeşil "Onayla" ve Kırmızı "Reddet" butonlarını gösterir.
class RequestCardWidget extends StatelessWidget {
  final AdvanceRequestModel request;

  const RequestCardWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    final statusColor = request.isApproved
        ? ext.approvedGreen
        : (request.isRejected ? ext.rejectedRed : ext.pendingAmber);

    final statusIcon = request.isApproved
        ? Icons.check_circle_outline
        : (request.isRejected
              ? Icons.cancel_outlined
              : Icons.schedule_outlined);

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final canDecide =
            state.activeProfile.isAdminOrManager && request.isPending;
        final cubit = context.read<BankCubit>();

        return Padding(
          padding: AppPaddings.cardMargin,
          child: Container(
            padding: AppPaddings.cardPadding,
            decoration: BoxDecoration(
              color: ext.cardContainerBg,
              borderRadius: AppPaddings.radiusLg,
              border: Border.all(color: colorScheme.outline),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: AppPaddings.rLg,
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: Text(
                        request.fullName.isNotEmpty
                            ? request.fullName[0].toUpperCase()
                            : 'M',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    AppPaddings.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.fullName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            request.reason,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppPaddings.hGapSm,
                    Container(
                      padding: AppPaddings.badgePadding,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: AppPaddings.radiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: AppPaddings.iconXs,
                            color: statusColor,
                          ),
                          AppPaddings.hGapXxs,
                          Text(
                            request.statusLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppPaddings.vGapMd,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Talep Edilen Maaş Avansı / Kredi',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppPaddings.vGapXxs,
                            Text(
                              ProfileModel.formatCurrency(
                                request.amount,
                                showDecimals: true,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      AppPaddings.hGapSm,
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Geri Ödeme Planı',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppPaddings.vGapXxs,
                            Text(
                              'Ayın 15\'i Maaştan Mahsup',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDecide) ...[
                  AppPaddings.vGapMd,
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => cubit.processAdvanceRequest(
                            request: request,
                            approve: false,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: ext.rejectedRed,
                            foregroundColor: colorScheme.onError,
                            padding: AppPaddings.buttonPaddingCompact,
                          ),
                          icon: const Icon(
                            Icons.close,
                            size: AppPaddings.iconSm,
                          ),
                          label: const Text(
                            'Reddet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      AppPaddings.hGapSm,
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => cubit.processAdvanceRequest(
                            request: request,
                            approve: true,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: ext.approvedGreen,
                            foregroundColor: colorScheme.onPrimary,
                            padding: AppPaddings.buttonPaddingCompact,
                          ),
                          icon: const Icon(
                            Icons.check,
                            size: AppPaddings.iconSm,
                          ),
                          label: const Text(
                            'Onayla & Bakiyeye Ekle',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
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
