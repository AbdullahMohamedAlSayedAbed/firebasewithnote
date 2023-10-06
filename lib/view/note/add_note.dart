import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasewithnote/constants.dart';
import 'package:firebasewithnote/view/note/view_sup_note.dart';
import 'package:firebasewithnote/widgets/primary_button.dart';
import 'package:firebasewithnote/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:io';
class AddNote extends StatefulWidget {
  const AddNote({super.key, required this.docId});
  final String docId;
  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController addNoteControl;

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
    addNoteControl = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    addNoteControl.dispose();
    super.dispose();
  }


  bool isLoading = false;
  Future<void> addNote(context) {
      CollectionReference note =
        FirebaseFirestore.instance.collection(category).doc(widget.docId).collection("note");
    isLoading = true;
    setState(() {});
    return note.add({
      "note": addNoteControl.text,
      "url":url
    }).then((value) {
      return Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return  SubcollectionNoteView(CategoryId: widget.docId);
        },
      ));
    }).catchError((error) {
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
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
                      hintText: "enter note",
                      controller: addNoteControl,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "the note is requred";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ImageButton(
                        onPressed: () async {
                          await takePhoto();
                        },
                        text: "Upload image",
                        isSelecting: url == null ? false : true),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                        onPressed: () async {
                          await addNote(context);
                        },
                        text: "Add Note")
                  ],
                ),
              )),
    );
  }
}
