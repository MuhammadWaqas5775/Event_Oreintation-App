import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final User? user = FirebaseAuth.instance.currentUser;
  late final DocumentReference<Map<String, dynamic>> userDoc;
  late final CloudinaryPublic cloudinary;
  File? _image;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);
    if (user != null) {
      userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (user == null) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
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
      await userDoc.set({'profileImageUrl': imageUrl}, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

  Future<void> _showUpdateProfileDialog(BuildContext context, String currentName) async {
    _nameController.text = currentName;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _updateProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (user == null || _nameController.text.trim().isEmpty) return;

    try {
      await userDoc.update({'name': _nameController.text.trim()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text("Please log in to see your profile."),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(title: const Text("Profile")),
              body: const Center(child: Text('Something went wrong')));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(title: const Text("Profile")),
              body: const Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
              appBar: AppBar(title: const Text("Profile")),
              body: const Center(child: Text("User data not found.")));
        }

        final data = snapshot.data!.data()!;
        final name = data['name'] ?? 'No name';
        final email = data['email'] ?? 'No email';
        final imageUrl = data['profileImageUrl'];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showUpdateProfileDialog(context, name);
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: imageUrl != null
                        ? ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes !=
                                  null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 50),
                      ),
                    )
                        : const Icon(Icons.person, size: 50),
                  ),
                ),
                const SizedBox(height: 20),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(email, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
