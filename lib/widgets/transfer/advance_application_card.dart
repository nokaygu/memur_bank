import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../models/profile_model.dart';
import '../../theme/app_theme.dart';
import 'transfer_header_widgets.dart';

/// Maaş Avansı / Memur Kredisi Başvuru Kartı (`AdvanceApplicationCard`).
class AdvanceApplicationCard extends StatelessWidget {
  const AdvanceApplicationCard({super.key});

  void _submitAndUnfocus(BankCubit cubit) {
    FocusManager.instance.primaryFocus?.unfocus();
    cubit.submitAdvanceRequest();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();
        final reqAmount = state.parsedAdvanceAmount;
        final installment = state.monthlyInstallmentAmount;

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
                      Icons.payments_outlined,
                      color: colorScheme.secondary,
                      size: AppPaddings.iconLg,
                    ),
                    AppPaddings.hGapSm,
                    Expanded(
                      child: Text(
                        'Maaş Avansı / Memur Kredisi Başvurusu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                AppPaddings.vGapXs,
                Text(
                  'Seçilen tutar ve gerekçe doğrudan Kurum Mutemedi ve Bakanlık Başmüfettişi onay ekranına düşer (Tek seferlik üst limit: 100.000 ₺).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppPaddings.vGapMd,

                // Hızlı Tutar Seçim Çipleri
                Text(
                  'Hızlı Tutar Seçimi (Seçili: ${ProfileModel.formatCurrency(reqAmount)})',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppPaddings.vGapXs,
                Wrap(
                  spacing: AppPaddings.sm,
                  runSpacing: AppPaddings.xs,
                  children: const ['5000', '10000', '15000', '25000', '35000']
                      .map(
                        (preset) => AmountPresetChip(
                          amountText: preset,
                          isAdvance: true,
                        ),
                      )
                      .toList(),
                ),
                AppPaddings.vGapMd,

                TextFormField(
                  key: ValueKey('adv-amount-${state.formPresetVersion}'),
                  initialValue: state.advanceAmountInput,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setAdvanceAmountInput,
                  decoration: const InputDecoration(
                    labelText: 'Avans / Kredi Tutarı (₺)',
                    prefixIcon: Icon(Icons.currency_lira),
                  ),
                ),
                AppPaddings.vGapMd,

                // Geri Ödeme Planı Seçimi
                Text(
                  'Geri Ödeme Tercihi',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppPaddings.vGapXs,
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => cubit.setRepaymentPlanIndex(0),
                        borderRadius: AppPaddings.radiusMd,
                        child: Container(
                          padding: AppPaddings.allSm,
                          decoration: BoxDecoration(
                            color: state.repaymentPlanIndex == 0
                                ? colorScheme.primaryContainer
                                : ext.subtleCardBg,
                            borderRadius: AppPaddings.radiusMd,
                            border: Border.all(
                              color: state.repaymentPlanIndex == 0
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ayın 15\'i Tek Sefer',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                '%0 Faiz • Masrafsız',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppPaddings.hGapSm,
                    Expanded(
                      child: InkWell(
                        onTap: () => cubit.setRepaymentPlanIndex(1),
                        borderRadius: AppPaddings.radiusMd,
                        child: Container(
                          padding: AppPaddings.allSm,
                          decoration: BoxDecoration(
                            color: state.repaymentPlanIndex == 1
                                ? colorScheme.primaryContainer
                                : ext.subtleCardBg,
                            borderRadius: AppPaddings.radiusMd,
                            border: Border.all(
                              color: state.repaymentPlanIndex == 1
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3 Eşit Taksitle Mahsup',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                              Text(
                                '3 x ${ProfileModel.formatCurrency(installment)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppPaddings.vGapMd,

                Text(
                  'Hızlı Gerekçe Şablonları (Seçmek veya Kaldırmak İçin Dokunun)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppPaddings.vGapXs,
                Wrap(
                  spacing: AppPaddings.xs,
                  runSpacing: AppPaddings.xs,
                  children: AppStrings.presetReasons.map((reason) {
                    final selected = state.advanceReasonInput == reason;
                    return InkWell(
                      onTap: () => cubit.setAdvanceReasonInput(
                        selected ? '' : reason,
                        fromPreset: true,
                      ),
                      borderRadius: AppPaddings.radiusFull,
                      child: Container(
                        padding: AppPaddings.chipPadding,
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.primaryContainer,
                          borderRadius: AppPaddings.radiusFull,
                        ),
                        child: Text(
                          reason,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: selected
                                ? colorScheme.onPrimary
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppPaddings.vGapMd,

                TextFormField(
                  key: ValueKey('adv-reason-${state.formPresetVersion}'),
                  initialValue: state.advanceReasonInput,
                  textInputAction: TextInputAction.done,
                  onChanged: cubit.setAdvanceReasonInput,
                  onFieldSubmitted: (_) => _submitAndUnfocus(cubit),
                  decoration: InputDecoration(
                    labelText: 'Başvuru Gerekçesi / Açıklama',
                    hintText: 'Örn: Okul dönemi eğitim harcaması...',
                    prefixIcon: const Icon(Icons.description_outlined),
                    suffixIcon: state.advanceReasonInput.isNotEmpty
                        ? IconButton(
                            tooltip: 'Gerekçeyi Temizle',
                            onPressed: () => cubit.setAdvanceReasonInput(
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
                AppPaddings.vGapMd,

                // Finansal Başvuru Özeti Kartı
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
                              'Faiz & Dosya Masrafı: 0,00 ₺ (Kamu Muafiyeti)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: ext.approvedGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              state.repaymentPlanIndex == 0
                                  ? 'Ayın 15\'inde Tek Seferde Mahsup'
                                  : 'Aylık Taksit: ${ProfileModel.formatCurrency(installment)} x 3 Ay',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        ProfileModel.formatCurrency(
                          reqAmount,
                          showDecimals: true,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                AppPaddings.vGapLg,

                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _submitAndUnfocus(cubit),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Maaş Avansı Başvurusunu Tamamla'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
