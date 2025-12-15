import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/controllers/authenticator_provider.dart';
import 'package:auth/models/authenticator_model.dart';
import 'package:otp/otp.dart';

const String _appName = 'Nun Auth';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _simulateAddAccount(BuildContext context) {
    final secretKey = OTP.randomSecret();

    context.read<AuthenticatorProvider>().addAccount(
      serviceName: 'GitHub',
      email: 'user_github@example.com',
      secret: secretKey,
    );

    context.read<AuthenticatorProvider>().addAccount(
      serviceName: 'My Bank App',
      email: 'user_bank@example.com',
      secret: OTP.randomSecret(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulated GitHub and Bank accounts added!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final authenticatorProvider = context.watch<AuthenticatorProvider>();
    final accounts = authenticatorProvider.accounts;
    final primaryColor = Theme.of(context).primaryColor;

    final currentSecond = (DateTime.now().millisecondsSinceEpoch / 1000)
        .floor();
    final secondsRemaining = 30 - (currentSecond % 30);
    final progressValue = secondsRemaining / 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          _appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Account Settings',
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: accounts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Authenticator Accounts Added',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the "+" button to scan a 2FA QR code.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final code = authenticatorProvider.generateCode(account.secret);

                return _buildAccountTile(
                  context,
                  account: account,
                  code: code,
                  primaryColor: primaryColor,
                  progressValue: progressValue,
                  secondsRemaining: secondsRemaining,
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _simulateAddAccount(context);
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Account'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required AuthenticatorAccount account,
    required String code,
    required Color primaryColor,
    required double progressValue,
    required int secondsRemaining,
  }) {
    return ListTile(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code $code copied for ${account.serviceName}'),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.1),
        child: Text(
          account.serviceName[0].toUpperCase(),
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        account.serviceName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        account.email,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              value: progressValue,
              strokeWidth: 3,
              color: secondsRemaining < 5 ? Colors.red : primaryColor,
              backgroundColor: primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
