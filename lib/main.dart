import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:investapas/presentation/bloc/login/login_bloc.dart';
import 'package:investapas/presentation/bloc/option_chain/option_chain_bloc.dart';
import 'package:investapas/presentation/bloc/profile/profile_bloc.dart';
import 'package:investapas/presentation/bloc/setup_challenge/challenge_bloc.dart';
import 'package:investapas/presentation/bloc/splash/splash_bloc.dart';
import 'package:investapas/presentation/bloc/stock_details/stock_details_bloc.dart';
import 'package:investapas/presentation/bloc/technical/technical_bloc.dart';
import 'package:investapas/presentation/bloc/trading_journal/journal_bloc.dart';
import 'package:investapas/presentation/bloc/trading_terminal/terminal_bloc.dart';
import 'package:investapas/presentation/bloc/orders/order_bloc.dart';
import 'package:investapas/presentation/bloc/watchlist/watchlist_bloc.dart';
import 'package:investapas/presentation/bloc/demo/demo_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'core/constants/app_config.dart';
import 'core/constants/local/app_local.dart';
import 'core/services/free_unlock_timer_service.dart';
import 'core/services/demo_mode_service.dart';
import 'core/utils/navigationService.dart';
import 'core/utils/shared_prefs_helper.dart';
import 'presentation/bloc/dashboard/bloc.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';
import 'presentation/bloc/theme/bloc.dart';
import 'routes/appRoutes.dart';
import 'Widgets/free_unlock_timer_bar.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await EasyLocalization.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  await FreeUnlockTimerService.instance.init(); // restore persisted timer
  DemoModeService.instance.init();              // restore demo mode toggle
  await NotificationService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

/// Main App
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _prefs = SharedPrefsHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _prefs.saveLastActiveTime();
    } else if (state == AppLifecycleState.resumed) {
      _checkSessionOnResume();
    }
  }

  Future<void> _checkSessionOnResume() async {
    final isAuthenticated = await _prefs.getAuthenticationStatus();
    if (!isAuthenticated) return;

    final freeUnlockActive = FreeUnlockTimerService.instance.isActive;
    final withinSession    = await _prefs.isWithinQuickUnlockWindow();
    if (!freeUnlockActive && !withinSession) {
      final hasPinSet = await _prefs.hasPinSet();
      NavigatorService.pushNamedAndRemoveUntil(
        hasPinSet ? AppRoutes.appLockPage : AppRoutes.loginPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Locale> languages = kAppLanguages.map((lang) => lang.locale).toList();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: OKToast(
        child: EasyLocalization(
           path: AppConfig.languageAssetPath,
            supportedLocales: languages,
              fallbackLocale: enLocale,
            startLocale: enLocale,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => ThemeBloc()..add(GetThemeEvent())),
              BlocProvider(create: (context) => SplashBloc()),
              BlocProvider(create: (context) => LoginBloc()),
              BlocProvider(create: (context) => DashBoardBloc()),
              BlocProvider(create: (context) => JournalBloc()),
              BlocProvider(create: (context) => TerminalBloc()),
              BlocProvider(create: (context) => ChallengeBloc()),
              BlocProvider(create: (_) => WatchlistBloc()),
              BlocProvider(create: (_) => ProfileBloc()),
              BlocProvider(create: (_) => StockDetailsBloc()),
              BlocProvider(create: (_) => TechnicalBloc()),
              BlocProvider(create: (_) => OptionChainBloc()),
              BlocProvider(create: (_) => OrderBloc()),
              BlocProvider(create: (_) => WalletBloc()),
              BlocProvider(create: (_) => DemoBloc()),
            ],
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return MaterialApp(
                  navigatorKey: NavigatorService.navigatorKey,
                  debugShowCheckedModeBanner: false,
                  theme: state.themeData,
                  themeMode: ThemeMode.light,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,

                  onGenerateRoute: AppRoutes.generateRoute,
                  initialRoute: AppRoutes.initialRoute,

                  // ── Global FREE-unlock timer bar ──────────────────────────
                  // Renders above every route so the countdown is always visible.
                  builder: (ctx, child) => Column(
                    children: [
                      const FreeUnlockTimerBar(),
                      Expanded(child: child!),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
