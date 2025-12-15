import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp/otp.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  User? _user;
  User? get user => _user;

  bool is2FARequired = false;
  String? currentUserId;

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Login failed');
    }

    _user = res.user;
    currentUserId = res.user!.id;
    is2FARequired = res.user!.appMetadata['2fa_enabled'] == true;

    notifyListeners();
  }

  // ================= SIGN UP =================
  Future<void> signup(String email, String password) async {
    final res = await supabase.auth.signUp(email: email, password: password);

    if (res.user == null) {
      throw Exception('Sign up failed');
    }

    _user = res.user;
    currentUserId = res.user!.id;

    notifyListeners();
  }

  // ================= OAUTH LOGIN =================
  Future<void> oauthLogin(String provider) async {
    late OAuthProvider oauthProvider;

    if (provider == 'google') {
      oauthProvider = OAuthProvider.google;
    } else if (provider == 'github') {
      oauthProvider = OAuthProvider.github;
    } else {
      throw Exception('Unsupported provider');
    }

    await supabase.auth.signInWithOAuth(
      oauthProvider,
      redirectTo: 'io.supabase.flutter://callback',
    );

    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('OAuth login failed');
    }

    _user = user;
    currentUserId = user.id;
    is2FARequired = user.appMetadata['2fa_enabled'] == true;

    notifyListeners();
  }

  // ================= VERIFY 2FA =================
  Future<void> verify2FA(String code) async {
    final user = supabase.auth.currentUser;
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

    is2FARequired = false;
    notifyListeners();
  }

  // ================= FORGOT PASSWORD =================
  Future<void> forgotPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await supabase.auth.signOut();

    _user = null;
    currentUserId = null;
    is2FARequired = false;

    notifyListeners();
  }
}
