import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/authenticator_provider.dart';
import 'package:auth/models/authenticator_model.dart';

const String _appName = 'Nun Authentication';

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

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _getAssetPath(String serviceName) {
    final name = serviceName.toLowerCase();
    return switch (name) {
      String s when s.contains('facebook') => 'assets/images/facebook.png',
      String s when s.contains('github') => 'assets/images/github.png',
      String s when s.contains('google') => 'assets/images/google.png',
      String s when s.contains('brevo') => 'assets/images/brevo.png',
      String s when s.contains('netify') => 'assets/images/netify.png',
      String s when s.contains('vercel') => 'assets/images/vercel.png',
      String s when s.contains('supabase') => 'assets/images/supabase.png',
      String s when s.contains('firebase') => 'assets/images/firebase.png',
      String s when s.contains('termius') => 'assets/images/termius.png',
      String s when s.contains('amazon web services') =>
        'assets/images/aws.png',
      String s when s.contains('cloudflare') => 'assets/images/cloudflare.png',
      String s when s.contains('coolify') => 'assets/images/coolify.png',
      String s when s.contains('nun note') => 'assets/images/nun-note.png',
      String s when s.contains('hostinger') || s.contains('namecheap') =>
        'assets/images/domain.png',
      String s when s.contains('nham') || s.contains('kammarng') =>
        'assets/images/kammarng.png',
      String s when s.contains('contabo') || s.contains('interser') =>
        'assets/images/server.png',
      _ => null,
    };
  }

  Future<void> _confirmAndDeleteAccount(
    BuildContext context,
    AuthenticatorAccount account,
  ) async {
    final provider = context.read<AuthenticatorProvider>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          title: const Text(
            'Delete Account?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Remove 2FA for ${account.serviceName} (${account.email})?\n\nThis action cannot be undone.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await provider.deleteAccount(account.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${account.serviceName} removed successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticatorProvider = context.watch<AuthenticatorProvider>();
    final groupedAccounts = authenticatorProvider.groupedAccounts;
    final serviceNames = groupedAccounts.keys.toList();

    final primaryColor = Theme.of(context).primaryColor;

    final currentSecond = (DateTime.now().millisecondsSinceEpoch / 1000)
        .floor();
    final secondsRemaining = 30 - (currentSecond % 30);
    final progressValue = secondsRemaining / 30;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          _appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withBlue(150),
                  primaryColor.withRed(100).withBlue(200),
                  primaryColor.withRed(50),
                ],
              ),
            ),
          ),
          // Floating Orbs
          Positioned(
            top: 40,
            right: -60,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Search Bar (Telegram Style)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            authenticatorProvider.setSearchQuery(value);
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search accounts...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: authenticatorProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : groupedAccounts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          itemCount: serviceNames.length,
                          itemBuilder: (context, index) {
                            final serviceName = serviceNames[index];
                            final accounts = groupedAccounts[serviceName]!;

                            return Column(
                              children: accounts.map((account) {
                                final code = authenticatorProvider.generateCode(
                                  account.secret,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Dismissible(
                                    key: ValueKey(account.id),
                                    direction: DismissDirection.endToStart,
                                    background: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        color: Colors.red.withOpacity(0.8),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    confirmDismiss: (_) async {
                                      await _confirmAndDeleteAccount(
                                        context,
                                        account,
                                      );
                                      return false;
                                    },
                                    child: _buildAccountTile(
                                      key: ValueKey(account.id),
                                      context,
                                      account: account,
                                      code: code,
                                      primaryColor: Colors.white,
                                      progressValue: progressValue,
                                      secondsRemaining: secondsRemaining,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Accounts Yet',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap the scan button to add your first 2FA account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          key: key,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code $code copied'),
                  duration: const Duration(milliseconds: 1200),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: assetPath != null
                        ? Image.asset(assetPath)
                        : Text(
                            account.serviceName[0].toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.serviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          account.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'monospace',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: CircularProgressIndicator(
                              value: progressValue,
                              strokeWidth: 3,
                              color: secondsRemaining < 5
                                  ? Colors.redAccent
                                  : Colors.white70,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                          Text(
                            '$secondsRemaining',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondsRemaining < 5
                                  ? Colors.redAccent
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.more_vert,
                      //     color: Colors.white70,
                      //   ),
                      //   onPressed: () =>
                      //       _confirmAndDeleteAccount(context, account),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
