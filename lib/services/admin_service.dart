import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryPublic _cloudinary = CloudinaryPublic('dcfpfknn1', 'ueoapp', cache: false);


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
    required String time,
    required String day,
    required String price,
    required String description,
    required XFile? imageFile,
    required List<Map<String, dynamic>> subEvents,
  }) async {
    String? imageUrl;
    
    if (imageFile != null) {
      try {
        final CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
      } catch (e) {
        throw Exception("Cloudinary Upload Failed: $e");
      }
    }

    await _firestore.collection('events').add({
      'title': title,
      'category': category,
      'date': date,
      'time': time,
      'day': day,
      'price': price,
      'detail': [{
        'description': description,
        'imgurl': imageUrl ?? "",
      }],
      'subevents': subEvents,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String category,
    required String date,
    required String time,
    required String day,
    required String price,
    required String description,
    XFile? newImageFile,
    String? existingImageUrl,
    required List<Map<String, dynamic>> subEvents,
  }) async {
    String? imageUrl = existingImageUrl;
    
    if (newImageFile != null) {
      try {
        final CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(newImageFile.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
      } catch (e) {
        throw Exception("Cloudinary Update Failed: $e");
      }
    }

    await _firestore.collection('events').doc(eventId).update({
      'title': title,
      'category': category,
      'date': date,
      'time': time,
      'day': day,
      'price': price,
      'detail': [{
        'description': description,
        'imgurl': imageUrl ?? '',
      }],
      'subevents': subEvents,
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }


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

  // --- NEW: MEMORIES METHODS ---
  Stream<List<Map<String, dynamic>>> getMemories() {
    return _firestore.collection('memories').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> deleteMemory(String id) async {
    await _firestore.collection('memories').doc(id).delete();
  }
}
