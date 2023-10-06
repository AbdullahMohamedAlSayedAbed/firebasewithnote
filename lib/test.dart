import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  File? file;
  String? url;
  takePhoto() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    // final XFile? imageGallery =
    //     await picker.pickImage(source: ImageSource.gallery);
// // Capture a photo.
    final XFile? photoCamera =
        await picker.pickImage(source: ImageSource.camera);
    if (photoCamera != null) {
      file = File(photoCamera.path);
      String imageName = basename(photoCamera.path);
      final storage = FirebaseStorage.instance.ref(imageName);
      await storage.putFile(file!);
       url =await storage.getDownloadURL();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ElevatedButton(
            onPressed: () async {
              await takePhoto();
            },
            child: const Text("image")),
        if (url != null) Image.network(url!)
      ]),
    );
  }
}
