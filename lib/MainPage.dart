import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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

  @override
  void initState() {
    super.initState();
    cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);
    if (user != null) {
      _userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      _loadProfileImage();
    }
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
        SnackBar(
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

List pages=[
  HomePage(),
  Memories(),
  Mapscreen(),
  Profile(),
  Loginscreen(),
];
var currentindex=0;
  void ontap(int index){
    setState(() {
      currentindex=index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
child: ListView(
  children: [
    DrawerHeader(decoration: BoxDecoration(color: Colors.deepPurple),
    child: GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
        child: _imageUrl == null && _image == null ? Icon(Icons.person) : null,
      ),
    ),
    ),
    ListTile(
      leading: Icon(Icons.home),
      title: Text("Home"),
      onTap:(){
        Navigator.pushNamed(context,"/MainPage");
      },
    ),
    ListTile(
      leading: Icon(Icons.person),
      title: Text("Profile"),
      onTap: (){
        Navigator.pushNamed(context,"/Profile");
      },
    ),
    ListTile(
      leading: Icon(Icons.settings),
      title: Text("Settings"),
      onTap: (){
        Navigator.pushNamed(context,"/Settings");
      },
    ),
    ListTile(
      leading: Icon(Icons.logout),
      title: Text("Logout"),
      onTap: (){
        Navigator.pushNamedAndRemoveUntil(context, '/', ( route) => false);
      },
    ),
  ],
  ),
),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
      ),
      body: pages[currentindex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15.0),
        child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.deepPurple,
            padding: EdgeInsets.all(16),
            gap: 8,
            tabs:
           const [
              GButton(icon: Icons.calendar_month,
                text: "Schedule",
              ),
              GButton(icon: Icons.image,
              text: "memories",
              ),
              GButton(icon: Icons.location_on,
              text: "location",
              ),
              GButton(icon: Icons.person,
              text: "Profile",
              ),
            ],
            selectedIndex: currentindex,
            onTabChange: (index){
              setState(() {
                currentindex = index;
              });
            },
          ),
      ),
    );
  }
}
