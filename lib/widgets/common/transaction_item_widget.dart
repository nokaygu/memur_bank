import 'package:flutter/material.dart';

import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../models/transaction_record_model.dart';
import '../../theme/app_theme.dart';

/// Hesap Hareketleri satırı ve tıklandığında açılan MemurBank Dijital İşlem Dekontu BottomSheet'i.
class TransactionItemWidget extends StatelessWidget {
  final TransactionRecord transaction;

  const TransactionItemWidget({super.key, required this.transaction});

  String _formatSignedAmount(double value, bool isIncoming) {
    final prefix = isIncoming ? '+' : '-';
    return '$prefix${ProfileModel.formatCurrency(value, showDecimals: true)}';
  }

  void _openDigitalReceipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
      child: SingleChildScrollView(
        padding: AppPaddings.bottomSheetPadding.add(
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: colorScheme.primary,
                        size: AppPaddings.iconLg,
                      ),
                      AppPaddings.hGapSm,
                      Expanded(
                        child: Text(
                          'MemurBank Dijital İşlem Dekontu',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          'İşlem Referans No:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AppPaddings.hGapSm,
                      Flexible(
                        child: Text(
                          transaction.referenceCode,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  AppPaddings.vGapXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kategori:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AppPaddings.hGapSm,
                      Flexible(
                        child: Text(
                          transaction.category,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  AppPaddings.vGapXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'İşlem Tutarı:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AppPaddings.hGapSm,
                      Text(
                        ProfileModel.formatCurrency(
                          transaction.amount,
                          showDecimals: true,
                        ),
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
