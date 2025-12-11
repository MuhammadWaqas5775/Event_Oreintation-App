import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ueo_app/theme_provider.dart';
import 'Loginscreen.dart';
import 'Signupscreen.dart';
import 'HomePage.dart';
import 'MainPage.dart';
import 'Memories.dart';
import 'Profile.dart';
import 'Map.dart';
import 'Settings.dart';
import 'AboutUs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: ThemeData(
            brightness: themeProvider.getIsDarkTheme ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.purple,
          ),
          initialRoute: "/",
          routes: {
            "/": (context) => Loginscreen(),
            "/Signupscreen": (context) => Signupscreen(),
            "/MainPage": (context) => MainPage(),
            "/HomePage": (context) => HomePage(),
            "/Memories": (context) => Memories(),
            "/Map": (context) => Map(),
            "/Profile": (context) => Profile(),
            "/Settings": (context) => Settings(),
            "/AboutUs": (context) => AboutUs(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
