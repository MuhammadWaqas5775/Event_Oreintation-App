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
      await userDoc.set({'profileImageUrl': imageUrl}, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _showUpdateProfileDialog(BuildContext context, String currentName) async {
    _nameController.text = currentName;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Update Profile'),
          content: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  // Implementation of Reset Password
  Future<void> _handlePasswordReset() async {
    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email found for this user.")),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reset email sent to ${user!.email}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Security Settings", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Colors.white70),
              title: const Text("Reset Password", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Receive reset link via email", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _handlePasswordReset();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text("Delete Account", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Account?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This action is permanent and cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await user?.delete();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please re-login to delete your account.")),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Colors.white70),
              title: const Text("Contact Support", style: TextStyle(color: Colors.white)),
              subtitle: const Text("support@ueoapp.com", style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Inquiry sent to support team.")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text("App Version", style: TextStyle(color: Colors.white)),
              subtitle: const Text("1.0.0", style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see your profile.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found.", style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!.data()!;
          final name = data['name'] ?? 'No name';
          final email = data['email'] ?? 'No email';
          final imageUrl = data['profileImageUrl'];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.deepPurple.shade200,
                          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                          child: imageUrl == null
                              ? const Icon(Icons.person, size: 70, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        _buildProfileOption(Icons.edit, "Edit Profile", () => _showUpdateProfileDialog(context, name)),
                        const Divider(color: Colors.white12, height: 1),
                        _buildProfileOption(Icons.notifications_none, "Notifications", () {}),
                        const Divider(color: Colors.white12, height: 1),
                        _buildProfileOption(Icons.security, "Security", _showSecurityDialog),
                        const Divider(color: Colors.white12, height: 1),
                        _buildProfileOption(Icons.help_outline, "Help & Support", _showHelpSupportDialog),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      child: const Text("Logout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Extra space for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 18),
      onTap: onTap,
    );
  }
}
