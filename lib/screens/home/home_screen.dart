import 'dart:async';
import 'dart:ui';
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

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
    ).push(MaterialPageRoute(builder: (_) => const QRScannerScreen()));

    if (!mounted) return;
    context.read<AuthenticatorProvider>().fetchAccounts();
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
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Delete Account?'),
          content: Text(
            'Remove 2FA for ${account.serviceName} (${account.email})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    final provider = context.watch<AuthenticatorProvider>();
    final groupedAccounts = provider.groupedAccounts;
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
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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
          // Main Content
          provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : groupedAccounts.isEmpty
              ? _buildEmptyState()
              : SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: serviceNames.length,
                    itemBuilder: (context, index) {
                      final serviceName = serviceNames[index];
                      final accounts = groupedAccounts[serviceName]!;

                      return Column(
                        children: accounts.map((account) {
                          final code = provider.generateCode(account.secret);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Dismissible(
                              key: ValueKey(account.id),
                              direction: DismissDirection.endToStart,
                              background: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  color: Colors.red.withOpacity(0.8),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _handleAddAccount(context),
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
        ),
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
                      IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            _confirmAndDeleteAccount(context, account),
                      ),
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

// import 'dart:async';
// import 'package:auth/screens/scan/qr_scanner_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:auth/controllers/authenticator_provider.dart';
// import 'package:auth/models/authenticator_model.dart';

// const String _appName = 'Nun Auth';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AuthenticatorProvider>().fetchAccounts();
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _handleAddAccount(BuildContext context) async {
//     await Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (context) => const QRScannerScreen()));

//     if (!mounted) return;
//     context.read<AuthenticatorProvider>().fetchAccounts();
//   }

//   String? _getAssetPath(String serviceName) {
//     final lowerCaseName = serviceName.toLowerCase();
//     if (lowerCaseName.contains('facebook')) {
//       return 'assets/images/facebook.png';
//     } else if (lowerCaseName.contains('github')) {
//       return 'assets/images/github.png';
//     } else if (lowerCaseName.contains('google')) {
//       return 'assets/images/google.png';
//     } else if (lowerCaseName.contains('brevo')) {
//       return 'assets/images/brevo.png';
//     } else if (lowerCaseName.contains('netify')) {
//       return 'assets/images/netify.png';
//     } else if (lowerCaseName.contains('vercel')) {
//       return 'assets/images/vercel.png';
//     } else if (lowerCaseName.contains('supabase')) {
//       return 'assets/images/supabase.png';
//     } else if (lowerCaseName.contains('firebase')) {
//       return 'assets/images/firebase.png';
//     } else if (lowerCaseName.contains('termius')) {
//       return 'assets/images/termius.png';
//     } else if (lowerCaseName.contains('nun note')) {
//       return 'assets/images/nun-note.png';
//     } else if (lowerCaseName.contains('hostinger') ||
//         lowerCaseName.contains('namecheap')) {
//       return 'assets/images/domain.png';
//     } else if (lowerCaseName.contains('contabo') ||
//         lowerCaseName.contains('interser')) {
//       return 'assets/images/server.png';
//     }
//     return null;
//   }

//   Future<void> _confirmAndDeleteAccount(
//     BuildContext context,
//     AuthenticatorAccount account,
//   ) async {
//     final provider = context.read<AuthenticatorProvider>();

//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Delete Account?'),
//           content: Text(
//             'Are you sure you want to remove the 2FA account for ${account.serviceName} (${account.email})? This action cannot be undone.',
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(dialogContext).pop(false),
//             ),
//             TextButton(
//               child: const Text('Delete', style: TextStyle(color: Colors.red)),
//               onPressed: () => Navigator.of(dialogContext).pop(true),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete == true && context.mounted) {
//       try {
//         await provider.deleteAccount(account.id);

//         await provider.fetchAccounts();

//         if (!context.mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '${account.serviceName} account removed successfully.',
//             ),
//           ),
//         );
//       } catch (e) {
//         if (!context.mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to delete account. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authenticatorProvider = context.watch<AuthenticatorProvider>();
//     final accounts = authenticatorProvider.accounts;
//     final primaryColor = Theme.of(context).primaryColor;

//     final currentSecond = (DateTime.now().millisecondsSinceEpoch / 1000)
//         .floor();
//     final secondsRemaining = 30 - (currentSecond % 30);
//     final progressValue = secondsRemaining / 30;

//     final groupedAccounts = authenticatorProvider.groupedAccounts;
//     final serviceNames = groupedAccounts.keys.toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           _appName,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.menu),
//           onPressed: () => Scaffold.of(context).openDrawer(),
//         ),
//         automaticallyImplyLeading: false,
//       ),
//       body: authenticatorProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : accounts.isEmpty
//           ? _buildEmptyState()
//           : ListView.builder(
//               padding: const EdgeInsets.only(bottom: 80.0),
//               itemCount: accounts.length,
//               itemBuilder: (context, index) {
//                 final account = accounts[index];
//                 final code = authenticatorProvider.generateCode(account.secret);

//                 return Dismissible(
//                   key: ValueKey(account.id),
//                   direction: DismissDirection.endToStart,
//                   background: Container(
//                     color: Colors.red,
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.only(right: 20),
//                     child: const Icon(Icons.delete, color: Colors.white),
//                   ),

//                   confirmDismiss: (direction) async {
//                     try {
//                       await _confirmAndDeleteAccount(context, account);
//                       return false;
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Error: $e'),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                       return false;
//                     }
//                   },

//                   child: _buildAccountTile(
//                     key: ValueKey(account.id),
//                     context,
//                     account: account,
//                     code: code,
//                     primaryColor: primaryColor,
//                     progressValue: progressValue,
//                     secondsRemaining: secondsRemaining,
//                   ),
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _handleAddAccount(context),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         child: const Icon(Icons.qr_code_scanner),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey.shade400),
//           const SizedBox(height: 20),
//           const Text(
//             'No Authenticator Accounts Added',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Tap the "+" button to scan a 2FA QR code.',
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAccountTile(
//     BuildContext context, {
//     required Key key,
//     required AuthenticatorAccount account,
//     required String code,
//     required Color primaryColor,
//     required double progressValue,
//     required int secondsRemaining,
//   }) {
//     final assetPath = _getAssetPath(account.serviceName);

//     return Container(
//       key: key,
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.shade300, width: 1),
//         ),
//       ),
//       child: InkWell(
//         onTap: () {
//           Clipboard.setData(ClipboardData(text: code));
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Code $code copied for ${account.serviceName}'),
//               duration: const Duration(milliseconds: 1200),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: primaryColor.withOpacity(0.1),
//                 child: assetPath != null
//                     ? Image.asset(assetPath, width: 24, height: 24)
//                     : Text(
//                         account.serviceName[0].toUpperCase(),
//                         style: TextStyle(
//                           color: primaryColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       account.serviceName,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 17,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       account.email,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     code,
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 2.5,
//                       fontFamily: 'monospace',
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         height: 35,
//                         width: 35,
//                         child: CircularProgressIndicator(
//                           value: progressValue,
//                           strokeWidth: 3,
//                           color: secondsRemaining < 5
//                               ? Colors.red.shade600
//                               : primaryColor,
//                           backgroundColor: Colors.grey.shade200,
//                         ),
//                       ),
//                       Text(
//                         '$secondsRemaining',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: secondsRemaining < 5
//                               ? Colors.red.shade600
//                               : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.more_vert, color: Colors.grey),
//                     onPressed: () => _confirmAndDeleteAccount(context, account),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
