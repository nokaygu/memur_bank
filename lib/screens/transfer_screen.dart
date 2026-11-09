import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/request_card_widget.dart';

/// Memurlar Arası Para Transferi ve "Maaş Avansı / Memur Kredisi" Başvuru Ekranı.
/// Zorunlu `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` mimarisiyle kurulmuştur.
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();

        return RefreshIndicator(
          onRefresh: cubit.loadInitialData,
          child: CustomScrollView(
            slivers: [
              // 1. Üst Başlık ve Bakiye Özet Kartı
              const SliverToBoxAdapter(child: _TransferHeroBanner()),

              // 2. Yapışkan Sekme Seçici (Maaş Avansı Başvurusu vs Para Transferi)
              const PinnedHeaderSliver(child: _TransferModePinnedHeader()),

              // 3. Aktif Forma Göre İçerik Kartı
              const SliverToBoxAdapter(child: _TransferOrAdvanceFormSection()),

              // 4. Alt Liste: Son Başvurular (SliverList.builder ile)
              SliverList.builder(
                itemCount: state.filteredRequests.length,
                itemBuilder: (context, index) =>
                    RequestCardWidget(request: state.filteredRequests[index]),
              ),

              const SliverToBoxAdapter(child: AppPaddings.vGapXxxl),
            ],
          ),
        );
      },
    );
  }
}

class _TransferHeroBanner extends StatelessWidget {
  const _TransferHeroBanner();

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
                  'Aktif Hesap: ${profile.fullName} (${profile.kurumSicilNo}) • Bakiye: ${profile.balance.toStringAsFixed(0)} ₺',
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

class _TransferModePinnedHeader extends StatelessWidget {
  const _TransferModePinnedHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

class _TransferOrAdvanceFormSection extends StatelessWidget {
  const _TransferOrAdvanceFormSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        if (state.transferModeTab == 0) {
          return const _AdvanceApplicationCard();
        }
        return const _PeerTransferCard();
      },
    );
  }
}

class _AdvanceApplicationCard extends StatelessWidget {
  const _AdvanceApplicationCard();

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
                  'Seçilen tutar ve gerekçe doğrudan Kurum Mutemedi ve Bakanlık Başmüfettişi onay ekranına düşer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AppPaddings.vGapMd,

                // Hızlı Tutar Seçim Çipleri (Stitch UI Preset Chips)
                Text(
                  'Hızlı Tutar Seçimi (Seçili: ${state.advanceAmountInput} ₺)',
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
                        (preset) => _AmountPresetChip(
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
                  onChanged: cubit.setAdvanceAmountInput,
                  decoration: const InputDecoration(
                    labelText: 'Avans / Kredi Tutarı (₺)',
                    prefixIcon: Icon(Icons.currency_lira),
                  ),
                ),
                AppPaddings.vGapMd,

                // Geri Ödeme Planı Seçimi (Stitch UI maasavans_basvuru_ekran)
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
                                '3 x ${installment.toStringAsFixed(0)} ₺',
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
                  'Hızlı Gerekçe Şablonları',
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
                      onTap: () =>
                          cubit.setAdvanceReasonInput(reason, fromPreset: true),
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
                  onChanged: cubit.setAdvanceReasonInput,
                  decoration: const InputDecoration(
                    labelText: 'Başvuru Gerekçesi / Açıklama',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                AppPaddings.vGapMd,

                // Finansal Başvuru Özeti Kartı (Stitch UI)
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
                            'Faiz & Dosya Masrafı: 0,00 ₺ (Kamu Muafiyeti)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ext.approvedGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            state.repaymentPlanIndex == 0
                                ? 'Ayın 15\'inde Tek Seferde Mahsup'
                                : 'Aylık Taksit: ${installment.toStringAsFixed(0)} ₺ x 3 Ay',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${reqAmount.toStringAsFixed(0)} ₺',
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
                      : cubit.submitAdvanceRequest,
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

class _PeerTransferCard extends StatelessWidget {
  const _PeerTransferCard();

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
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: colorScheme.primary,
                                size: AppPaddings.iconMd,
                              ),
                              AppPaddings.hGapSm,
                              Expanded(
                                child: Text(
                                  '${person.fullName} • ${person.unvan} (${person.kurumSicilNo})',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${person.balance.toStringAsFixed(0)} ₺',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
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
                        (preset) => _AmountPresetChip(
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
                  onChanged: cubit.setTransferAmountInput,
                  decoration: InputDecoration(
                    labelText:
                        'Transfer Tutarı (Seçili: ${state.transferAmountInput} ₺)',
                    prefixIcon: const Icon(Icons.currency_lira),
                  ),
                ),
                AppPaddings.vGapMd,
                TextFormField(
                  initialValue: state.transferNoteInput,
                  onChanged: cubit.setTransferNoteInput,
                  decoration: const InputDecoration(
                    labelText: 'Transfer Açıklaması',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                AppPaddings.vGapLg,
                FilledButton.icon(
                  onPressed: state.isLoading ? null : cubit.submitMoneyTransfer,
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

class _AmountPresetChip extends StatelessWidget {
  final String amountText;
  final bool isAdvance;

  const _AmountPresetChip({required this.amountText, required this.isAdvance});

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
              '+$amountText ₺',
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
