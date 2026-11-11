import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../bloc/theme_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';
import '../common/role_switcher_bar.dart';

/// `ProfileScreen` üst bölümünde yer alan Memur Dijital Kimlik Kartı, IBAN Kopyalama,
/// Aydınlık/Koyu Tema, Güvenlik Tercihleri, Test Araçları ve Güvenli Çıkış bileşeni.
class ProfileIdentityAndSettingsSection extends StatelessWidget {
  const ProfileIdentityAndSettingsSection({super.key});

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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'T.C. KAMU PERSONELİ DİJİTAL KİMLİĞİ',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.secondaryContainer,
                                            fontWeight: FontWeight.w800,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const ConnectionStatusBadge(),
                                ],
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

/// `ProfileScreen` üzerinde `PinnedHeaderSliver` içinde kullanılan yapışkan memur hesapları başlığı.
class ProfileSwitchPinnedHeader extends StatelessWidget {
  const ProfileSwitchPinnedHeader({super.key});

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
