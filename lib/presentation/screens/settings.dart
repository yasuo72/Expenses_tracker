import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expanse_management/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedCurrency = 'INR'; // Default currency
  String selectedLanguage = 'English';
  List<String> currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY', 'AUD'];
  List<String> languages = ['English', 'Hindi', 'Spanish', 'French'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCurrency = prefs.getString('selectedCurrency') ?? 'INR';
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _logout() {
    // Implement logout logic (e.g., Firebase sign-out or clear session)
    print("User logged out");
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to login screen
  }

  Future<void> _backupData() async {
    // Implement backup logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Backup completed successfully!")),
    );
  }

  Future<void> _restoreData() async {
    // Implement restore logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data restored successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Currency Selector
            ListTile(
              title: Text("Select Currency"),
              trailing: DropdownButton<String>(
                value: selectedCurrency,
                items: currencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newCurrency) {
                  if (newCurrency != null) {
                    setState(() => selectedCurrency = newCurrency);
                    _saveSetting('selectedCurrency', newCurrency);
                  }
                },
              ),
            ),

            // Dark Mode Toggle
            SwitchListTile(
              title: Text("Dark Mode"),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
              },
            ),

            // Language Selector
            ListTile(
              title: Text("Select Language"),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                items: languages.map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    setState(() => selectedLanguage = newLanguage);
                    _saveSetting('selectedLanguage', newLanguage);
                  }
                },
              ),
            ),

            Divider(),

            // Backup & Restore Options
            ListTile(
              title: Text("Backup Data"),
              leading: Icon(Icons.backup),
              onTap: _backupData,
            ),
            ListTile(
              title: Text("Restore Data"),
              leading: Icon(Icons.restore),
              onTap: _restoreData,
            ),

            Divider(),

            // Logout Button
            ListTile(
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
