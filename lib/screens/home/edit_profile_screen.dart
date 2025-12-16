import 'dart:io';
import 'package:auth/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auth/controllers/auth_provider.dart';
import 'package:auth/services/profile_service.dart';
import 'package:auth/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;
  File? _imageFile;

  String _currentAvatarUrl = '';

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _nameController.text = user?.userMetadata?['name'] ?? '';
    _currentAvatarUrl = user?.userMetadata?['avatar_url'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    final T = AppLocalizations.of(context)!;

    setState(() => _loading = true);
    String? finalAvatarUrl = _currentAvatarUrl;

    try {
      if (_imageFile != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(T.uploadingAvatar)));
        finalAvatarUrl = await StorageService.uploadAvatar(_imageFile!);
      }

      await ProfileService.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: finalAvatarUrl,
      );

      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).reloadUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T.profileSaveSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${T.profileSaveFailed}${e.toString()}'),
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
    final T = AppLocalizations.of(context)!;

    final primaryColor = Theme.of(context).primaryColor;
    final displayImage = _imageFile != null
        ? FileImage(_imageFile!) as ImageProvider
        : (_currentAvatarUrl.isNotEmpty
              ? NetworkImage(_currentAvatarUrl) as ImageProvider
              : null);

    final String initialName = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: Text(T.editProfileTitle),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryColor.withOpacity(0.15),
                    backgroundImage: displayImage,
                    child: displayImage == null
                        ? Text(
                            initialName,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: _inputDecoration(
                T.displayNameLabel,
                Icons.person_outline,
                primaryColor,
              ),
            ),
            const SizedBox(height: 16),

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
                    child: Text(
                      T.saveProfile,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
