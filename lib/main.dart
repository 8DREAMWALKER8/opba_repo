import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opba_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/loan_provider.dart';

import 'services/api_service.dart';

import 'theme/app_theme.dart';
import 'utils/app_localizations.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/security_question_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_account_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/credit_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/transactions_screen.dart';

// Global navigatorKey: Notification popup’ı ekran bağımsız göstermek için
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const OpbaApp());
}

class OpbaApp extends StatelessWidget {
  const OpbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

        // Tek ApiService instance
        Provider<ApiService>(create: (_) => ApiService()),

        // Notifications
        ChangeNotifierProvider(
          create: (ctx) => NotificationProvider(
            api: ctx.read<ApiService>(),
            navigatorKey: rootNavigatorKey,
          ),
        ),

        // Budgets
        ChangeNotifierProvider<BudgetProvider>(
          create: (ctx) => BudgetProvider(ctx.read<ApiService>()),
        ),

        // Loans (aynı ApiService instance kullan)
        ChangeNotifierProvider(
          create: (ctx) =>
              LoanProvider(ctx.read<ApiService>())..fetchRates(currency: 'TRY'),
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            title: 'OPBA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(appProvider.language),
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/security-question': (context) => const SecurityQuestionScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/add-account': (context) => const AddAccountScreen(),
              '/expenses': (context) => const ExpensesScreen(),
              '/budget': (context) => const BudgetScreen(),
              '/credit': (context) => const CreditScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/privacy': (context) => const PrivacyScreen(),
              '/transactions': (context) => const ListTransactionScreen(),
            },
          );
        },
      ),
    );
  }
}
