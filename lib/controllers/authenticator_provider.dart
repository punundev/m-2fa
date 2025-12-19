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

    try {
      final response = await supabase
          .from('totp_secrets')
          .insert(newAccountData)
          .select()
          .single();

      final newAccount = AuthenticatorAccount.fromMap(response);
      _accounts.add(newAccount);
    } catch (e) {
      debugPrint('Error adding TOTP account: $e');
      rethrow;
    }

    notifyListeners();
  }

  // Future<void> deleteAccount(String accountIdString) async {
  //   final int accountIdInt = int.tryParse(accountIdString) ?? -1;

  //   try {
  //     await supabase.from('totp_secrets').delete().eq('id', accountIdString);

  //     _accounts.removeWhere((account) => account.id == accountIdInt);

  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint('Error deleting TOTP account with ID $accountIdString: $e');
  //     rethrow;
  //   }
  // }

  Future<void> deleteAccount(String accountIdString) async {
    try {
      debugPrint('--- DELETE START ---');
      debugPrint('Raw ID from UI: $accountIdString');

      // 1. Determine type (Supabase is strict: int8 vs text)
      final dynamic idToPass = int.tryParse(accountIdString) ?? accountIdString;
      debugPrint('Converted ID Type: ${idToPass.runtimeType}');

      // 2. Execute delete with .select()
      // This forces Supabase to return the deleted data.
      // If 'data' is empty, it means NOTHING was deleted.
      final data = await supabase
          .from('totp_secrets')
          .delete()
          .eq('id', idToPass)
          .select();

      debugPrint('Supabase Response Data: $data');

      if ((data as List).isEmpty) {
        debugPrint(
          '!!! ZERO ROWS DELETED !!! This is usually an RLS Policy issue or ID mismatch.',
        );
        // Throwing a manual error so your UI SnackBar actually shows something
        throw Exception('Database rejected delete. Check RLS policies.');
      }

      // 3. If we got here, it actually deleted from DB
      _accounts.removeWhere(
        (account) => account.id.toString() == accountIdString,
      );
      notifyListeners();

      debugPrint('--- DELETE SUCCESS ---');
    } catch (e) {
      debugPrint('--- DELETE CRASHED ---');
      debugPrint('Error: $e');
      rethrow; // This will trigger the catch block in your HomeScreen
    }
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
