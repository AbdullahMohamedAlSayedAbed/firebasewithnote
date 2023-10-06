import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasewithnote/constants.dart';
import 'package:firebasewithnote/view/note/view_sup_note.dart';
import 'package:firebasewithnote/widgets/primary_button.dart';
import 'package:firebasewithnote/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class EditNote extends StatefulWidget {
  const EditNote(
      {super.key,
      required this.noteDocId,
      required this.categoryId,
      required this.value});
  final String noteDocId;
  final String value;
  final String categoryId;
  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController editNoteControl = TextEditingController();
  @override
  void initState() {
    editNoteControl.text = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    editNoteControl.dispose();
    super.dispose();
  }

  bool isLoading = false;
  Future<void> editNote() {
    CollectionReference edit = FirebaseFirestore.instance
        .collection(category)
        .doc(widget.categoryId)
        .collection("note");
    isLoading = true;
    setState(() {});
    return edit.doc(widget.noteDocId).update({"note": editNoteControl.text}).then((value) {
      return Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return SubcollectionNoteView(CategoryId: widget.categoryId);
        },
      ));
    }).catchError((error) {
      isLoading = false;
      print("erorr === $error");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('edit Note'),
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
                      controller: editNoteControl,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "the note is requred";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                        onPressed: () async {
                          await editNote();
                        },
                        text: "edit Note")
                  ],
                ),
              )),
    );
  }
}
