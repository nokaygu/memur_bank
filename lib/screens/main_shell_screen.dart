import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bank_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../constants/app_paddings.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/role_switcher_bar.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'management_panel_screen.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';
import 'transfer_screen.dart';

/// Yöntem A & Yöntem C + Splash & Login Yönlendirici:
/// - `isSplashVisible == true` ise `SplashScreen` gösterir.
/// - `isAuthenticated == false` ise `LoginScreen` gösterir.
/// - `isUsingFallback == true` ise en üstte kalıcı `FallbackModeStickyBanner` gösterir.
/// - Oturum açıkken üst barda "Rol Değiştir (Test)" + Tema + Oturumu Kapat butonları ve
///   alt barda role göre 3 (`user`) veya 4 (`manager` / `admin` -> `Teftiş/Yönetim`) dinamik sekme gösterir.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<MemurBankThemeExtension>()!;

    return BlocConsumer<BankCubit, BankState>(
      listenWhen: (previous, current) =>
          previous.feedbackMessage != current.feedbackMessage &&
          current.feedbackMessage != null,
      listener: (context, state) {
        final msg = state.feedbackMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: state.isErrorFeedback
                  ? ext.rejectedRed
                  : ext.approvedGreen,
              content: Text(
                msg,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      builder: (context, state) {
        if (state.isSplashVisible) {
          return const SplashScreen();
        }
        if (!state.isAuthenticated) {
          return const LoginScreen();
        }

        final cubit = context.read<BankCubit>();
        final profile = state.activeProfile;
        final hasManagementTab = profile.isAdminOrManager;

        final screens = <Widget>[
          const HomeScreen(),
          const TransferScreen(),
          const ProfileScreen(),
          if (hasManagementTab) const ManagementPanelScreen(),
        ];

        final activeIndex = state.bottomNavIndex >= screens.length
            ? 0
            : state.bottomNavIndex;

        final navItems = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            activeIcon: Icon(Icons.account_balance),
            label: AppStrings.navHome,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: AppStrings.navTransfer,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge),
            label: AppStrings.navProfile,
          ),
          if (hasManagementTab)
            BottomNavigationBarItem(
              icon: Icon(
                profile.isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.verified_user_outlined,
              ),
              activeIcon: Icon(
                profile.isAdmin
                    ? Icons.admin_panel_settings
                    : Icons.verified_user,
              ),
              label: AppStrings.navManagement,
            ),
        ];

        return Scaffold(
          appBar: AppBar(
            titleSpacing: AppPaddings.md,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: AppPaddings.radiusSm,
                  child: Image.asset(
                    'stitch_ui/memurbank_resmi_logo/screen.png',
                    width: AppPaddings.avatarSm,
                    height: AppPaddings.avatarSm,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.account_balance,
                      size: AppPaddings.iconLg,
                    ),
                  ),
                ),
                AppPaddings.hGapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.appBarTheme.foregroundColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${profile.fullName} • ${profile.role.toUpperCase()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.appBarTheme.foregroundColor?.withValues(
                            alpha: 0.85,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Yöntem C: Üst barda tek tıkla Rol Değiştir (Test) butonu
              Padding(
                padding: AppPaddings.allXxs,
                child: FilledButton.tonalIcon(
                  onPressed: cubit.cycleTestRole,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: AppPaddings.buttonPaddingCompact,
                  ),
                  icon: const Icon(
                    Icons.switch_account_outlined,
                    size: AppPaddings.iconSm,
                  ),
                  label: const Text(AppStrings.devRoleSwitchTitle),
                ),
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
              IconButton(
                onPressed: cubit.logout,
                tooltip: 'Güvenli Çıkış (Oturumu Kapat)',
                icon: const Icon(Icons.logout_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              const FallbackModeStickyBanner(),
              Expanded(
                child: Stack(
                  children: [
                    screens[activeIndex],
                    if (state.isLoading)
                      const Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: activeIndex,
            onTap: cubit.setBottomNavIndex,
            items: navItems,
          ),
        );
      },
    );
  }
}
