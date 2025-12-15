import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/core/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String _appName = 'Nun Auth';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final primaryColor = Theme.of(context).primaryColor;

    final userName = user?.appMetadata?['name'] ?? 'User Name';
    final avatarUrl = user?.appMetadata?['avatarUrl'];
    final email = user?.email ?? 'No email available';

    String userInitials = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : 'NA');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
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
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 30),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
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
              'Security & Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.verified_user_outlined, color: primaryColor),
              title: const Text('2-Factor Authentication'),
              subtitle: const Text('Add an extra layer of security.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            Divider(indent: 20, endIndent: 20),

            ListTile(
              leading: Icon(Icons.vpn_key_outlined, color: primaryColor),
              title: const Text('Change PIN Code'),
              subtitle: const Text('Update your quick access 4-digit PIN.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pushNamed('/change-pin');
              },
            ),
            Divider(indent: 20, endIndent: 20),

            ListTile(
              leading: Icon(Icons.lock_reset_outlined, color: primaryColor),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pushNamed('/change-password');
              },
            ),
            Divider(indent: 20, endIndent: 20),

            ListTile(
              leading: Icon(Icons.link, color: primaryColor),
              title: const Text('Linked Accounts'),
              subtitle: const Text('Manage Google, GitHub connections.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
  }
}
