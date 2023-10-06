import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasewithnote/constants.dart';
import 'package:firebasewithnote/view/note_view.dart';
import 'package:firebasewithnote/widgets/primary_button.dart';
import 'package:firebasewithnote/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class EditView extends StatefulWidget {
  const EditView({super.key, this.docId, required this.oldTitle});
  final String? docId;
  final String oldTitle;
  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  late TextEditingController editControl = TextEditingController();
  @override
  void initState() {
    editControl.text = widget.oldTitle;
    super.initState();
  }

  @override
  void dispose() {
    editControl.dispose();
    super.dispose();
  }

  CollectionReference categories =
      FirebaseFirestore.instance.collection(category);
  bool isLoading = false;
  Future<void> editUser() async {
    isLoading = true;
    setState(() {});
    await categories
        .doc(widget.docId)
        .update({"title": editControl.text}).then((value) {
      return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return const NoteView();
        },
      ), (route) => false);
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit category'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoteView(),
                  ));
            },
            icon: const Icon(Icons.arrow_back,size: 40,)),
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
                      controller: editControl,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "the name is requred";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                        onPressed: () async {
                          await editUser();
                        },
                        text: "Edit")
                  ],
                ),
              )),
    );
  }
}
