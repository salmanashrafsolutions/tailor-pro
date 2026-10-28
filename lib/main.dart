import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailor_pro/core/database/app_database.dart';
import 'package:tailor_pro/core/localization/locale_provider.dart';
import 'package:tailor_pro/core/theme/app_theme.dart';
import 'package:tailor_pro/features/business/providers/business_provider.dart';
import 'package:tailor_pro/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:tailor_pro/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  await AppDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: TailorProApp(),
    ),
  );
}

class TailorProApp extends ConsumerWidget {
  const TailorProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeProvider);
    final bizState = ref.watch(businessProvider);

    return MaterialApp(
      title: 'TailorPro | ٹیلر پرو',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: localeState.locale,
      supportedLocales: const [
        Locale('ur', 'PK'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: bizState.isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : bizState.businesses.isEmpty
              ? const OnboardingScreen()
              : const DashboardScreen(),
    );
  }
}

