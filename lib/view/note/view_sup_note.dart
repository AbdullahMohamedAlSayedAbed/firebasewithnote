import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasewithnote/auth/home_page.dart';
import 'package:firebasewithnote/constants.dart';
import 'package:firebasewithnote/view/note/add_note.dart';
import 'package:firebasewithnote/view/note/edit_note.dart';
import 'package:firebasewithnote/view/note_view.dart';
import 'package:flutter/material.dart';

class SubcollectionNoteView extends StatefulWidget {
  const SubcollectionNoteView({super.key, required this.CategoryId});

  final String CategoryId;
  @override
  State<SubcollectionNoteView> createState() => _SubcollectionNoteViewState();
}

class _SubcollectionNoteViewState extends State<SubcollectionNoteView> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(category)
        .doc(widget.CategoryId)
        .collection("note")
        .get();
    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: 'exit',
                  desc: 'The account already exit to app.',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                      builder: (context) {
                        return const HomePage();
                      },
                    ), (route) => false);
                  },
                ).show();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
        title: const Text('Note'),
      ),
      body: WillPopScope(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) {
                            return EditNote(
                                noteDocId: data[index].id,
                                categoryId: widget.CategoryId,
                                value: data[index]['note']);
                          },
                        ));
                      },
                      onLongPress: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.bottomSlide,
                          title: 'delete',
                          desc: 'Are you already from delete process.',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            await FirebaseFirestore.instance
                                .collection(category)
                                .doc(widget.CategoryId)
                                .collection("note")
                                .doc(data[index].id)
                                .delete();
                            data.removeAt(index);
                            setState(() {});
                            if (data[index]['url'] != null) {
                              FirebaseStorage.instance
                                  .refFromURL(data[index]['url'])
                                  .delete();
                            }
                          },
                        ).show();
                      },
                      child: Stack(
                        alignment: Alignment.centerRight,
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data[index]['url'] != null)
                                    Expanded(
                                      flex: 2,
                                      child: Image.network(
                                        data[index]['url'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text("${data[index]['note']}")),
                                ],
                              ),
                              const Divider(
                                height: 20,
                                color: Colors.orange,
                                thickness: 1,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        onWillPop: () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) {
              return const NoteView();
            },
          ), (route) => false);
          return Future.value(false);
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AddNote(docId: widget.CategoryId);
              },
            ));
          },
          child: const Icon(Icons.add)),
    );
  }
}
