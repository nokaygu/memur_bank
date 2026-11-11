import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../theme/app_theme.dart';

/// Sisteme yeni kamu personeli (memur) ekleme BottomSheet penceresi (`AddNewOfficerBottomSheet`).
class AddNewOfficerBottomSheet extends StatelessWidget {
  const AddNewOfficerBottomSheet({super.key});

  Future<void> _submitNewOfficer(BuildContext context, BankCubit cubit) async {
    final success = await cubit.addNewOfficer();
    if (success && context.mounted) {
      Navigator.of(context).pop();
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
                      child: Text(
                        'Sisteme Yeni Kamu Personeli (Memur) Ekle',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (state.isErrorFeedback && state.feedbackMessage != null) ...[
                  AppPaddings.vGapXs,
                  Container(
                    padding: AppPaddings.cardPaddingCompact,
                    decoration: BoxDecoration(
                      color: ext.rejectedRed,
                      borderRadius: AppPaddings.radiusMd,
                    ),
                    child: Text(
                      state.feedbackMessage!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                AppPaddings.vGapMd,
                TextFormField(
                  key: ValueKey('new_officer_name_${state.formPresetVersion}'),
                  initialValue: state.newOfficerName,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerName,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad (Zorunlu)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey('new_officer_sicil_${state.formPresetVersion}'),
                  initialValue: state.newOfficerSicilNo,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerSicilNo,
                  decoration: const InputDecoration(
                    labelText: 'Kurum Sicil No (Zorunlu • Örn: MEB-2090)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey(
                    'new_officer_password_${state.formPresetVersion}',
                  ),
                  initialValue: state.newOfficerPassword,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerPassword,
                  decoration: const InputDecoration(
                    labelText: 'Giriş Şifresi (Zorunlu)',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey('new_officer_unvan_${state.formPresetVersion}'),
                  initialValue: state.newOfficerUnvan,
                  textInputAction: TextInputAction.next,
                  onChanged: cubit.setNewOfficerUnvan,
                  decoration: const InputDecoration(
                    labelText: 'Unvan (Örn: Uzman Tabip / Mühendis)',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                AppPaddings.vGapSm,
                TextFormField(
                  key: ValueKey(
                    'new_officer_balance_${state.formPresetVersion}',
                  ),
                  initialValue: state.newOfficerBalance,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: cubit.setNewOfficerBalance,
                  onFieldSubmitted: (_) => _submitNewOfficer(context, cubit),
                  decoration: const InputDecoration(
                    labelText: 'Başlangıç Maaş Bakiyesi (₺)',
                    prefixIcon: Icon(Icons.currency_lira),
                  ),
                ),
                AppPaddings.vGapLg,
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _submitNewOfficer(context, cubit),
                  style: FilledButton.styleFrom(
                    padding: AppPaddings.buttonPadding,
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Memuru Kaydet ve Hesabı Aç'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
