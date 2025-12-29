import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryPublic _cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);

  // --- Event Management ---

  Stream<List<Map<String, dynamic>>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> addEvent({
    required String title,
    required String category,
    required String date,
    required String day,
    required String price,
    required String description,
    required XFile? imageFile,
    required List<Map<String, dynamic>> subEvents,
  }) async {
    String? imageUrl;
    
    if (imageFile != null) {
      print("Starting image upload to Cloudinary...");
      try {
        final CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
        print("Image uploaded successfully! URL: $imageUrl");
      } catch (e) {
        print("Cloudinary Upload Error: $e");
        throw Exception("Cloudinary Upload Failed: $e");
      }
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      print("Warning: Image URL is null or empty after upload. Using placeholder.");
      imageUrl = ""; // You can put a default image URL here if you want
    }

    print("Saving event to Firestore...");
    await _firestore.collection('events').add({
      'title': title,
      'category': category,
      'date': date,
      'day': day,
      'price': price,
      'detail': [{
        'description': description,
        'imgurl': imageUrl,
      }],
      'subevents': subEvents,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print("Event saved to Firestore successfully!");
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String category,
    required String date,
    required String day,
    required String price,
    required String description,
    XFile? newImageFile,
    String? existingImageUrl,
    required List<Map<String, dynamic>> subEvents,
  }) async {
    String? imageUrl = existingImageUrl;
    
    if (newImageFile != null) {
      print("Uploading new image to Cloudinary...");
      try {
        final CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(newImageFile.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
        print("New image uploaded: $imageUrl");
      } catch (e) {
        print("Cloudinary Update Error: $e");
        throw Exception("Cloudinary Update Failed: $e");
      }
    }

    await _firestore.collection('events').doc(eventId).update({
      'title': title,
      'category': category,
      'date': date,
      'day': day,
      'price': price,
      'detail': [{
        'description': description,
        'imgurl': imageUrl ?? '',
      }],
      'subevents': subEvents,
    });
    print("Event updated in Firestore.");
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  // --- User Management ---

  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
