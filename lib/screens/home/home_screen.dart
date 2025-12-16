import 'dart:async';
import 'package:auth/screens/scan/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/authenticator_provider.dart';
import 'package:auth/models/authenticator_model.dart';

const String _appName = 'Nun Auth';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticatorProvider>().fetchAccounts();
    });

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

  void _handleAddAccount(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const QRScannerScreen()));

    if (!mounted) return;
    context.read<AuthenticatorProvider>().fetchAccounts();
  }

  String? _getAssetPath(String serviceName) {
    final lowerCaseName = serviceName.toLowerCase();
    if (lowerCaseName.contains('facebook')) {
      return 'assets/images/facebook.png';
    } else if (lowerCaseName.contains('github')) {
      return 'assets/images/github.png';
    } else if (lowerCaseName.contains('google')) {
      return 'assets/images/google.png';
    }
    return null;
  }

  void _confirmAndDeleteAccount(
    BuildContext context,
    AuthenticatorAccount account,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: Text(
            'Are you sure you want to remove the 2FA account for ${account.serviceName} (${account.email})? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      if (!mounted) return;

      try {
        await context.read<AuthenticatorProvider>().deleteAccount(account.id!);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${account.serviceName} account removed successfully.',
            ),
          ),
        );

        Future.delayed(Duration.zero, () {
          if (mounted) {
            context.read<AuthenticatorProvider>().fetchAccounts();
          }
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: const [],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        automaticallyImplyLeading: false,
      ),

      body: authenticatorProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
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
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final code = authenticatorProvider.generateCode(account.secret);

                return _buildAccountTile(
                  key: ValueKey(account.id!),
                  context,
                  account: account,
                  code: code,
                  primaryColor: primaryColor,
                  progressValue: progressValue,
                  secondsRemaining: secondsRemaining,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddAccount(context),
        child: const Icon(Icons.qr_code_scanner),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required Key key,
    required AuthenticatorAccount account,
    required String code,
    required Color primaryColor,
    required double progressValue,
    required int secondsRemaining,
  }) {
    final assetPath = _getAssetPath(account.serviceName);

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code $code copied for ${account.serviceName}'),
              duration: const Duration(milliseconds: 1200),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: assetPath != null
                    ? Image.asset(assetPath, width: 24, height: 24)
                    : Text(
                        account.serviceName[0].toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.serviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      account.email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 35,
                        width: 35,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 3,
                          color: secondsRemaining < 5
                              ? Colors.red.shade600
                              : primaryColor,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      Text(
                        '$secondsRemaining',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: secondsRemaining < 5
                              ? Colors.red.shade600
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () => _confirmAndDeleteAccount(context, account),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
