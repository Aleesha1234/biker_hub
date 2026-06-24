import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

// These global notifiers allow the whole app to react to changes.
// To make this fully functional, wrap your MaterialApp in a ValueListenableBuilder
// in your main.dart file.
ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(ThemeMode.light);
ValueNotifier<Locale> appLocaleNotifier = ValueNotifier(const Locale('en'));

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings_suggest_rounded),
            SizedBox(width: 10),
            Text("APP SETTINGS",
                style:
                    TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: BikerColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Appearance"),
            const SizedBox(height: 15),
            _buildThemeOption(
              title: "Light Mode",
              subtitle: "Standard White interface",
              icon: Icons.light_mode_rounded,
              mode: ThemeMode.light,
            ),
            _buildThemeOption(
              title: "Dark Mode",
              subtitle: "Standard Black interface",
              icon: Icons.dark_mode_rounded,
              mode: ThemeMode.dark,
            ),
            _buildThemeOption(
              title: "Medium (System)",
              subtitle: "Follows your device settings",
              icon: Icons.brightness_medium_rounded,
              mode: ThemeMode.system,
            ),
            const SizedBox(height: 30),
            _buildSectionHeader("Language"),
            const SizedBox(height: 15),
            _buildLanguageOption(
              title: "English",
              subtitle: "Default Language",
              locale: const Locale('en'),
              flag: "🇺🇸",
            ),
            _buildLanguageOption(
              title: "Urdu (اردو)",
              subtitle: "مقامی زبان",
              locale: const Locale('ur'),
              flag: "🇵🇰",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title.toUpperCase(),
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: BikerColors.blue,
            letterSpacing: 1));
  }

  Widget _buildThemeOption(
      {required String title,
      required String subtitle,
      required IconData icon,
      required ThemeMode mode}) {
    bool isSelected = appThemeNotifier.value == mode;
    return _buildOptionContainer(
      isSelected: isSelected,
      onTap: () => setState(() => appThemeNotifier.value = mode),
      icon: Icon(icon, color: isSelected ? BikerColors.blue : Colors.grey),
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildLanguageOption(
      {required String title,
      required String subtitle,
      required Locale locale,
      required String flag}) {
    bool isSelected = appLocaleNotifier.value == locale;
    return _buildOptionContainer(
      isSelected: isSelected,
      onTap: () => setState(() => appLocaleNotifier.value = locale),
      icon: Text(flag, style: const TextStyle(fontSize: 22)),
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildOptionContainer(
      {required bool isSelected,
      required VoidCallback onTap,
      required Widget icon,
      required String title,
      required String subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? BikerColors.blue.withOpacity(0.05)
              : BikerColors.greyLt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? BikerColors.blue : Colors.grey.shade200,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: BikerColors.blue),
          ],
        ),
      ),
    );
  }
}
