// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:travelmateeee/core/auth/google_auth_result.dart';
import 'package:travelmateeee/core/config/app_config.dart';
import 'package:travelmateeee/core/services/google_sign_in_service.dart';
import 'package:travelmateeee/core/services/api_service.dart';

/// Authenticated user returned from auth endpoints.
class AuthUser {
  final String id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final bool isVerified;

  const AuthUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.isVerified = false,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    firstName:
        json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
    lastName:
        json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
    role: json['role']?.toString() ?? 'rider',
    isVerified:
        json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? false,
  );

  String get fullName => '$firstName $lastName'.trim();
}

class PendingSignUpSession {
  final AuthUser user;
  final String token;
  final String refreshToken;

  const PendingSignUpSession({
    required this.user,
    required this.token,
    required this.refreshToken,
  });
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiService _api = ApiService.instance;

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  static const _mockUser = AuthUser(
    id: 'mock-user-id-123',
    email: 'travelmate.mock@example.com',
    phone: '+2348012345678',
    firstName: 'Mock',
    lastName: 'Traveler',
    role: 'rider',
    isVerified: true,
  );

  /// Normalizes Nigerian numbers to +234XXXXXXXXXX for the API.
  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234') && digits.length >= 13) {
      return '+$digits';
    }
    if (digits.startsWith('0') && digits.length >= 10) {
      return '+234${digits.substring(1)}';
    }
    if (digits.length == 10) {
      return '+234$digits';
    }
    return phone.trim();
  }

  Future<AuthUser> signIn(String emailOrPhone, String password) async {
    if (AppConfig.useMockRepositories) {
      await Future.delayed(const Duration(milliseconds: 600));
      await _api.saveSession(
        token: 'mock-jwt-token',
        refreshToken: 'mock-refresh-token',
        userId: _mockUser.id,
      );
      _currentUser = _mockUser;
      return _mockUser;
    }

    final body = <String, dynamic>{'password': password};
    if (emailOrPhone.contains('@')) {
      body['email'] = emailOrPhone.trim();
    } else {
      body['phone'] = emailOrPhone.trim();
    }

    final data = await _api.post('/auth/signin', body: body);
    return _persistAuthResponse(data);
  }

  Future<AuthUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    if (AppConfig.useMockRepositories) {
      await Future.delayed(const Duration(milliseconds: 600));
      final user = AuthUser(
        id: 'mock-user-id-signup',
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        role: role,
        isVerified: true,
      );
      await _api.saveSession(
        token: 'mock-jwt-token-signup',
        refreshToken: 'mock-refresh-token-signup',
        userId: user.id,
      );
      _currentUser = user;
      return user;
    }

    final data = await _api.post(
      '/auth/signup',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      },
    );
    return _persistAuthResponse(data);
  }

  Future<GoogleAuthResult> authenticateWithGoogle({
    required String credential,
    required Map<String, dynamic> googleUserInfo,
    String role = 'rider',
  }) async {
    if (AppConfig.useMockRepositories) {
      await Future.delayed(const Duration(milliseconds: 600));
      final user = AuthUser(
        id: googleUserInfo['sub']?.toString() ?? 'mock-google-id',
        email: googleUserInfo['email']?.toString() ?? 'mock@example.com',
        phone: '',
        firstName: googleUserInfo['given_name']?.toString() ?? 'Google',
        lastName: googleUserInfo['family_name']?.toString() ?? 'User',
        role: role,
        isVerified: false,
      );
      _currentUser = user;
      await _api.saveTemporarySession(
        token: 'mock-google-token',
        refreshToken: 'mock-google-refresh',
        userId: user.id,
        phone: user.phone,
        email: user.email,
      );
      return GoogleAuthResult(
        user: user,
        token: 'mock-google-token',
        refreshToken: 'mock-google-refresh',
        isNewUser: true,
        needsOnboarding: true,
      );
    }

    final response = await _api.postWithStatus(
      '/auth/google',
      body: {
        'credential': credential,
        'googleUserInfo': googleUserInfo,
        'role': role,
      },
    );
    final pendingSession = _parsePendingSignUpSession(response.body);
    final isNewUser =
        response.statusCode == 201 ||
        response.body['isNewUser'] == true ||
        response.body['newUser'] == true;
    final needsOnboarding = _userNeedsOnboarding(
      pendingSession.user,
      response.body,
      isNewUser,
    );

    if (needsOnboarding) {
      await _api.saveTemporarySession(
        token: pendingSession.token,
        refreshToken: pendingSession.refreshToken,
        userId: pendingSession.user.id,
        phone: pendingSession.user.phone,
        email: pendingSession.user.email.isNotEmpty
            ? pendingSession.user.email
            : googleUserInfo['email']?.toString() ?? '',
      );
    } else if (pendingSession.token.isNotEmpty &&
        pendingSession.user.id.isNotEmpty) {
      await _api.saveSession(
        token: pendingSession.token,
        refreshToken: pendingSession.refreshToken,
        userId: pendingSession.user.id,
      );
    }

    _currentUser = pendingSession.user;
    return GoogleAuthResult(
      user: pendingSession.user,
      token: pendingSession.token,
      refreshToken: pendingSession.refreshToken,
      isNewUser: isNewUser,
      needsOnboarding: needsOnboarding,
    );
  }

  /// Legacy helper — prefer [authenticateWithGoogle] for routing new users.
  Future<AuthUser> signInWithGoogle({
    required String credential,
    required Map<String, dynamic> googleUserInfo,
    String role = 'rider',
  }) async {
    final result = await authenticateWithGoogle(
      credential: credential,
      googleUserInfo: googleUserInfo,
      role: role,
    );
    return result.user;
  }

  bool _userNeedsOnboarding(
    AuthUser user,
    Map<String, dynamic> data,
    bool isNewUser,
  ) {
    if (data['profileComplete'] == false) return true;
    if (data['requiresOnboarding'] == true) return true;
    if (data['needsOnboarding'] == true) return true;
    if (isNewUser) return true;
    if (user.phone.trim().isEmpty) return true;
    if (!user.isVerified) return true;

    final first = user.firstName.trim().toLowerCase();
    final last = user.lastName.trim().toLowerCase();
    if (first.isEmpty ||
        first == 'travelmate' ||
        first == 'google' ||
        first == 'user') {
      return true;
    }
    if (last.isEmpty || last == 'user') return true;
    return false;
  }

  Future<PendingSignUpSession> signUpForVerification({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final normalizedPhone = normalizePhone(phone);
    final data = await _api.post(
      '/auth/signup',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email.trim(),
        'phone': normalizedPhone,
        'password': password,
        'role': role,
      },
    );
    final pendingSession = _parsePendingSignUpSession(data);
    await _api.saveTemporarySession(
      token: pendingSession.token,
      refreshToken: pendingSession.refreshToken,
      userId: pendingSession.user.id,
      phone: pendingSession.user.phone.isNotEmpty
          ? pendingSession.user.phone
          : normalizedPhone,
      email: pendingSession.user.email.isNotEmpty
          ? pendingSession.user.email
          : email.trim(),
    );
    _currentUser = pendingSession.user;

    return pendingSession;
  }

  Future<PendingSignUpSession> resendSignupOtp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    return signUpForVerification(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }

  Future<void> verifyOtp({
    required String phone,
    required String firebaseIdToken,
  }) async {
    final normalizedPhone = normalizePhone(phone);

    await _api.post(
      '/auth/verify-otp',
      body: {'phone': normalizedPhone, 'firebaseIdToken': firebaseIdToken},
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.post(
      '/auth/change-password',
      body: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    await _api.put(
      '/profile/$userId',
      body: {'firstName': firstName, 'lastName': lastName},
    );
  }

  Future<bool> isEmailVerified() async {
    // travelmate_api_spec.json has no dedicated email verification endpoint.
    // The app can only poll /auth/me after the user opens the email link.
    final user = await getMe();
    return user.isVerified;
  }

  Future<AuthUser> completeVerifiedSession({
    required String token,
    required String refreshToken,
    required String userId,
  }) async {
    _api.setTemporarySession(
      token: token,
      refreshToken: refreshToken,
      userId: userId,
    );
    final user = await getMe();
    await _api.saveSession(
      token: token,
      refreshToken: refreshToken,
      userId: user.id.isNotEmpty ? user.id : userId,
    );
    await _api.clearTemporarySession();
    return user;
  }

  Future<void> signOut() async {
    final refreshToken = _api.getRefreshToken();
    try {
      if (refreshToken != null) {
        await _api.post('/auth/signout', body: {'token': refreshToken});
      }
    } catch (_) {
      // Clear local session even if server sign-out fails.
    } finally {
      _currentUser = null;
      await _signOutGoogleProviders();
      await _api.clearSession();
    }
  }

  Future<void> _signOutGoogleProviders() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (_) {
      // Firebase may not be initialized on builds without Firebase config.
    }
    try {
      await GoogleSignInService.instance.signOut();
    } catch (_) {
      // GoogleSignIn keeps no session on some platforms.
    }
  }

  Future<AuthUser> getMe() async {
    if (AppConfig.useMockRepositories) {
      return _currentUser ?? _mockUser;
    }
    final data = await _api.get('/auth/me');
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    _currentUser = AuthUser.fromJson(userJson);
    return _currentUser!;
  }

  Future<AuthUser> switchRole(String role) async {
    // Switch role on the backend; it returns a fresh token — we must persist it.
    final data = await _api.post('/auth/switch-role', body: {'role': role});
    // _persistAuthResponse saves the new token + user; also refresh /auth/me
    // in case the backend embeds minimal user data in the switch-role response.
    final user = await _persistAuthResponse(data);
    // Re-fetch full profile so downstream code sees the updated role field.
    try {
      return await getMe();
    } catch (_) {
      return user;
    }
  }

  /// Returns the user if the saved token is valid; clears session on 401.
  Future<AuthUser?> validateSession() async {
    if (AppConfig.useMockRepositories) {
      return _currentUser ?? _mockUser;
    }
    if (!_api.isLoggedIn()) return null;
    try {
      return await getMe();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _api.clearSession();
        _currentUser = null;
      }
      return null;
    }
  }

  Future<AuthUser> _persistAuthResponse(Map<String, dynamic> data) async {
    final pendingSession = _parsePendingSignUpSession(data);

    if (pendingSession.token.isNotEmpty && pendingSession.user.id.isNotEmpty) {
      await _api.saveSession(
        token: pendingSession.token,
        refreshToken: pendingSession.refreshToken,
        userId: pendingSession.user.id,
      );
    }

    _currentUser = pendingSession.user;
    return pendingSession.user;
  }

  PendingSignUpSession _parsePendingSignUpSession(Map<String, dynamic> data) {
    final session = data['session'] as Map<String, dynamic>?;
    final token =
        data['token']?.toString() ?? session?['access_token']?.toString() ?? '';
    final refreshToken =
        data['refreshToken']?.toString() ??
        session?['refresh_token']?.toString() ??
        '';

    final userJson =
        data['user'] as Map<String, dynamic>? ??
        session?['user'] as Map<String, dynamic>? ??
        {};
    final user = AuthUser.fromJson(userJson);

    return PendingSignUpSession(
      user: user,
      token: token,
      refreshToken: refreshToken,
    );
  }
}
