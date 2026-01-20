import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:ueo_app/AdminPage.dart';
import 'package:ueo_app/SplashScreen.dart';
import 'package:ueo_app/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ueo_app/Loginscreen.dart';
import 'package:ueo_app/Signupscreen.dart';
import 'package:ueo_app/HomePage.dart';
import 'package:ueo_app/MainPage.dart';
import 'package:ueo_app/Memories.dart';
import 'package:ueo_app/Profile.dart';
import 'package:ueo_app/Settings.dart';
import 'package:ueo_app/AboutUs.dart';
import 'package:ueo_app/ChatScreen.dart';
import 'package:ueo_app/NotificationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  // 2. Initialize Stripe
  Stripe.publishableKey = dotenv.env['stripePublishableKey'] ?? dotenv.env['stripePublishablekey'] ?? "";
  await Stripe.instance.applySettings();

  // 3. Initialize Firebase
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
          title: 'UEO App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: themeProvider.getIsDarkTheme ? Brightness.dark : Brightness.light,
            ),
            fontFamily: 'Roboto',
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            cardTheme: CardThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
          initialRoute: "/splash",
          routes: {
            "/splash": (context) => const SplashScreen(),
            "/": (context) => const Loginscreen(),
            "/Signupscreen": (context) => const Signupscreen(),
            "/MainPage": (context) => const MainPage(),
            "/HomePage": (context) => const HomePage(),
            "/Memories": (context) => const Memories(),
            "/Profile": (context) => const Profile(),
            "/Settings": (context) => const Settings(),
            "/AboutUs": (context) => const AboutUs(),
            "/ChatScreen": (context) => const ChatScreen(),
            "/AdminPage": (context) => const AdminPage(),
            "/NotificationPage": (context) => const NotificationPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
