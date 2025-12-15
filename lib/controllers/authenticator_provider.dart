import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:auth/models/authenticator_model.dart';

class AuthenticatorProvider extends ChangeNotifier {
  final List<AuthenticatorAccount> _accounts = [];
  List<AuthenticatorAccount> get accounts => _accounts;

  void addAccount({
    required String serviceName,
    required String email,
    required String secret,
  }) {
    final newAccount = AuthenticatorAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: serviceName,
      email: email,
      secret: secret,
    );
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
