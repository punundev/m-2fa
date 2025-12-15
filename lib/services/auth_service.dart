import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp/otp.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<User?> signup(String email, String password) async {
    final res = await _supabase.auth.signUp(email: email, password: password);

    if (res.user == null) {
      throw Exception('Sign up failed');
    }

    return res.user;
  }

  Future<User?> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Login failed');
    }

    final is2FA = res.user!.appMetadata['2fa_enabled'] == true;
    if (is2FA) {
      throw Exception('2FA required');
    }

    return res.user;
  }

  Future<void> verify2FA(String code) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No logged in user');
    }

    final secret = user.appMetadata['2fa_secret'];
    if (secret == null) {
      throw Exception('2FA not enabled');
    }

    final validCode = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
    );

    if (code != validCode) {
      throw Exception('Invalid 2FA code');
    }
  }

  Future<void> oauthLogin(String provider) async {
    late OAuthProvider oauthProvider;

    switch (provider.toLowerCase()) {
      case 'google':
        oauthProvider = OAuthProvider.google;
        break;
      case 'github':
        oauthProvider = OAuthProvider.github;
        break;
      default:
        throw Exception('Unsupported provider');
    }

    await _supabase.auth.signInWithOAuth(
      oauthProvider,
      redirectTo: 'io.supabase.flutter://callback',
    );
  }

  Future<void> forgotPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
