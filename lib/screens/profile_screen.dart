import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../constants/app_paddings.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/profile/profile_identity_settings_section.dart';

/// Memur Kimliği, IBAN & Kurum Bilgileri, Güvenlik Ayarları, Aydınlık/Koyu Tema,
/// Hızlı Rol Değiştirici (Yöntem C), Veritabanı Sıfırlama ve Güvenli Çıkış (Logout) Ekranı (`ProfileScreen`).
/// Zorunlu `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` mimarisindedir.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();

        return CustomScrollView(
          slivers: [
            // 1. Üst Memur Dijital Kimlik Kartı, IBAN, Güvenlik, Tema ve Test Araçları
            const SliverToBoxAdapter(
              child: ProfileIdentityAndSettingsSection(),
            ),

            // 2. Yapışkan Başlık: Sistemdeki Demo Memur Profilleri (Hızlı Geçiş)
            const PinnedHeaderSliver(child: ProfileSwitchPinnedHeader()),

            // 3. Sistemdeki Tüm Memur Profilleri (Tıklayınca O Memura Geçer - SliverList.builder)
            SliverList.builder(
              itemCount: state.profiles.length,
              itemBuilder: (context, index) {
                final officer = state.profiles[index];
                final isCurrent = officer.id == state.activeProfile.id;

                return Padding(
                  padding: AppPaddings.cardMargin,
                  child: InkWell(
                    onTap: () => cubit.switchProfileById(officer.id),
                    borderRadius: AppPaddings.radiusLg,
                    child: Container(
                      padding: AppPaddings.cardPadding,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? colorScheme.primaryContainer
                            : ext.cardContainerBg,
                        borderRadius: AppPaddings.radiusLg,
                        border: Border.all(
                          color: isCurrent
                              ? colorScheme.primary
                              : colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: AppPaddings.rLg,
                            backgroundColor: isCurrent
                                ? colorScheme.primary
                                : colorScheme.secondaryContainer,
                            foregroundColor: isCurrent
                                ? colorScheme.onPrimary
                                : colorScheme.onSecondaryContainer,
                            child: Text(
                              officer.initials,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          AppPaddings.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${officer.fullName} (${officer.role.toUpperCase()})',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                AppPaddings.vGapXxs,
                                Text(
                                  '${officer.unvan} • Sicil: ${officer.kurumSicilNo}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                ProfileModel.formatCurrency(officer.balance),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              AppPaddings.vGapXxs,
                              Text(
                                isCurrent ? 'Aktif Oturum' : 'Hesaba Geç',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isCurrent
                                      ? ext.approvedGreen
                                      : colorScheme.secondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: AppPaddings.vGapXxxl),
          ],
        );
      },
    );
  }
}
