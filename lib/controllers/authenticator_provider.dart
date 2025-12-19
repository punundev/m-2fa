import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auth/models/authenticator_model.dart';

final supabase = Supabase.instance.client;

class AuthenticatorProvider extends ChangeNotifier {
  // ========================
  // STATE
  // ========================
  List<AuthenticatorAccount> _accounts = [];
  bool _isLoading = false;

  List<AuthenticatorAccount> get accounts => _accounts;
  bool get isLoading => _isLoading;

  // ========================
  // FETCH ACCOUNTS
  // ========================
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

  // ========================
  // GROUP BY SERVICE NAME
  // ========================
  Map<String, List<AuthenticatorAccount>> get groupedAccounts {
    final Map<String, List<AuthenticatorAccount>> grouped = {};

    for (final account in _accounts) {
      grouped.putIfAbsent(account.serviceName, () => []);
      grouped[account.serviceName]!.add(account);
    }

    // Sort each group by created_at (oldest → newest)
    for (final list in grouped.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return grouped;
  }

  // ========================
  // ADD ACCOUNT
  // ========================
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

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding TOTP account: $e');
      rethrow;
    }
  }

  // ========================
  // DELETE ACCOUNT
  // ========================
  Future<void> deleteAccount(String accountIdString) async {
    try {
      final dynamic idToPass = int.tryParse(accountIdString) ?? accountIdString;

      final data = await supabase
          .from('totp_secrets')
          .delete()
          .eq('id', idToPass)
          .select();

      if ((data as List).isEmpty) {
        throw Exception('Delete failed (RLS or ID mismatch)');
      }

      _accounts.removeWhere((account) => account.id == accountIdString);

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  // ========================
  // GENERATE OTP
  // ========================
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

// import 'package:flutter/material.dart';
// import 'package:otp/otp.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:auth/models/authenticator_model.dart';

// final supabase = Supabase.instance.client;

// class AuthenticatorProvider extends ChangeNotifier {
//   List<AuthenticatorAccount> _accounts = [];
//   List<AuthenticatorAccount> get accounts => _accounts;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   Future<void> fetchAccounts() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final response = await supabase
//           .from('totp_secrets')
//           .select('*')
//           .order('created_at', ascending: true);

//       _accounts = (response as List<dynamic>)
//           .map(
//             (item) =>
//                 AuthenticatorAccount.fromMap(item as Map<String, dynamic>),
//           )
//           .toList();
//     } catch (e) {
//       debugPrint('Error fetching TOTP accounts: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> addAccount({
//     required String serviceName,
//     required String email,
//     required String secret,
//   }) async {
//     final userId = supabase.auth.currentUser?.id;
//     if (userId == null) {
//       throw Exception('User must be logged in to add an account.');
//     }

//     final newAccountData = {
//       'user_id': userId,
//       'service_name': serviceName,
//       'email': email,
//       'secret': secret,
//     };

//     try {
//       final response = await supabase
//           .from('totp_secrets')
//           .insert(newAccountData)
//           .select()
//           .single();

//       final newAccount = AuthenticatorAccount.fromMap(response);
//       _accounts.add(newAccount);
//     } catch (e) {
//       debugPrint('Error adding TOTP account: $e');
//       rethrow;
//     }

//     notifyListeners();
//   }

//   Future<void> deleteAccount(String accountIdString) async {
//     try {
//       debugPrint('--- DELETE START ---');
//       debugPrint('Raw ID from UI: $accountIdString');

//       final dynamic idToPass = int.tryParse(accountIdString) ?? accountIdString;
//       debugPrint('Converted ID Type: ${idToPass.runtimeType}');

//       final data = await supabase
//           .from('totp_secrets')
//           .delete()
//           .eq('id', idToPass)
//           .select();

//       debugPrint('Supabase Response Data: $data');

//       if ((data as List).isEmpty) {
//         debugPrint(
//           '!!! ZERO ROWS DELETED !!! This is usually an RLS Policy issue or ID mismatch.',
//         );
//         throw Exception('Database rejected delete. Check RLS policies.');
//       }

//       _accounts.removeWhere(
//         (account) => account.id.toString() == accountIdString,
//       );
//       notifyListeners();

//       debugPrint('--- DELETE SUCCESS ---');
//     } catch (e) {
//       debugPrint('--- DELETE CRASHED ---');
//       debugPrint('Error: $e');
//       rethrow;
//     }
//   }

//   String generateCode(String secret) {
//     if (secret.isEmpty) return '------';

//     final now = DateTime.now().millisecondsSinceEpoch;

//     return OTP.generateTOTPCodeString(
//       secret,
//       now,
//       length: 6,
//       interval: 30,
//       algorithm: Algorithm.SHA1,
//       isGoogle: true,
//     );
//   }
// }
