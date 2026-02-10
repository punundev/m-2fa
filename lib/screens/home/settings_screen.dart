import 'dart:ui';
import 'package:auth/controllers/controllers/settings_provider.dart';
import 'package:auth/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final T = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          T.settingsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
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
          // Animated Orbs
          Positioned(
            top: 20,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Glass Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildGlassCategory(
                    context,
                    title: T.themeMode,
                    description: T.systemMode,
                    icon: Icons.brightness_6_rounded,
                    children: [
                      SwitchListTile(
                        title: Text(
                          T.darkMode,
                          style: const TextStyle(color: Colors.white),
                        ),
                        secondary: const Icon(
                          Icons.dark_mode_rounded,
                          color: Colors.white70,
                        ),
                        value: settings.themeMode == ThemeMode.dark,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.white38,
                        onChanged: (bool isOn) {
                          settings.setThemeMode(
                            isOn ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text(
                          T.systemMode,
                          style: const TextStyle(color: Colors.white),
                        ),
                        secondary: const Icon(
                          Icons.settings_brightness_rounded,
                          color: Colors.white70,
                        ),
                        value: ThemeMode.system,
                        groupValue: settings.themeMode,
                        activeColor: Colors.white,
                        onChanged: (ThemeMode? newValue) {
                          if (newValue != null) {
                            settings.setThemeMode(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildGlassCategory(
                    context,
                    title: T.language,
                    description: T.languageName,
                    icon: Icons.language_rounded,
                    children: [
                      ListTile(
                        title: Text(
                          T.languageName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: const Icon(
                          Icons.translate_rounded,
                          color: Colors.white70,
                        ),
                        trailing: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(canvasColor: primaryColor.withBlue(100)),
                          child: DropdownButton<String>(
                            value: settings.locale?.languageCode ?? 'en',
                            dropdownColor: primaryColor.withOpacity(0.8),
                            iconEnabledColor: Colors.white,
                            underline: const SizedBox(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                settings.setLocale(newValue);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'km',
                                child: Text('ភាសាខ្មែរ'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                              DropdownMenuItem(value: 'zh', child: Text('中文')),
                              DropdownMenuItem(value: 'ja', child: Text('日本語')),
                              DropdownMenuItem(
                                value: 'ru',
                                child: Text('Русский'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildGlassCategory(
                    context,
                    title: T.primaryColor,
                    description: 'Accent color for the application.',
                    icon: Icons.palette_rounded,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildColorOption(Colors.deepPurple, settings),
                              _buildColorOption(Colors.blue, settings),
                              _buildColorOption(Colors.red, settings),
                              _buildColorOption(Colors.green, settings),
                              _buildColorOption(Colors.orange, settings),
                              _buildColorOption(Colors.pink, settings),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCategory(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  description,
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: Colors.white10),
              ),
              ...children,
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, SettingsProvider settings) {
    final isSelected = settings.primaryColor == color;
    return GestureDetector(
      onTap: () => settings.setPrimaryColor(color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}
