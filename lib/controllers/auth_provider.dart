import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:otp/otp.dart';
import 'package:auth/models/profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  User? _user;
  User? get user => _user;

  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool is2FARequired = false;
  String? currentUserId;

  AuthProvider() {
    _initAuthListener();
    _user = supabase.auth.currentUser;
    if (_user != null) {
      currentUserId = _user!.id;
      is2FARequired = _user!.appMetadata['2fa_enabled'] == true;
    }
  }

  void _initAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        if (session != null) {
          _user = session.user;
          currentUserId = _user!.id;
          is2FARequired = _user!.appMetadata['2fa_enabled'] == true;
          await fetchProfile();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _profile = null;
        currentUserId = null;
        is2FARequired = false;
        notifyListeners();
      }
    });
  }

  Future<void> fetchProfile({int retries = 5}) async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    for (int i = 0; i < retries; i++) {
      try {
        final response = await supabase
            .from('profiles')
            .select('id, full_name, avatar_url, hashed_pin')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (response != null) {
          _profile = ProfileModel.fromJson(response);
          notifyListeners();
          return;
        } else {
          // Profile might still be being created by trigger
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        }
      } catch (e) {
        debugPrint('Error fetching profile (attempt $i): $e');
      }
    }
    notifyListeners();
  }

  Future<bool> reloadUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      _user = null;
      _profile = null;
      notifyListeners();
      return false;
    }

    _user = session.user;
    currentUserId = _user!.id;
    is2FARequired = _user!.appMetadata['2fa_enabled'] == true;

    await fetchProfile();
    return _profile != null;
  }

  Future<void> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) {
      throw Exception('Login failed: Invalid credentials');
    }

    _user = res.user;
    currentUserId = _user!.id;
    is2FARequired = _user!.appMetadata['2fa_enabled'] == true;

    await fetchProfile();
    notifyListeners();
  }

  Future<void> signup(String email, String password) async {
    final res = await supabase.auth.signUp(email: email, password: password);

    if (res.user == null) {
      throw Exception('Sign up failed');
    }

    _user = res.user;
    currentUserId = res.user?.id;

    if (res.session != null) {
      await fetchProfile();
    }
    notifyListeners();
  }

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
  }

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

  Future<void> forgotPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    _user = null;
    _profile = null;
    currentUserId = null;
    is2FARequired = false;
    notifyListeners();
  }
}
