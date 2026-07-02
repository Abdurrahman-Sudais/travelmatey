/// REST endpoint paths — keep in sync with [travelmate_api_spec.json].
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const signIn = '/auth/signin';
  static const signUp = '/auth/signup';
  static const signOut = '/auth/signout';
  static const me = '/auth/me';
  static const switchRole = '/auth/switch-role';
  static const verifyOtp = '/auth/verify-otp';
  static const changePassword = '/auth/change-password';
  static const google = '/auth/google';

  // Profile
  static String profile(String userId) => '/profile/$userId';
  static String profileAvatar(String userId) => '/profile/$userId/avatar';
  static String profileStats(String userId) => '/profile/$userId/stats';

  // User activity
  static const userActivity = '/user/activity';

  // KYC
  static const kycStatus = '/kyc/status';
  static const kycSubmit = '/kyc/submit';
  static const kycDocument = '/kyc/documents';

  // Rides
  static const rides = '/rides';
  static const ridesPopular = '/rides/popular';
  static String ride(String id) => '/rides/$id';

  // Bookings
  static const bookings = '/bookings';
  static const bookingsDriverPending = '/bookings/driver/pending';
  static String booking(String id) => '/bookings/$id';
  static String userBookings(String userId) => '/bookings/user/$userId';

  // Wallet
  static const walletMe = '/wallet/me';
  static const walletFund = '/wallet/fund';
  static const walletVerifyPayment = '/wallet/verify-payment';
  static const walletWithdraw = '/wallet/withdraw';
  static const walletBanks = '/wallet/banks';
  static const walletBankAccount = '/wallet/bank-account';
  static const walletResolveAccount = '/wallet/resolve-account';
  static String walletTransactions(String userId) =>
      '/wallet/$userId/transactions';

  // Bills (VTPass)
  static const billsAirtime = '/bills/airtime';
  static const billsData = '/bills/data';
  static const billsElectricity = '/bills/electricity';

  // Chat — legacy ride conversations
  static const chat = '/chat';
  static String chatMessages(String conversationId) =>
      '/chat/$conversationId/messages';

  // Chats — multi-participant system
  static const chats = '/chats';
  static String userChats(String userId) => '/chats/$userId';
  static String chatUnread(String userId) => '/chats/unread/$userId';
  static String chatMessagesNew(String chatId) => '/chats/$chatId/messages';
  static String chatRead(String chatId) => '/chats/$chatId/read';

  // Notifications
  static const notificationsMe = '/notifications/me';
  static const notificationsReadAll = '/notifications/read-all';

  // Referral
  static const referral = '/referral';

  // Health
  static const health = '/health';

  // Payments
  static const paymentsInitialize = '/payments/initialize';
  static String paymentsVerify(String reference) =>
      '/payments/verify/${Uri.encodeComponent(reference)}';
}
