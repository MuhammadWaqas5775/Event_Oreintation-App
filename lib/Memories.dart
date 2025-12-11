import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ueo_app/full_screen_image.dart';

class Memories extends StatefulWidget {
  const Memories({super.key});
  @override
  State<Memories> createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  final ImagePicker picker = ImagePicker();
  bool _isUploading = false;
  late final CloudinaryPublic cloudinary;
  final User? user = FirebaseAuth.instance.currentUser;
  CollectionReference<Map<String, dynamic>>? _memoriesCollection;

  @override
  void initState() {
    super.initState();
    cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);
    if (user != null) {
      _memoriesCollection = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('memories');
    }
  }

  Future<void> _uploadImages() async {
    if (_isUploading || user == null || _memoriesCollection == null) return;

    final List<XFile> pickedFiles = await picker.pickMultipleMedia();
    if (pickedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      for (var pickedFile in pickedFiles) {
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path, resourceType: CloudinaryResourceType.Image),
        );
        await _memoriesCollection!.add({
          'imageUrl': response.secureUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload images: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null || _memoriesCollection == null) {
      return const Center(child: Text("Please log in to see your memories."));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memories"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _memoriesCollection!.orderBy('timestamp', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final imageUrl = data['imageUrl'];
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(imageUrl: imageUrl),
                          ),
                        );
                      },
                      onLongPress: () async {
                        final bool? shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Image'),
                              content: const Text('Are you sure you want to delete this image?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          await _memoriesCollection!.doc(docs[index].id).delete();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image deleted.'),
                              ),
                            );
                          }
                        }
                      },
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImages,
        child: const Icon(Icons.add),
      ),
    );
  }
}
