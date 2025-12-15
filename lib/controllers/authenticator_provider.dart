import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/models/authenticator_model.dart';

final supabase = Supabase.instance.client;

class AuthenticatorProvider extends ChangeNotifier {
  List<AuthenticatorAccount> _accounts = [];
  List<AuthenticatorAccount> get accounts => _accounts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('totp_secrets')
          .select('*')
          .order('created_at', ascending: true);

      _accounts = (response as List<dynamic>)
          .map(
            (item) =>
                AuthenticatorAccount.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching TOTP accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount({
    required String serviceName,
    required String email,
    required String secret,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be logged in to add an account.');
    }

    final newAccountData = {
      'user_id': userId,
      'service_name': serviceName,
      'email': email,
      'secret': secret,
    };

    final response = await supabase
        .from('totp_secrets')
        .insert(newAccountData)
        .select()
        .single();

    final newAccount = AuthenticatorAccount.fromMap(response);
    _accounts.add(newAccount);

    notifyListeners();
  }

  String generateCode(String secret) {
    if (secret.isEmpty) return '------';

    final now = DateTime.now().millisecondsSinceEpoch;

    return OTP.generateTOTPCodeString(
      secret,
      now,
      length: 6,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
  }
}
