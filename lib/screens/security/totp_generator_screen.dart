import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:otp/otp.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:flutter/services.dart';

class TOTPGeneratorScreen extends StatefulWidget {
  const TOTPGeneratorScreen({super.key});

  @override
  State<TOTPGeneratorScreen> createState() => _TOTPGeneratorScreenState();
}

class _TOTPGeneratorScreenState extends State<TOTPGeneratorScreen> {
  String _currentTotpCode = '------';
  int _secondsRemaining = 30;
  Timer? _timer;
  String? _secret;

  static const int _totpPeriod = 30;
  static const String _serviceName = 'NunAuthApp';

  @override
  void initState() {
    super.initState();
    _startTotpGeneration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTotpGeneration() {
    _secret =
        context.read<AuthProvider>().user?.appMetadata?['2fa_secret']
            as String?;

    if (_secret == null || _secret!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA is not set up. Redirecting.')),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
      }
      return;
    }

    _generateTotp();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerAndCode();
    });
  }

  void _generateTotp() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final code = OTP.generateTOTPCodeString(
      _secret!,
      now,
      length: 6,
      interval: _totpPeriod,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final currentSecond = (now / 1000).floor();
    final secondsRemaining = _totpPeriod - (currentSecond % _totpPeriod);

    if (mounted) {
      setState(() {
        _currentTotpCode = code;
        _secondsRemaining = secondsRemaining;
      });
    }
  }

  void _updateTimerAndCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentSecond = (now / 1000).floor();
    final secondsRemaining = _totpPeriod - (currentSecond % _totpPeriod);

    if (mounted) {
      if (secondsRemaining == _totpPeriod) {
        _generateTotp();
      } else {
        setState(() {
          _secondsRemaining = secondsRemaining;
        });
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentTotpCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code $_currentTotpCode copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final is2FAEnabled =
        context.read<AuthProvider>().user?.appMetadata?['2fa_enabled'] == true;
    final userEmail =
        context.read<AuthProvider>().user?.email ?? 'Unknown User';

    if (!is2FAEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TOTP Generator'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open, size: 80, color: Colors.red.shade400),
                const SizedBox(height: 16),
                const Text(
                  '2FA is not enabled for your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register-2fa');
                  },
                  child: const Text('Go to Setup 2FA'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _serviceName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: _copyToClipboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    _currentTotpCode,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining / _totpPeriod,
                        strokeWidth: 6,
                        color: _secondsRemaining < 5
                            ? Colors.red
                            : primaryColor,
                        backgroundColor: primaryColor.withOpacity(0.2),
                      ),
                    ),
                    Text(
                      '$_secondsRemaining',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _secondsRemaining < 5
                            ? Colors.red
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Tap the code to copy it.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
