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
      appBar: AppBar(title: Text(T.settingsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSettingCard(
              context,
              icon: Icons.brightness_6_outlined,
              title: T.themeMode,
              description: T.systemMode,
              children: [
                SwitchListTile(
                  title: Text(T.darkMode),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (bool isOn) {
                    settings.setThemeMode(
                      isOn ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(T.systemMode),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,

                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      settings.setThemeMode(newValue);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingCard(
              context,
              icon: Icons.language,
              title: T.language,
              description: T.languageName,
              children: [
                ListTile(
                  title: Text(T.languageName),
                  trailing: DropdownButton<String>(
                    value: settings.locale?.languageCode ?? 'en',
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        settings.setLocale(newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(
                        value: 'km',
                        child: Text('ភាសាខ្មែរ (Khmer)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingCard(
              context,
              icon: Icons.color_lens_outlined,
              title: T.primaryColor,
              description: 'Select the accent color for the app.',
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildColorOption(
                          Colors.deepPurple,
                          settings,
                          primaryColor,
                        ),
                        _buildColorOption(Colors.blue, settings, primaryColor),
                        _buildColorOption(Colors.red, settings, primaryColor),
                        _buildColorOption(Colors.green, settings, primaryColor),
                        _buildColorOption(
                          Colors.orange,
                          settings,
                          primaryColor,
                        ),
                        _buildColorOption(Colors.pink, settings, primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon, color: Theme.of(context).primaryColor),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(description),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildColorOption(
    Color color,
    SettingsProvider settings,
    Color primaryColor,
  ) {
    final isSelected = settings.primaryColor == color;
    return GestureDetector(
      onTap: () => settings.setPrimaryColor(color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: isSelected
              ? Icon(Icons.check, color: Colors.white, size: 24)
              : null,
        ),
      ),
    );
  }
}
