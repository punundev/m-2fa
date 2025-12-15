import 'dart:async';
import 'package:auth/screens/scan/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/controllers/authenticator_provider.dart';
import 'package:auth/models/authenticator_model.dart';

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

    if (mounted) {
      context.read<AuthenticatorProvider>().fetchAccounts();
    }
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
    required AuthenticatorAccount account,
    required String code,
    required Color primaryColor,
    required double progressValue,
    required int secondsRemaining,
  }) {
    final assetPath = _getAssetPath(account.serviceName);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      account.email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            value: progressValue,
                            strokeWidth: 3,
                            color: secondsRemaining < 5
                                ? Colors.red
                                : primaryColor,
                            backgroundColor: primaryColor.withOpacity(0.2),
                          ),
                        ),
                        Text(
                          '$secondsRemaining',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: secondsRemaining < 5
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
// import 'package:auth/controllers/auth_provider.dart';
// import 'package:auth/controllers/authenticator_provider.dart';
// import 'package:auth/models/authenticator_model.dart';

// const String _appName = 'Nun Auth';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

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

//     if (mounted) {
//       context.read<AuthenticatorProvider>().fetchAccounts();
//     }
//   }

//   // Helper function to get asset path based on service name
//   String? _getAssetPath(String serviceName) {
//     final lowerCaseName = serviceName.toLowerCase();
//     if (lowerCaseName.contains('facebook')) {
//       return 'assets/images/facebook.png';
//     } else if (lowerCaseName.contains('github')) {
//       return 'assets/images/github.png';
//     } else if (lowerCaseName.contains('google')) {
//       return 'assets/images/google.png';
//     }
//     // Return null if no specific asset is found
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();
//     final authenticatorProvider = context.watch<AuthenticatorProvider>();
//     final accounts = authenticatorProvider.accounts;
//     final primaryColor = Theme.of(context).primaryColor;

//     final currentSecond = (DateTime.now().millisecondsSinceEpoch / 1000)
//         .floor();
//     final secondsRemaining = 30 - (currentSecond % 30);
//     final progressValue = secondsRemaining / 30;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           _appName,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: () async {
//               await authProvider.logout();
//               if (!context.mounted) return;
//               Navigator.of(context).pushReplacementNamed('/login');
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),

//       body: authenticatorProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : accounts.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.qr_code_scanner,
//                     size: 80,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'No Authenticator Accounts Added',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Tap the "+" button to scan a 2FA QR code.',
//                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.only(top: 10, bottom: 80),
//               itemCount: accounts.length,
//               itemBuilder: (context, index) {
//                 final account = accounts[index];
//                 final code = authenticatorProvider.generateCode(account.secret);

//                 return _buildAccountTile(
//                   context,
//                   account: account,
//                   code: code,
//                   primaryColor: primaryColor,
//                   progressValue: progressValue,
//                   secondsRemaining: secondsRemaining,
//                 );
//               },
//             ),

//       // Change 1: Use a regular FloatingActionButton (no 'label' or 'extended')
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _handleAddAccount(context),
//         child: const Icon(Icons.qr_code_scanner),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }

//   Widget _buildAccountTile(
//     BuildContext context, {
//     required AuthenticatorAccount account,
//     required String code,
//     required Color primaryColor,
//     required double progressValue,
//     required int secondsRemaining,
//   }) {
//     // Check if an asset path exists for the service
//     final assetPath = _getAssetPath(account.serviceName);

//     return ListTile(
//       onTap: () {
//         Clipboard.setData(ClipboardData(text: code));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Code $code copied for ${account.serviceName}'),
//           ),
//         );
//       },
//       leading: CircleAvatar(
//         backgroundColor: primaryColor.withOpacity(0.1),
//         // Change 2: Use Image.asset if an asset path is found, otherwise fallback to Text
//         child: assetPath != null
//             ? Image.asset(
//                 assetPath,
//                 width: 24, // Adjust size as needed
//                 height: 24, // Adjust size as needed
//               )
//             : Text(
//                 account.serviceName[0].toUpperCase(),
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//       title: Text(
//         account.serviceName,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//       ),
//       subtitle: Text(
//         account.email,
//         style: TextStyle(color: Colors.grey.shade600),
//       ),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             code,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w900,
//               letterSpacing: 2,
//             ),
//           ),
//           const SizedBox(width: 15),
//           SizedBox(
//             height: 24,
//             width: 24,
//             child: CircularProgressIndicator(
//               value: progressValue,
//               strokeWidth: 3,
//               color: secondsRemaining < 5 ? Colors.red : primaryColor,
//               backgroundColor: primaryColor.withOpacity(0.2),
//             ),
//           ),
//         ],
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//     );
//   }
// }

// import 'dart:async';
// import 'package:auth/screens/scan/qr_scanner_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:auth/controllers/auth_provider.dart';
// import 'package:auth/controllers/authenticator_provider.dart';
// import 'package:auth/models/authenticator_model.dart';

// const String _appName = 'Nun Auth';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

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

//     if (mounted) {
//       context.read<AuthenticatorProvider>().fetchAccounts();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();
//     final authenticatorProvider = context.watch<AuthenticatorProvider>();
//     final accounts = authenticatorProvider.accounts;
//     final primaryColor = Theme.of(context).primaryColor;

//     final currentSecond = (DateTime.now().millisecondsSinceEpoch / 1000)
//         .floor();
//     final secondsRemaining = 30 - (currentSecond % 30);
//     final progressValue = secondsRemaining / 30;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           _appName,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: () async {
//               await authProvider.logout();
//               if (!context.mounted) return;
//               Navigator.of(context).pushReplacementNamed('/login');
//             },
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),

//       body: authenticatorProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : accounts.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.qr_code_scanner,
//                     size: 80,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'No Authenticator Accounts Added',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Tap the "+" button to scan a 2FA QR code.',
//                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.only(top: 10, bottom: 80),
//               itemCount: accounts.length,
//               itemBuilder: (context, index) {
//                 final account = accounts[index];
//                 final code = authenticatorProvider.generateCode(account.secret);

//                 return _buildAccountTile(
//                   context,
//                   account: account,
//                   code: code,
//                   primaryColor: primaryColor,
//                   progressValue: progressValue,
//                   secondsRemaining: secondsRemaining,
//                 );
//               },
//             ),

//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _handleAddAccount(context),
//         icon: const Icon(Icons.qr_code_scanner),
//         label: const Text('Add'),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }

//   Widget _buildAccountTile(
//     BuildContext context, {
//     required AuthenticatorAccount account,
//     required String code,
//     required Color primaryColor,
//     required double progressValue,
//     required int secondsRemaining,
//   }) {
//     return ListTile(
//       onTap: () {
//         Clipboard.setData(ClipboardData(text: code));
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Code $code copied for ${account.serviceName}'),
//           ),
//         );
//       },
//       leading: CircleAvatar(
//         backgroundColor: primaryColor.withOpacity(0.1),
//         child: Text(
//           account.serviceName[0].toUpperCase(),
//           style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
//         ),
//       ),
//       title: Text(
//         account.serviceName,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//       ),
//       subtitle: Text(
//         account.email,
//         style: TextStyle(color: Colors.grey.shade600),
//       ),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             code,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w900,
//               letterSpacing: 2,
//             ),
//           ),
//           const SizedBox(width: 15),
//           SizedBox(
//             height: 24,
//             width: 24,
//             child: CircularProgressIndicator(
//               value: progressValue,
//               strokeWidth: 3,
//               color: secondsRemaining < 5 ? Colors.red : primaryColor,
//               backgroundColor: primaryColor.withOpacity(0.2),
//             ),
//           ),
//         ],
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//     );
//   }
// }
