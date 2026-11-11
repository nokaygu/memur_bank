import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bank_cubit.dart';
import '../../constants/app_paddings.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';

/// Kurumsal Giriş Ekranı Üst Karşılama Bloğu ve Sicil No + Şifre Giriş Formu Kartı (`%100 const StatelessWidget`).
class LoginFormHeaderCard extends StatelessWidget {
  const LoginFormHeaderCard({super.key});

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
                        AppStrings.appLogoAsset,
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

              // Kurum Sicil No & Şifre ile Giriş Kartı
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

/// `LoginScreen` üzerinde `PinnedHeaderSliver` içinde kullanılan yapışkan demo hesap seçici başlığı.
class DemoAccountsPinnedHeader extends StatelessWidget {
  const DemoAccountsPinnedHeader({super.key});

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
