import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Memories extends StatefulWidget {
  const Memories({super.key});
  @override
  State<Memories> createState() => _MemoriesState();
}

class _MemoriesState extends State<Memories> {
  final ImagePicker picker = ImagePicker();
  final List<XFile> image = [];

  Future<void> getImage() async {
    final List<XFile> pickedImage = await picker.pickMultipleMedia();
    if (pickedImage.isNotEmpty) {
      setState(() {
        image.addAll(pickedImage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memories"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: image.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.file(
              File(image[index].path),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        child: Icon(Icons.add),
      ),
    );
  }
}