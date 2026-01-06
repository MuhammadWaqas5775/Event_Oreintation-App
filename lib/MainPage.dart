import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ueo_app/HomePage.dart';
import 'Memories.dart';
import 'Mapscreen.dart';
import 'Profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Navigation State
  int currentIndex = 0;
  late CircularBottomNavigationController _navController;

  // User & Profile State
  final User? user = FirebaseAuth.instance.currentUser;
  String? _imageUrl;
  late final CloudinaryPublic cloudinary;
  late final DocumentReference<Map<String, dynamic>> _userDoc;

  // Tab items for bottom navigation
  final List<TabItem> tabItems = [
    TabItem(Icons.calendar_month, "Schedule", Colors.deepPurple),
    TabItem(Icons.image, "Memories", Colors.deepPurple),
    TabItem(Icons.location_on, "Location", Colors.deepPurple),
    TabItem(Icons.person, "Profile", Colors.deepPurple),
  ];
  Future<void> _chat()async{
    Navigator.pushNamed(context, "/ChatScreen");
  }
  @override
  void initState() {
    super.initState();
    _navController = CircularBottomNavigationController(currentIndex);
    cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);

    if (user != null) {
      _userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      _loadProfileImage();
    }
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  // --- Profile Logic ---

  Future<void> _loadProfileImage() async {
    final snapshot = await _userDoc.get();
    if (snapshot.exists && mounted) {
      setState(() {
        _imageUrl = snapshot.data()?['profileImageUrl'];
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && user != null) {
      try {
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path, resourceType: CloudinaryResourceType.Image),
        );
        await _userDoc.set({'profileImageUrl': response.secureUrl}, SetOptions(merge: true));
        if (mounted) {
          setState(() {
            _imageUrl = response.secureUrl;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
    }
  }

  // --- UI Components ---

  List<Widget> get _pages => [
    const HomePage(),
    const Memories(),
    const Mapscreen(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer:Drawer(
        child: Container(
          color: Colors.grey[600],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                currentAccountPicture: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                    child: _imageUrl == null ? const Icon(Icons.camera_alt, color: Colors.white) : null,
                  ),
                ),
                accountName: Text(user?.displayName ?? "User"),
                accountEmail: Text(user?.email ?? "user@example.com"),
              ),
              _drawerItem(Icons.home, "Home", () => Navigator.pushNamed(context,"/MainPage")),
              _drawerItem(Icons.person, "Profile", () => Navigator.pushNamed(context, "/Profile")),
              _drawerItem(Icons.settings, "Settings", () => Navigator.pushNamed(context, "/Settings")),
              _drawerItem(Icons.info, "About Us", () => Navigator.pushNamed(context, "/AboutUs")),

              const Divider(color: Colors.white24),
              _drawerItem(Icons.logout, "Logout", () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title:  const Text("UEO App", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/background.png", fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: IndexedStack(
              index: currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      extendBody: true,

      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: _navController,
        barHeight: 60,
        circleSize: 50,
        iconsSize: 20,
        selectedCallback: (int? selectedPos) {
          setState(() {
            currentIndex = selectedPos ?? 0;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed:_chat,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          child:const Icon(Icons.chat, color: Colors.white),
        ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
