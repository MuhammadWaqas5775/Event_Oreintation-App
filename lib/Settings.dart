import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ueo_app/theme_provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text("Settings"),
        ),
        body: ListView(children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: Icon(themeProvider.getIsDarkTheme ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.getIsDarkTheme,
            onChanged: (bool value) {
              themeProvider.setDarkTheme(value);
            },
          ),
          ListTile(
            title: const Text('About Us'),
            leading: const Icon(Icons.question_mark),
            onTap: () {
              Navigator.pushNamed(context, '/AboutUs');
            },
          ),

          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ]));
  }
}
