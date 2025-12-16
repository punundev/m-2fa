import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/core/secure_storage.dart';
import 'package:auth/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _loadProfile(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.profile == null && authProvider.user != null) {
      await authProvider.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final T = AppLocalizations.of(context)!;

    final user = authProvider.user;
    final profile = authProvider.profile;
    final primaryColor = Theme.of(context).primaryColor;

    return FutureBuilder(
      future: _loadProfile(context),
      builder: (context, snapshot) {
        final userName =
            profile?.fullName ??
            user?.userMetadata?['name'] ??
            T.userNameDefault;
        final avatarUrl =
            profile?.avatarUrl ?? user?.userMetadata?['avatar_url'];
        final email = user?.email ?? T.emailDefault;

        String userInitials = userName.isNotEmpty
            ? userName[0].toUpperCase()
            : (email.isNotEmpty ? email[0].toUpperCase() : 'NA');

        if (user != null &&
            profile == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              T.appName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: const [],
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl) as ImageProvider
                            : null,
                        backgroundColor: primaryColor.withOpacity(0.15),
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? Text(
                                userInitials,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(T.editProfile),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/edit-profile');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                Text(
                  T.securityAccount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),

                ListTile(
                  leading: Icon(Icons.vpn_key_outlined, color: primaryColor),
                  title: Text(T.changePin),
                  subtitle: Text(T.changePinSubtitle),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pushNamed('/change-pin');
                  },
                ),
                Divider(indent: 20, endIndent: 20),

                ListTile(
                  leading: Icon(Icons.lock_reset_outlined, color: primaryColor),
                  title: Text(T.changePassword),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pushNamed('/change-password');
                  },
                ),
                Divider(indent: 20, endIndent: 20),

                const SizedBox(height: 40),

                ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    T.logoutTitle,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    await authProvider.logout();
                    await SecureStorage.clearToken();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
