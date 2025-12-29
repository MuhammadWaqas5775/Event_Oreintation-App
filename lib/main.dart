import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:ueo_app/AdminPage.dart';
import 'package:ueo_app/SplashScreen.dart';
import 'package:ueo_app/theme_provider.dart';
import 'package:ueo_app/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Loginscreen.dart';
import 'Signupscreen.dart';
import 'HomePage.dart';
import 'MainPage.dart';
import 'Memories.dart';
import 'Profile.dart';
import 'Mapscreen.dart';
import 'Settings.dart';
import 'AboutUs.dart';
import 'ChatScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = dotenv.env['stripePublishablekey']!;
  await Stripe.instance.applySettings();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Notifications
  await NotificationService().init();
  
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
            "/Map": (context) => const Mapscreen(),
            "/Profile": (context) => const Profile(),
            "/Settings": (context) => const Settings(),
            "/AboutUs": (context) => const AboutUs(),
            "/ChatScreen": (context) => const ChatScreen(),
            "/AdminPage": (context) => const AdminPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
