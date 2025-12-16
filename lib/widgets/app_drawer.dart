import 'package:auth/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/core/secure_storage.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.primaryColor,
    required this.onNavigate,
  });

  final Color primaryColor;
  final void Function(int index) onNavigate;

  void _navigateToRoute(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    final T = AppLocalizations.of(context)!;

    final user = authProvider.user;
    final profile = authProvider.profile;

    final userName =
        profile?.fullName ?? user?.userMetadata?['name'] ?? 'User Account';
    final avatarUrl = profile?.avatarUrl ?? user?.userMetadata?['avatar_url'];
    final email = user?.email ?? 'No email available';

    String userInitials = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : 'NA');

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              radius: 30,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl) as ImageProvider
                  : null,
              backgroundColor: Colors.white,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                      userInitials,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    )
                  : null,
            ),
            decoration: BoxDecoration(color: primaryColor),
            onDetailsPressed: () {
              Navigator.pop(context);
              onNavigate(1);
            },
          ),

          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(T.homeTitle),
            onTap: () {
              Navigator.pop(context);
              onNavigate(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(T.profileTitle),
            onTap: () {
              Navigator.pop(context);
              onNavigate(1);
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(T.settingsTitle),
            onTap: () => _navigateToRoute(context, '/settings'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              T.logoutTitle,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);

              await authProvider.logout();
              await SecureStorage.clearToken();

              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
