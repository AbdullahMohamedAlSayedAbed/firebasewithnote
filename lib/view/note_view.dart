import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasewithnote/auth/home_page.dart';
import 'package:firebasewithnote/constants.dart';
import 'package:firebasewithnote/view/add_view.dart';
import 'package:firebasewithnote/view/edit_view.dart';
import 'package:firebasewithnote/view/note/view_sup_note.dart';
import 'package:flutter/material.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(category)
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : GridView.builder(
              itemCount: data.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 15),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SubcollectionNoteView(CategoryId: data[index].id),
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
                            .doc(data[index].id)
                            .delete();
                        if (data[index]['url'] != null) {
                          FirebaseStorage.instance
                              .refFromURL(data[index]['url'])
                              .delete();
                        }
                        data.removeAt(index);
                        setState(() {});
                      },
                    ).show();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              if (data[index]['url'] != null)
                                Image.network(
                                  data[index]['url'],
                                  height: 130,
                                ),
                              const SizedBox(height: 10),
                              Text("${data[index]['title']}"),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -10,
                        child: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) {
                                      return EditView(
                                          oldTitle: data[index]['title'],
                                          docId: data[index].id);
                                    },
                                  ));
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ))),
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const AddView();
              },
            ));
          },
          child: const Icon(Icons.add)),
    );
  }
}
