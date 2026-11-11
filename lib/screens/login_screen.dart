import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common/connection_status_banners.dart';
import '../widgets/login/login_form_header_card.dart';

/// Kamu Personeli Kurumsal Giriş Ekranı (`LoginScreen`).
/// Zorunlu `CustomScrollView` + `const SliverToBoxAdapter` + `const PinnedHeaderSliver` + `SliverList.builder` mimarisiyle kurulmuştur.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: AppPaddings.radiusSm,
              child: Image.asset(
                AppStrings.appLogoAsset,
                width: AppPaddings.avatarSm,
                height: AppPaddings.avatarSm,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_balance, size: AppPaddings.iconLg),
              ),
            ),
            AppPaddings.hGapSm,
            const Flexible(
              child: Text(
                'MemurBank Kurumsal Giriş',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          const Padding(
            padding: AppPaddings.allXxs,
            child: ConnectionStatusBadge(),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return IconButton(
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                tooltip: 'Aydınlık / Koyu Tema Değiştir',
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const FallbackModeStickyBanner(),
          Expanded(
            child: BlocBuilder<BankCubit, BankState>(
              builder: (context, state) {
                final cubit = context.read<BankCubit>();

                return CustomScrollView(
                  slivers: [
                    // 1. Üst Kurumsal Giriş Formu (Kurum Sicil No + Şifre ile Doğrulama)
                    const SliverToBoxAdapter(child: LoginFormHeaderCard()),

                    // 2. Yapışkan Başlık: Hızlı Demo Memur Seçici (3 Rol Testi)
                    const PinnedHeaderSliver(
                      child: DemoAccountsPinnedHeader(),
                    ),

                    // 3. Tek Tıkla Demo Memur / Mutemet / Başmüfettiş Giriş Kartları (SliverList.builder)
                    SliverList.builder(
                      itemCount: state.profiles.length,
                      itemBuilder: (context, index) {
                        final officer = state.profiles[index];

                        return Padding(
                          padding: AppPaddings.cardMargin,
                          child: InkWell(
                            onTap: () => cubit.loginAsProfile(officer),
                            borderRadius: AppPaddings.radiusLg,
                            child: Container(
                              padding: AppPaddings.cardPadding,
                              decoration: BoxDecoration(
                                color: ext.cardContainerBg,
                                borderRadius: AppPaddings.radiusLg,
                                border: Border.all(
                                  color: officer.isAdmin
                                      ? colorScheme.secondary
                                      : colorScheme.outline,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: AppPaddings.rXl,
                                    backgroundColor: officer.isAdmin
                                        ? ext.adminCardBg
                                        : colorScheme.primaryContainer,
                                    foregroundColor: officer.isAdmin
                                        ? ext.onAdminCard
                                        : colorScheme.onPrimaryContainer,
                                    child: Text(
                                      officer.initials,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: officer.isAdmin
                                                ? ext.onAdminCard
                                                : colorScheme
                                                      .onPrimaryContainer,
                                          ),
                                    ),
                                  ),
                                  AppPaddings.hGapMd,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                officer.fullName,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            AppPaddings.hGapXs,
                                            Container(
                                              padding: AppPaddings.badgePadding,
                                              decoration: BoxDecoration(
                                                color: officer.isAdmin
                                                    ? colorScheme.secondary
                                                    : colorScheme
                                                          .primaryContainer,
                                                borderRadius:
                                                    AppPaddings.radiusSm,
                                              ),
                                              child: Text(
                                                officer.role.toUpperCase(),
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: officer.isAdmin
                                                          ? colorScheme
                                                                .onSecondary
                                                          : colorScheme
                                                                .onPrimaryContainer,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        AppPaddings.vGapXxs,
                                        Text(
                                          '${officer.unvan} • Sicil: ${officer.kurumSicilNo} • Şifre: ${officer.password} • ${ProfileModel.formatCurrency(officer.balance)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () =>
                                        cubit.loginAsProfile(officer),
                                    style: FilledButton.styleFrom(
                                      padding: AppPaddings.buttonPaddingCompact,
                                    ),
                                    icon: const Icon(
                                      Icons.login,
                                      size: AppPaddings.iconSm,
                                    ),
                                    label: const Text('Giriş'),
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
            ),
          ),
        ],
      ),
    );
  }
}
