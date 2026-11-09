import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../models/advance_request_model.dart';
import '../theme/app_theme.dart';

/// `SliverList.builder` içinde kullanılan avans/kredi talebi kartı.
/// Yönetici (`manager`) veya Başmüfettiş (`admin`) için bekleyen taleplerde
/// Yeşil "Onayla" ve Kırmızı "Reddet" butonlarını gösterir.
class RequestCardWidget extends StatelessWidget {
  final AdvanceRequestModel request;

  const RequestCardWidget({super.key, required this.request});

  String _formatAmount(double value) {
    final whole = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final rev = whole.length - i;
      buffer.write(whole[i]);
      if (rev > 1 && rev % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()},00 ₺';
  }

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Talep Edilen Maaş Avansı / Kredi',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            _formatAmount(request.amount),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Geri Ödeme Planı',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            'Ayın 15\'i Maaştan Mahsup',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                          label: const Text('Reddet'),
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
                          label: const Text('Onayla & Bakiyeye Ekle'),
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

/// Hesap Hareketleri satırı ve tıklandığında açılan MemurBank Dijital İşlem Dekontu BottomSheet'i.
class TransactionItemWidget extends StatelessWidget {
  final TransactionRecord transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  String _formatSignedAmount(double value, bool isIncoming) {
    final whole = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final rev = whole.length - i;
      buffer.write(whole[i]);
      if (rev > 1 && rev % 3 == 1) {
        buffer.write('.');
      }
    }
    final prefix = isIncoming ? '+' : '-';
    return '$prefix${buffer.toString()},00 ₺';
  }

  void _openDigitalReceipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppPaddings.bottomSheetRadius,
      ),
      builder: (_) => _DigitalReceiptBottomSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    final amountColor = transaction.isIncoming
        ? ext.approvedGreen
        : ext.rejectedRed;

    return Padding(
      padding: AppPaddings.cardMargin,
      child: InkWell(
        onTap: () => _openDigitalReceipt(context),
        borderRadius: AppPaddings.radiusLg,
        child: Container(
          padding: AppPaddings.cardPaddingCompact,
          decoration: BoxDecoration(
            color: ext.cardContainerBg,
            borderRadius: AppPaddings.radiusLg,
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                padding: AppPaddings.allSm,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.14),
                  borderRadius: AppPaddings.radiusMd,
                ),
                child: Icon(
                  transaction.isIncoming
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: amountColor,
                  size: AppPaddings.iconMd,
                ),
              ),
              AppPaddings.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppPaddings.vGapXxs,
                    Text(
                      '${transaction.subtitle} • Dekont: ${transaction.referenceCode}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppPaddings.hGapSm,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatSignedAmount(
                      transaction.amount,
                      transaction.isIncoming,
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  AppPaddings.vGapXxs,
                  Text(
                    'Dekont Gör',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
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

class _DigitalReceiptBottomSheet extends StatelessWidget {
  final TransactionRecord transaction;

  const _DigitalReceiptBottomSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return SafeArea(
      child: Padding(
        padding: AppPaddings.bottomSheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: colorScheme.primary,
                      size: AppPaddings.iconLg,
                    ),
                    AppPaddings.hGapSm,
                    Text(
                      'MemurBank Dijital İşlem Dekontu',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            AppPaddings.vGapSm,
            Container(
              padding: AppPaddings.cardPadding,
              decoration: BoxDecoration(
                color: ext.subtleCardBg,
                borderRadius: AppPaddings.radiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppPaddings.vGapXxs,
                  Text(
                    transaction.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppPaddings.vGapMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İşlem Referans No:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        transaction.referenceCode,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  AppPaddings.vGapXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kategori:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        transaction.category,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  AppPaddings.vGapXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İşlem Tutarı:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${transaction.amount.toStringAsFixed(0)},00 ₺',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: transaction.isIncoming
                              ? ext.approvedGreen
                              : ext.rejectedRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppPaddings.vGapMd,
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(padding: AppPaddings.buttonPadding),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Dekontu Kapat'),
            ),
          ],
        ),
      ),
    );
  }
}
