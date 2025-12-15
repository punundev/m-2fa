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

  Future<void> fetchProfile() async {
    if (_user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select('id, full_name, avatar_url, hashed_pin')
          .eq('id', _user!.id)
          .single();

      // Ensure the profile row exists before trying to parse
      if (response.isNotEmpty) {
        _profile = ProfileModel.fromJson(response);
      } else {
        // Handle case where profile row is missing (e.g., if DB trigger failed)
        print('Error: Profile row missing for user ${_user!.id}');
        _profile = null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      _profile = null;
    }
  }

  // 🎯 CRITICAL CHANGE: Reload user and return if the user AND profile are ready.
  @override
  Future<bool> reloadUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      // Not logged in
      _user = null;
      _profile = null;
      notifyListeners();
      return false;
    }

    // 1. Session is present. Set user.
    _user = session.user;

    // 2. Fetch the profile immediately.
    await fetchProfile();

    // 3. Notify listeners (for any widgets using profile data)
    notifyListeners();

    // 4. Return true only if both user and profile are successfully loaded.
    return _profile != null;
  }

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

    // Guaranteed profile fetch after successful login
    await fetchProfile();
    notifyListeners();
  }

  Future<void> signup(String email, String password) async {
    final res = await supabase.auth.signUp(email: email, password: password);

    if (res.user == null) {
      throw Exception('Sign up failed');
    }

    _user = res.user;
    currentUserId = res.user!.id;

    // Guaranteed profile fetch after successful signup
    // (Relies on the DB trigger creating the profile row first)
    await fetchProfile();
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

    // After the OAuth flow completes, we fetch the current user and session
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('OAuth login failed');
    }

    _user = user;
    currentUserId = user.id;
    is2FARequired = user.appMetadata['2fa_enabled'] == true;

    // Guaranteed profile fetch after successful OAuth
    await fetchProfile();
    notifyListeners();
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

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:otp/otp.dart';
// import 'package:auth/models/profile_model.dart';

// class AuthProvider extends ChangeNotifier {
//   final SupabaseClient supabase = Supabase.instance.client;

//   User? _user;
//   User? get user => _user;

//   ProfileModel? _profile;
//   ProfileModel? get profile => _profile;

//   bool is2FARequired = false;
//   String? currentUserId;

//   Future<void> fetchProfile() async {
//     if (_user == null) return;

//     try {
//       final response = await supabase
//           .from('profiles')
//           .select('id, full_name, avatar_url, hashed_pin')
//           .eq('id', _user!.id)
//           .single();

//       if (response.isNotEmpty) {
//         _profile = ProfileModel.fromJson(response);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error fetching profile: $e');
//       _profile = null;
//       notifyListeners();
//     }
//   }

//   @override
//   Future<void> reloadUser() async {
//     final session = supabase.auth.currentSession;
//     if (session != null) {
//       _user = session.user;
//       await fetchProfile();
//       notifyListeners();
//     }
//   }

//   Future<void> login(String email, String password) async {
//     final res = await supabase.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );

//     if (res.user == null) {
//       throw Exception('Login failed');
//     }

//     _user = res.user;
//     currentUserId = res.user!.id;
//     is2FARequired = res.user!.appMetadata['2fa_enabled'] == true;

//     await fetchProfile();
//     notifyListeners();
//   }

//   Future<void> signup(String email, String password) async {
//     final res = await supabase.auth.signUp(email: email, password: password);

//     if (res.user == null) {
//       throw Exception('Sign up failed');
//     }

//     _user = res.user;
//     currentUserId = res.user!.id;

//     await fetchProfile();
//     notifyListeners();
//   }

//   Future<void> oauthLogin(String provider) async {
//     late OAuthProvider oauthProvider;

//     if (provider == 'google') {
//       oauthProvider = OAuthProvider.google;
//     } else if (provider == 'github') {
//       oauthProvider = OAuthProvider.github;
//     } else {
//       throw Exception('Unsupported provider');
//     }

//     await supabase.auth.signInWithOAuth(
//       oauthProvider,
//       redirectTo: 'io.supabase.flutter://callback',
//     );

//     final user = supabase.auth.currentUser;
//     if (user == null) {
//       throw Exception('OAuth login failed');
//     }

//     _user = user;
//     currentUserId = user.id;
//     is2FARequired = user.appMetadata['2fa_enabled'] == true;

//     await fetchProfile();
//     notifyListeners();
//   }

//   Future<void> verify2FA(String code) async {
//     final user = supabase.auth.currentUser;
//     if (user == null) {
//       throw Exception('No logged in user');
//     }

//     final secret = user.appMetadata['2fa_secret'];
//     if (secret == null) {
//       throw Exception('2FA not enabled');
//     }

//     final validCode = OTP.generateTOTPCodeString(
//       secret,
//       DateTime.now().millisecondsSinceEpoch,
//     );

//     if (code != validCode) {
//       throw Exception('Invalid 2FA code');
//     }

//     is2FARequired = false;
//     notifyListeners();
//   }

//   Future<void> forgotPassword(String email) async {
//     await supabase.auth.resetPasswordForEmail(email);
//   }

//   Future<void> logout() async {
//     await supabase.auth.signOut();

//     _user = null;
//     _profile = null;
//     currentUserId = null;
//     is2FARequired = false;

//     notifyListeners();
//   }
// }
