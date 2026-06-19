/// REST endpoint paths — keep in sync with the backend OpenAPI/Swagger spec.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const refreshToken = '/auth/refresh';
  static const verifyPhone = '/auth/verify-phone';
  static const verifyEmail = '/auth/verify-email';

  // User / Profile
  static const me = '/users/me';
  static const avatar = '/users/me/avatar';
  static const address = '/users/me/address';

  // KYC
  static const kycStatus = '/kyc/status';
  static const kycSubmit = '/kyc/submit';
  static const kycDocument = '/kyc/documents'; // POST multipart

  // Rides (driver)
  static const rides = '/rides';
  static String ride(String id) => '/rides/$id';

  // Bookings (rider)
  static const bookings = '/bookings';
  static String booking(String id) => '/bookings/$id';

  // Wallet
  static const wallet = '/wallet';
  static const walletTransactions = '/wallet/transactions';
  static const walletFund = '/wallet/fund';
  static const walletWithdraw = '/wallet/withdraw';
  static const walletAirtime = '/wallet/airtime';
  static const walletData = '/wallet/data';
  static const walletBills = '/wallet/bills';

  // Messages
  static const conversations = '/conversations';
  static String conversation(String id) => '/conversations/$id';
}
