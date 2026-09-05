
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/data/models/market_item.dart';
import 'package:investapas/data/models/portfolio_position.dart';
import 'package:investapas/presentation/bloc/buy/buy_bloc.dart';
import 'package:investapas/presentation/bloc/sell/sell_bloc.dart';
import 'package:investapas/presentation/pages/buy/buy_page.dart';
import 'package:investapas/presentation/pages/login/consent_webview_page.dart';
import 'package:investapas/presentation/pages/login/login_screen.dart';
import 'package:investapas/data/models/news_model.dart';
import 'package:investapas/presentation/pages/news_details/news_detail_page.dart';
import 'package:investapas/presentation/pages/option_chain/option_chain_page.dart';
import 'package:investapas/presentation/pages/orders/order_page.dart';
import 'package:investapas/presentation/pages/sell/sell_page.dart';
import 'package:investapas/presentation/pages/setup_challenge/setup_challenge_screen.dart';
import 'package:investapas/presentation/pages/splash/splash_screen.dart';
import 'package:investapas/presentation/pages/stock_details/stock_detail_page.dart';
import 'package:investapas/presentation/pages/watchlist/watchlist_page.dart';
import '../presentation/pages/challenge_history/challenge_history_page.dart';
import '../presentation/pages/dashBoard/dashboard_page.dart';
import '../presentation/pages/position/position_page.dart';
import '../presentation/pages/noInternet/page.dart';
import '../presentation/bloc/wallet/wallet_bloc.dart';
import '../presentation/pages/wallet/wallet_page.dart';
import '../presentation/bloc/demo/demo_bloc.dart';
import '../presentation/pages/demo/demo_page.dart';
import '../presentation/pages/user_manual/user_manual_page.dart';
import '../presentation/pages/support_portal/support_portal_page.dart';
import '../presentation/pages/contact_us/contact_us_page.dart';
import '../presentation/pages/app_lock/setup_pin_page.dart';
import '../presentation/pages/app_lock/app_lock_page.dart';
import '../presentation/pages/market/market_page.dart';

/// app routes
class AppRoutes {
  AppRoutes._();
/// initial route
  static const String initialRoute = '/';
  /// no internet page
  static const String noInternet = '/noInternet';
  ///login page
  static const String loginPage = '/login';
  ///home page
  static const String homePage = '/home';
  ///setup challenge page
  static const String setupChallengePage = '/setupChallengePage';
  ///position page
  static const String positionPage = '/positionPage';
  ///watchlist page
  static const String watchListPage = '/watchListPage';
  /// product order page
  static const String orderPage = '/orderPage';
  /// stock details page
  static const String stockDetailsPage = '/stockDetailsPage';
  /// option change page
  static const String optionChangePage = '/optionChangePage';
  /// news details page
  static const String newsDetailPage = '/newsDetailPage';
  /// buy page
  static const String buyPage = '/buyPage';
  /// sell page
  static const String sellPage = '/sellPage';
  /// login webview page
  static const String loginWebviewPage    = '/loginWebviewPage';
  static const String challengeHistoryPage = '/challengeHistoryPage';
  static const String walletPage           = '/walletPage';
  static const String demoPage             = '/demoPage';
  static const String userManualPage        = '/userManualPage';
  static const String supportPortalPage    = '/supportPortalPage';
  static const String contactUsPage        = '/contactUsPage';
  static const String setupPinPage         = '/setupPinPage';
  static const String appLockPage          = '/appLockPage';
  static const String marketPage           = '/marketPage';


  /// Generates a route based on the given [RouteSettings].
  ///
  /// The [settings] parameter contains the name of the route to be generated.
  /// The function returns a [Route] object that represents the generated route.
  ///
  /// The function uses a switch statement to determine the type of route to be generated based on the [settings.name].
  /// If the [settings.name] is equal to [initialRoute], it returns a [MaterialPageRoute] that builds a [const AuthBuilder].
   /// If the [settings.name] does not match any of the above cases, it returns a [MaterialPageRoute] that builds a [Scaffold] with a [Center] widget displaying the text 'Unknown route: ${settings.name}'.
  ///
  /// Parameters:
  /// - `settings` (RouteSettings): The settings for the route to be generated.
  ///
  /// Returns:
  /// - `Route<dynamic>`: The generated route.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      
      case noInternet:
        return MaterialPageRoute(
          builder: (_) => const NoInternetPage(),
        );
      case loginPage:
        return MaterialPageRoute(
            builder: (_) => LoginScreen()
        );
      case homePage:
        return MaterialPageRoute(
            builder: (_) => DashBoardPage()
        );
      case setupChallengePage:
        return MaterialPageRoute(
            builder: (_) => SetupChallengeScreen()
        );
      case positionPage:
        return MaterialPageRoute(
            builder: (_) => PositionPage()
        );
      case watchListPage:
        return MaterialPageRoute(
            builder: (_) => WatchlistPage()
        );
      case orderPage:
        return MaterialPageRoute(
            builder: (_) => OrderPage()
        );
      case stockDetailsPage:
        if (settings.arguments is MarketItem) {
          return MaterialPageRoute(
            builder: (_) => StockDetailPage(marketItem: settings.arguments as MarketItem),
          );
        }
        return MaterialPageRoute(
          builder: (_) => StockDetailPage(position: settings.arguments as PortfolioPosition?),
        );
      case optionChangePage:
        return MaterialPageRoute(
            builder: (_) => OptionChainPage()
        );
      case newsDetailPage:
        final newsArg = settings.arguments is StockNews
            ? settings.arguments as StockNews
            : null;
        return MaterialPageRoute(
          builder: (_) => NewsDetailPage(news: newsArg),
        );
      case buyPage:
        final args = settings.arguments as Map<String, dynamic>?;
        final marketItem = args?["stockData"] as MarketItem?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => BuyBloc(),
            child: BuyPage(marketItem: marketItem),
          ),
        );
      case sellPage:
        final sellArgs = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => SellBloc(),
            child: SellPage(
              name: sellArgs?["name"] as String?,
              quantity: sellArgs?["quantity"] as int?,
              securityId: sellArgs?["securityId"] as String?,
              exchangeSegment: sellArgs?["exchangeSegment"] as String?,
              lotSize: sellArgs?["lotSize"] as int?,
            ),
          ),
        );
      case challengeHistoryPage:
        return MaterialPageRoute(
          builder: (_) => const ChallengeHistoryPage(),
        );

      case walletPage:
        return MaterialPageRoute(builder: (_) => const WalletPage());

      case demoPage:
        return MaterialPageRoute(
          builder: (ctx) => BlocProvider(
            create: (_) => DemoBloc(),
            child: const DemoPage(),
          ),
        );

      case userManualPage:
        return MaterialPageRoute(
          builder: (_) => const UserManualPage(),
        );

      case supportPortalPage:
        return MaterialPageRoute(
          builder: (_) => const SupportPortalPage(),
        );

      case contactUsPage:
        return MaterialPageRoute(
          builder: (_) => const ContactUsPage(),
        );

      case setupPinPage:
        return MaterialPageRoute(builder: (_) => const SetupPinPage());

      case appLockPage:
        return MaterialPageRoute(builder: (_) => const AppLockPage());

      case marketPage:
        return MaterialPageRoute(builder: (_) => const MarketPage());

      case loginWebviewPage:
        final args = settings.arguments as Map<String, dynamic>?;
        final webUrl = args?["url"] as String?;
        return MaterialPageRoute(
            builder: (_) => ConsentWebviewPage(url: webUrl!)
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Unknown route: ${settings.name}')),
          ),
        );
    }
  }
}
