import 'dart:ui';
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Glass Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        backgroundImage:
                            (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl) as ImageProvider
                            : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? Text(
                                userInitials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildDrawerItem(
                context,
                icon: Icons.home_rounded,
                title: T.homeTitle,
                onTap: () {
                  Navigator.pop(context);
                  onNavigate(0);
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.person_rounded,
                title: T.profileTitle,
                onTap: () {
                  Navigator.pop(context);
                  onNavigate(1);
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.settings_rounded,
                title: T.settingsTitle,
                onTap: () => _navigateToRoute(context, '/settings'),
              ),
              const Spacer(),
              const Divider(color: Colors.white10, indent: 20, endIndent: 20),
              _buildDrawerItem(
                context,
                icon: Icons.logout_rounded,
                title: T.logoutTitle,
                titleColor: Colors.redAccent.withOpacity(0.8),
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
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: titleColor ?? Colors.white.withOpacity(0.7)),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        hoverColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
