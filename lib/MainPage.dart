import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ueo_app/HomePage.dart';
import 'package:ueo_app/Loginscreen.dart';
import 'Memories.dart';
import 'Mapscreen.dart';
import 'Profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? _image;
  String? _imageUrl;
  late final CloudinaryPublic cloudinary;
  final User? user = FirebaseAuth.instance.currentUser;
  late final DocumentReference<Map<String, dynamic>> _userDoc;

  int currentindex = 0;
  late CircularBottomNavigationController _navigationController;

  List<TabItem> tabItems = List.of([
    TabItem(Icons.calendar_month, "Schedule", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
    TabItem(Icons.image, "Memories", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
    TabItem(Icons.location_on, "Location", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
    TabItem(Icons.person, "Profile", Colors.deepPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
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
        SnackBar(
          content: Text('Failed to load profile image: $e'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    if (user == null) return;
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
        CloudinaryFile.fromFile(_image!.path,
            resourceType: CloudinaryResourceType.Image),
      );
      final imageUrl = response.secureUrl;
      await _userDoc
          .set({'profileImageUrl': imageUrl}, SetOptions(merge: true));
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

  List pages = [
    const HomePage(),
    const Memories(),
    const Mapscreen(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundImage:
                      _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  child: _imageUrl == null && _image == null
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pushNamed(context, "/MainPage");
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pushNamed(context, "/Profile");
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pushNamed(context, "/Settings");
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/ChatScreen");
              },
              child: const Icon(
                Icons.chat,
                color: Colors.white,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: pages[currentindex],
      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        selectedCallback: (int? selectedPos) {
          setState(() {
            currentindex = selectedPos ?? 0;
          });
        },
      ),
    );
  }
}
