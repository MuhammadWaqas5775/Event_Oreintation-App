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

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  File? _image;
  String? _imageUrl;
  late final CloudinaryPublic cloudinary;
  final User? user = FirebaseAuth.instance.currentUser;
  late final DocumentReference<Map<String, dynamic>> _userDoc;

  int currentindex = 0;
  late CircularBottomNavigationController _navigationController;

  List<TabItem> tabItems = List.of([
    TabItem(Icons.calendar_month, "Schedule", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    TabItem(Icons.image, "Memories", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    TabItem(Icons.location_on, "Location", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    TabItem(Icons.person, "Profile", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
  ]);

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(currentindex);
    cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);
    if (user != null) {
      _userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      _loadProfileImage();
    }
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    try {
      final snapshot = await _userDoc.get();
      if (snapshot.exists) {
        setState(() {
          _imageUrl = snapshot.data()?['profileImageUrl'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile image: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    if (user == null) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadToCloudinary();
    }
  }

  Future<void> _uploadToCloudinary() async {
    if (_image == null || user == null) return;
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_image!.path, resourceType: CloudinaryResourceType.Image),
      );
      final imageUrl = response.secureUrl;
      await _userDoc.set({'profileImageUrl': imageUrl}, SetOptions(merge: true));
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  List pages = [
    const HomePage(key: ValueKey(0)),
    const Memories(key: ValueKey(1)),
    const Mapscreen(key: ValueKey(2)),
    const Profile(key: ValueKey(3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade400],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                currentAccountPicture: GestureDetector(
                  onTap: _pickImage,
                  child: Hero(
                    tag: 'profile_pic',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                      child: _imageUrl == null && _image == null
                          ? const Icon(Icons.camera_alt, color: Colors.white70)
                          : null,
                    ),
                  ),
                ),
                accountName: Text(user?.displayName ?? "User Name", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Text(user?.email ?? "user@example.com"),
              ),
              _buildDrawerItem(Icons.home, "Home", () => Navigator.pop(context)),
              _buildDrawerItem(Icons.person, "Profile", () => Navigator.pushNamed(context, "/Profile")),
              _buildDrawerItem(Icons.settings, "Settings", () => Navigator.pushNamed(context, "/Settings")),
              _buildDrawerItem(Icons.info, "About Us", () => Navigator.pushNamed(context, "/AboutUs")),
              const Divider(color: Colors.white24),
              _buildDrawerItem(Icons.logout, "Logout", () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("UEO App", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.pushNamed(context, "/ChatScreen"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: 1.1),
              duration: const Duration(seconds: 30),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Image.asset(
                    "assets/background.png",
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeInQuart,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: pages[currentindex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        barHeight: 60,
        circleSize: 50,
        selectedCallback: (int? selectedPos) {
          setState(() {
            currentindex = selectedPos ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
