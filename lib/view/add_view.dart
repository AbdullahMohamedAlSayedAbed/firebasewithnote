import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasewithnote/constants.dart';
import 'package:firebasewithnote/view/note_view.dart';
import 'package:firebasewithnote/widgets/primary_button.dart';
import 'package:firebasewithnote/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:io';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController addControl;
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
      url = await storage.getDownloadURL();
    }
    setState(() {});
  }

  @override
  void initState() {
    addControl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    addControl.dispose();
    super.dispose();
  }

  CollectionReference categories =
      FirebaseFirestore.instance.collection(category);
  bool isLoading = false;
  Future<void> addUser(context) {
    isLoading = true;
    setState(() {});
    return categories.add({
      "id": FirebaseAuth.instance.currentUser!.uid,
      "title": addControl.text,
      "url":url}).then((value) {
      return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return const NoteView();
        },
      ), (route) => false);
    }).catchError((error) {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add category'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : Form(
              key: formState,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Column(
                  children: [
                    CustomTextFormField(
                      hintText: "enter name",
                      controller: addControl,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "the name is requred";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ImageButton(
                        onPressed: ()async {
                          await takePhoto();
                        },
                        text: "Upload image",
                        isSelecting: url == null ? false : true),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                        onPressed: () async {
                          await addUser(context);
                        },
                        text: "Add")
                  ],
                ),
              )),
    );
  }
}
