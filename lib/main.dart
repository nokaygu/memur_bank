import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bloc/bank_cubit.dart';
import 'bloc/theme_cubit.dart';
import 'constants/app_strings.dart';
import 'screens/main_shell_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseService = SupabaseService();

  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.maybeGet('SUPABASE_URL') ?? '';
    final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

    if (url.isNotEmpty &&
        anonKey.isNotEmpty &&
        !url.contains('your-project-id')) {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      supabaseService.markInitialized(true);
    }
  } catch (_) {
    // .env veya bağlantı yoksa yerel Fallback (4 memur + 2 bekleyen avans) devreye girer.
    supabaseService.markInitialized(false);
  }

  runApp(
    MemurBankApp(
      supabaseService: supabaseService,
      showSplash: true,
      startAuthenticated: false,
    ),
  );
}

class MemurBankApp extends StatelessWidget {
  final SupabaseService supabaseService;
  final bool showSplash;
  final bool startAuthenticated;

  const MemurBankApp({
    super.key,
    required this.supabaseService,
    this.showSplash = false,
    this.startAuthenticated = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<BankCubit>(
          create: (_) => BankCubit(
            supabaseService,
            showSplash: showSplash,
            startAuthenticated: startAuthenticated,
          )..loadInitialData(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const MainShellScreen(),
          );
        },
      ),
    );
  }
}
