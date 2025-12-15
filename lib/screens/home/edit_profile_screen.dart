import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _nameController.text = user?.userMetadata?['name'] ?? '';
    _avatarUrlController.text = user?.userMetadata?['avatar_url'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _loading = true);

    try {
      await ProfileService.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
      );

      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).reloadUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully and synced!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Manage your display name and profile picture.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: _inputDecoration(
                'Display Name (Full Name)',
                Icons.person_outline,
                primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _avatarUrlController,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration(
                'Profile Photo URL',
                Icons.photo_camera_outlined,
                primaryColor,
              ),
            ),

            const SizedBox(height: 40),

            _loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ElevatedButton(
                    onPressed: _loading ? null : _handleSaveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
  String label,
  IconData icon,
  Color primaryColor,
) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: primaryColor),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
  );
}
