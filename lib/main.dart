import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Loginscreen.dart';
import 'Signupscreen.dart';
import 'HomePage.dart';
import 'MainPage.dart';
import 'Memories.dart';
import 'Profile.dart';
import 'Map.dart';
import 'Settings.dart';
import 'AboutUs.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute:"/",
      routes:
      {
        "/": (context) => Loginscreen(),
        "/Signupscreen": (context) => Signupscreen(),
        "/MainPage": (context) => MainPage(),
        "/HomePage": (context) => HomePage(),
        "/Memories":(context)=> Memories(),
        "/Map":(context)=>Map(),
        "/Profile":(context)=>Profile(),
        "/Settings": (context) => Settings(),
        "/AboutUs": (context) =>AboutUs(),
      },
      debugShowCheckedModeBanner: false,

    );
  }
}
