import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AboutUs.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
      ListTile(
      title: Text('About Us'),
      leading: Icon(Icons.question_mark),
      onTap: (){
        Navigator.pushNamed(context, 'AboutUs');
      },
    ),
    ListTile(
      title: Text('Logout'),
      leading: Icon(Icons.logout),
      onTap: (){
          Navigator.pushNamed(context, '/');
      },

    ),
        ]
    )
    );
  }
}
