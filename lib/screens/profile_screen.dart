import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/role_switcher_bar.dart';

/// Memur Kimliği, IBAN & Kurum Bilgileri, Güvenlik Ayarları, Aydınlık/Koyu Tema,
/// Hızlı Rol Değiştirici (Yöntem C), Veritabanı Sıfırlama ve Güvenli Çıkış (Logout) Ekranı.
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
              child: _ProfileIdentityAndSettingsSection(),
            ),

            // 2. Yapışkan Başlık: Sistemdeki Demo Memur Profilleri (Hızlı Geçiş)
            const PinnedHeaderSliver(child: _ProfileSwitchPinnedHeader()),

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
                                '${officer.balance.toStringAsFixed(0)} ₺',
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

class _ProfileIdentityAndSettingsSection extends StatelessWidget {
  const _ProfileIdentityAndSettingsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final profile = state.activeProfile;
        final cubit = context.read<BankCubit>();

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dijital Kamu Personeli Kimlik Kartı
              Container(
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
                      children: [
                        CircleAvatar(
                          radius: AppPaddings.rXxl,
                          backgroundColor: colorScheme.onPrimary,
                          foregroundColor: colorScheme.primary,
                          child: Text(
                            profile.initials,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        AppPaddings.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'T.C. KAMU PERSONELİ DİJİTAL KİMLİĞİ',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.secondaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              AppPaddings.vGapXxs,
                              Text(
                                profile.fullName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${profile.unvan} • ${profile.kurumSicilNo} • ${profile.derecekademe}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primaryContainer,
                                  fontWeight: FontWeight.w600,
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
                        color: colorScheme.onPrimary.withValues(alpha: 0.14),
                        borderRadius: AppPaddings.radiusMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${profile.institutionName} (${profile.roleDisplayTitle})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.verified_outlined,
                            color: colorScheme.secondaryContainer,
                            size: AppPaddings.iconMd,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // 2. Kamu Maaş IBAN & Kopyalama Kartı
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      color: colorScheme.primary,
                      size: AppPaddings.iconLg,
                    ),
                    AppPaddings.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resmi Kamu Maaş IBAN Numarası',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            profile.formattedIban,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: profile.formattedIban),
                        );
                        cubit.notifyCopiedIban(profile.formattedIban);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: AppPaddings.buttonPaddingCompact,
                      ),
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: AppPaddings.iconSm,
                      ),
                      label: const Text('Kopyala'),
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // 3. Aydınlık & Koyu Tema ve Güvenlik Tercihleri
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  children: [
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        final isDark = themeMode == ThemeMode.dark;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isDark
                                        ? Icons.dark_mode_outlined
                                        : Icons.light_mode_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  AppPaddings.hGapMd,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDark
                                              ? 'Merkez Bankası Gece Paleti (Dark)'
                                              : 'Kamu & Halkbank Güven Paleti (Light)',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        Text(
                                          'Tek tıkla görünüm modunu değiştirin',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isDark,
                              onChanged: (_) =>
                                  context.read<ThemeCubit>().toggleTheme(),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Hazine KEP & SMS Maaş Bildirimleri',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Switch(
                          value: state.kepNotificationsEnabled,
                          onChanged: cubit.toggleKepNotifications,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'FAST Kolay Adres (Sicil No ile Transfer)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Switch(
                          value: state.fastInstantConfirmEnabled,
                          onChanged: cubit.toggleFastInstantConfirm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // 4. Yöntem C: Geliştirici Hızlı Rol Değiştirme & Veritabanını Sıfırla ve Demo Verileri Kur
              const RoleSwitcherBar(showResetButton: true),
              AppPaddings.vGapMd,

              // 5. Güvenli Çıkış (Oturumu Kapat -> LoginScreen)
              OutlinedButton.icon(
                onPressed: cubit.logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ext.rejectedRed,
                  padding: AppPaddings.buttonPadding,
                ),
                icon: const Icon(Icons.logout_outlined),
                label: const Text(
                  'Güvenli Çıkış Yap (Kurumsal Giriş Ekranına Dön)',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileSwitchPinnedHeader extends StatelessWidget {
  const _ProfileSwitchPinnedHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: AppPaddings.pinnedHeaderPadding,
      child: Row(
        children: [
          Icon(
            Icons.people_alt_outlined,
            color: colorScheme.primary,
            size: AppPaddings.iconMd,
          ),
          AppPaddings.hGapSm,
          Expanded(
            child: Text(
              'Kayıtlı Kamu Personeli Hesapları (${AppStrings.appName})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
