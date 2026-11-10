import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../constants/app_paddings.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/role_switcher_bar.dart';

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
                'stitch_ui/memurbank_resmi_logo/screen.png',
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
                    const SliverToBoxAdapter(child: _LoginFormHeaderCard()),

                    // 2. Yapışkan Başlık: Hızlı Demo Memur Seçici (3 Rol Testi)
                    const PinnedHeaderSliver(
                      child: _DemoAccountsPinnedHeader(),
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

class _LoginFormHeaderCard extends StatelessWidget {
  const _LoginFormHeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocBuilder<BankCubit, BankState>(
      builder: (context, state) {
        final cubit = context.read<BankCubit>();

        return Padding(
          padding: AppPaddings.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Karşılama Bloğu
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppPaddings.radiusMd,
                      child: Image.asset(
                        'stitch_ui/memurbank_resmi_logo/screen.png',
                        width: AppPaddings.logoLoginSize,
                        height: AppPaddings.logoLoginSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.account_balance,
                          size: AppPaddings.logoLoginSize,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    AppPaddings.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'T.C. Kamu Personeli Dijital Bankacılık',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          AppPaddings.vGapXxs,
                          Text(
                            'Kurum Sicil Numaranız ve Giriş Şifreniz ile güvenli kurumsal oturum açın.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppPaddings.vGapMd,

              // Kurum Sicil No & Şifre ile Giriş Kartı (Supabase `profiles.kurum_sicil_no` & `profiles.password`)
              Container(
                padding: AppPaddings.cardPadding,
                decoration: BoxDecoration(
                  color: ext.cardContainerBg,
                  borderRadius: AppPaddings.radiusLg,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kurum Sicil No & Şifre ile Güvenli Giriş',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppPaddings.vGapMd,
                    TextFormField(
                      key: ValueKey('login_sicil_${state.formPresetVersion}'),
                      initialValue: state.loginSicilInput,
                      textInputAction: TextInputAction.next,
                      onChanged: cubit.setLoginSicilInput,
                      decoration: const InputDecoration(
                        labelText: 'Kurum Sicil No (MEB-1042, EGM-8831, MAL-0092, MUF-0001)',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    AppPaddings.vGapMd,
                    TextFormField(
                      key: ValueKey(
                        'login_password_${state.formPresetVersion}',
                      ),
                      initialValue: state.loginPasswordInput,
                      obscureText: state.isLoginPasswordObscured,
                      textInputAction: TextInputAction.done,
                      onChanged: cubit.setLoginPasswordInput,
                      onFieldSubmitted: (_) => cubit.loginWithCredentials(),
                      decoration: InputDecoration(
                        labelText: 'Giriş Şifresi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: cubit.toggleLoginPasswordVisibility,
                          tooltip: 'Şifreyi Göster / Gizle',
                          icon: Icon(
                            state.isLoginPasswordObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    AppPaddings.vGapMd,
                    FilledButton.icon(
                      onPressed: cubit.loginWithCredentials,
                      style: FilledButton.styleFrom(
                        padding: AppPaddings.buttonPadding,
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('Sicil No ve Şifre ile Giriş Yap'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DemoAccountsPinnedHeader extends StatelessWidget {
  const _DemoAccountsPinnedHeader();

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
            Icons.bolt,
            color: colorScheme.secondary,
            size: AppPaddings.iconMd,
          ),
          AppPaddings.hGapSm,
          Expanded(
            child: Text(
              'Hızlı Demo Oturum Seçici (Tek Tıkla Rol Testi)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
