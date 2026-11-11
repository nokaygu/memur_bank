import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';
import 'transfer_header_widgets.dart';

/// Memurlar Arası Anlık FAST Para Transferi Kartı (`PeerTransferCard`).
class PeerTransferCard extends StatelessWidget {
  const PeerTransferCard({super.key});

  void _submitAndUnfocus(BankCubit cubit) {
    FocusManager.instance.primaryFocus?.unfocus();
    cubit.submitMoneyTransfer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final recipients = state.transferRecipients;

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Container(
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
                    Icon(
                      Icons.bolt,
                      color: colorScheme.primary,
                      size: AppPaddings.iconLg,
                    ),
                    AppPaddings.hGapSm,
                    Expanded(
                      child: Text(
                        'Memurlar Arası Anlık FAST Para Transferi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!state.fastInstantConfirmEnabled) ...[
                  AppPaddings.vGapSm,
                  Container(
                    padding: AppPaddings.cardPaddingCompact,
                    decoration: BoxDecoration(
                      color: ext.pendingAmber,
                      borderRadius: AppPaddings.radiusMd,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_clock_outlined,
                          color: colorScheme.onSecondary,
                          size: AppPaddings.iconMd,
                        ),
                        AppPaddings.hGapSm,
                        Expanded(
                          child: Text(
                            'FAST Kolay Adres transfer yetkiniz şu an kapalıdır. Profil sekmesinden tek tıkla açabilirsiniz.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                AppPaddings.vGapMd,
                Text(
                  'Alıcı Kamu Personelini Seçin:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppPaddings.vGapXs,
                Column(
                  children: recipients.map((person) {
                    final isSelected = state.selectedRecipientId == person.id;
                    return Padding(
                      padding: AppPaddings.allXxs,
                      child: InkWell(
                        onTap: () => cubit.setSelectedRecipientId(person.id),
                        borderRadius: AppPaddings.radiusMd,
                        child: Container(
                          padding: AppPaddings.cardPaddingCompact,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : ext.subtleCardBg,
                            borderRadius: AppPaddings.radiusMd,
                            border: Border.all(
                              color: person.isFrozen
                                  ? ext.rejectedRed
                                  : (isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: person.isFrozen
                                    ? ext.rejectedRed
                                    : colorScheme.primary,
                                size: AppPaddings.iconMd,
                              ),
                              AppPaddings.hGapSm,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${person.fullName} • ${person.unvan} (${person.kurumSicilNo})',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (person.isFrozen)
                                      Text(
                                        'BLOKE HESAP (MASAK / Teftiş Tedbiri - Transfer Yapılamaz)',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: ext.rejectedRed,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                ProfileModel.formatCurrency(person.balance),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: person.isFrozen
                                      ? ext.rejectedRed
                                      : colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppPaddings.vGapMd,
                Wrap(
                  spacing: AppPaddings.sm,
                  runSpacing: AppPaddings.xs,
                  children: const ['1000', '2500', '5000', '10000']
                      .map(
                        (preset) => AmountPresetChip(
                          amountText: preset,
                          isAdvance: false,
                        ),
                      )
                      .toList(),
                ),
                AppPaddings.vGapMd,
                TextFormField(
                  key: ValueKey('trf-amount-${state.formPresetVersion}'),
                  initialValue: state.transferAmountInput,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setTransferAmountInput,
                  decoration: InputDecoration(
                    labelText:
                        'Transfer Tutarı (Seçili: ${state.transferAmountInput} ₺)',
                    prefixIcon: const Icon(Icons.currency_lira),
                  ),
                ),
                AppPaddings.vGapMd,
                TextFormField(
                  key: ValueKey('trf-note-${state.formPresetVersion}'),
                  initialValue: state.transferNoteInput,
                  textInputAction: TextInputAction.done,
                  onChanged: cubit.setTransferNoteInput,
                  onFieldSubmitted: (_) => _submitAndUnfocus(cubit),
                  decoration: InputDecoration(
                    labelText: 'Transfer Açıklaması',
                    prefixIcon: const Icon(Icons.notes_outlined),
                    suffixIcon: state.transferNoteInput.isNotEmpty
                        ? IconButton(
                            tooltip: 'Açıklamayı Temizle',
                            onPressed: () => cubit.setTransferNoteInput(
                              '',
                              fromPreset: true,
                            ),
                            icon: const Icon(
                              Icons.cancel_outlined,
                              size: AppPaddings.iconMd,
                            ),
                          )
                        : null,
                  ),
                ),
                AppPaddings.vGapLg,
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _submitAndUnfocus(cubit),
                  style: FilledButton.styleFrom(
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Anında FAST Transferi Gönder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
