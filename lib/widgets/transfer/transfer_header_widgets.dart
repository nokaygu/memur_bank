import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';

/// Transfer ve Avans ekranı üst başlık ve bakiye özet kartı (`TransferHeroBanner`),
/// yapışkan mod seçici başlık (`TransferModePinnedHeader`) ve hızlı tutar çipi (`AmountPresetChip`).
class TransferHeroBanner extends StatelessWidget {
  const TransferHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final profile = state.activeProfile;

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Container(
            padding: AppPaddings.cardPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ext.headerGradientStart, ext.headerGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppPaddings.radiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Kamu Personeli Finans Merkezi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppPaddings.hGapSm,
                    Container(
                      padding: AppPaddings.badgePadding,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: AppPaddings.radiusFull,
                      ),
                      child: Text(
                        '%0 Faizli Avans',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                AppPaddings.vGapXs,
                Text(
                  'Aktif Hesap: ${profile.fullName} (${profile.kurumSicilNo}) • Bakiye: ${ProfileModel.formatCurrency(profile.balance, showDecimals: true)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (profile.isFrozen) ...[
                  AppPaddings.vGapSm,
                  Container(
                    padding: AppPaddings.allSm,
                    decoration: BoxDecoration(
                      color: ext.rejectedRed,
                      borderRadius: AppPaddings.radiusMd,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.onError,
                          size: AppPaddings.iconMd,
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Text(
                            'Bu hesap Başmüfettişlik tarafından dondurulmuştur! Transfer ve avans işlemleri kısıtlıdır.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onError,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

class TransferModePinnedHeader extends StatelessWidget {
  const TransferModePinnedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();

        return Container(
          color: colorScheme.surface,
          padding: AppPaddings.pinnedHeaderPadding,
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => cubit.setTransferModeTab(0),
                  style: FilledButton.styleFrom(
                    backgroundColor: state.transferModeTab == 0
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    foregroundColor: state.transferModeTab == 0
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimaryContainer,
                    padding: AppPaddings.buttonPaddingCompact,
                  ),
                  icon: const Icon(
                    Icons.request_quote_outlined,
                    size: AppPaddings.iconSm,
                  ),
                  label: const Text('Maaş Avansı / Kredi'),
                ),
              ),
              AppPaddings.hGapSm,
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => cubit.setTransferModeTab(1),
                  style: FilledButton.styleFrom(
                    backgroundColor: state.transferModeTab == 1
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    foregroundColor: state.transferModeTab == 1
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimaryContainer,
                    padding: AppPaddings.buttonPaddingCompact,
                  ),
                  icon: const Icon(
                    Icons.send_outlined,
                    size: AppPaddings.iconSm,
                  ),
                  label: const Text('Memura Para Transferi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AmountPresetChip extends StatelessWidget {
  final String amountText;
  final bool isAdvance;

  const AmountPresetChip({
    super.key,
    required this.amountText,
    required this.isAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final currentVal = isAdvance
            ? state.advanceAmountInput
            : state.transferAmountInput;
        final isSelected = currentVal == amountText;
        final numVal = double.tryParse(amountText) ?? 0.0;

        return InkWell(
          onTap: () {
            if (isAdvance) {
              cubit.setAdvanceAmountInput(amountText, fromPreset: true);
            } else {
              cubit.setTransferAmountInput(amountText, fromPreset: true);
            }
          },
          borderRadius: AppPaddings.radiusMd,
          child: Container(
            padding: AppPaddings.chipPadding,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.primaryContainer,
              borderRadius: AppPaddings.radiusMd,
            ),
            child: Text(
              '+${ProfileModel.formatCurrency(numVal)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }
}
