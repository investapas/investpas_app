class ApiEndpoints {
  // ═════════════════════════════════════════════════════════════════════════
  // UNIFIED TRADING ENDPOINTS (routes to both Dhan & Demo)
  // ═════════════════════════════════════════════════════════════════════════
  static const String buyOrderApi = "/api/trading/order";           // POST buy/sell order (auto-routes based on mode param)
  static const String modifyOrderApi = "/api/trading/modify-order"; // POST modify order
  static const String cancelOrderApi = "/api/trading/cancel-order"; // POST cancel order
  static const String portfolioApi = "/api/trading/portfolio";      // GET portfolio/positions
  static const String ordersApi = "/api/trading/orders";            // GET all orders
  static const String orderApi = "/api/trading/order";              // GET single order details

  // ═════════════════════════════════════════════════════════════════════════
  // LEGACY ENDPOINTS (kept for backward compatibility)
  // ═════════════════════════════════════════════════════════════════════════
  static const String generateConsentApi = "/dhan/generate-consent";
  static const String consumeConsentApi = "/dhan/consume-consent";
  static const String searchApi = "/dhan/search-stocks";
  static const String buySuperOrderApi = "/dhan/buy-super-order";
  static const String instrumentsApi = "/dhan/instruments";
  static const String tradeHistoryApi = "/dhan/trade-history";

  static const String challengeCreateApi = "/challenge/create";
  static const String challengeFetchApi = "/challenge/current";
  static const String challengeCheckOrderApi    = "/challenge/check-order";
  static const String challengeCompleteApi      = "/challenge/complete";
  static const String challengeHistoryApi       = "/challenge/history";
  static const String challengeQuickUnlockApi = "/challenge/quick-unlock";
  static const String challengeLogTradeApi = "/challenge/log-trade";
  static const String challengeRiskFrameworkApi = "/challenge/risk-framework";
  static const String challengeStyleDefaultsApi = "/challenge/style-defaults";
  static const String challengeDisciplineScoreApi = "/challenge/discipline-score";

  static const String profileApi = "/profile/";
  static const String profileUpdatePictureApi = "/profile/update-picture";
  static const String profileRemovePictureApi = "/profile/remove-picture";
  static const String profileUpdateFcmTokenApi = "/profile/fcm-token";
  static const String pinStatusApi    = "/profile/pin-status";
  static const String setPinApi       = "/profile/set-pin";
  static const String verifyPinApi    = "/profile/verify-pin";
  static const String biometricApi    = "/profile/biometric";
  static const String marketTokenApi      = "/dhan/market-token";
  static const String historicalApi       = "/dhan/historical";
  static const String historicalCachedApi = "/dhan/historical-cached";
  static const String intradayApi         = "/dhan/intraday";
  static const String intradayCachedApi   = "/dhan/intraday-cached";
  static const String intradayResyncApi   = "/dhan/intraday-resync";
  static const String optionChainApi      = "/dhan/option-chain";
  static const String relatedFNOApi          = "/dhan/related-fno";
  static const String expiryDatesApi         = "/dhan/expiry-dates";
  static const String lotSizeApi             = "/dhan/lot-size";
  static const String generateMarketTokenApi = "/dhan/generate-market-token";

  static const String walletBalanceApi      = "/wallet/balance";
  static const String walletAddCoinsApi     = "/wallet/add-coins";
  static const String walletTransactionsApi = "/wallet/transactions";
  static const String walletUnlockOptionsApi = "/wallet/unlock-options";

  static const String wishlistApi = "/wishlist";
  static const String wishlistAddApi = "/wishlist/add";
  static const String wishlistRemoveApi = "/wishlist/remove";
  static const String fundLimitApi = "/dhan/fund-limit";
  static const String marginCalculatorApi = "/dhan/margin-calculator";
  static const String superOrdersApi = "/dhan/super-orders";
  static const String dhanOrderApi = "/dhan/order"; // PUT /dhan/order/:orderId — modify regular order

  static const String demoActivateApi       = "/demo/activate";
  static const String demoWalletApi         = "/demo/wallet";
  static const String demoCoinPriceApi      = "/demo/coin-pack-price";
  static const String demoPurchaseApi       = "/demo/purchase-coins";
  static const String demoPortfolioApi      = "/demo/portfolio";
  static const String demoOrdersApi         = "/demo/orders";
  static const String demoOrderApi          = "/demo/order";
  static const String demoResetApi          = "/demo/reset";
  static const String demoChallengeInfoApi  = "/demo/challenge-info";

  // Market data: top gainers, losers, NIFTY 50, BANKNIFTY OHLC
  static const String marketDataApi = "/dhan/market-data";

  // Technical indicators (RSI, MACD, MAs, Pivots — calculated server-side)
  static const String technicalApi = "/dhan/technical-indicators";

  // News headlines for a stock
  static const String newsHeadlineApi = "/dhan/news-headlines";
}