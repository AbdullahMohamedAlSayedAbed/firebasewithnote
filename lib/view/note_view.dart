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
  const NoteView({Key? key}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  void deleteData(QueryDocumentSnapshot<Map<String, dynamic>> document) async {
    await FirebaseFirestore.instance
        .collection(category)
        .doc(document.id)
        .delete();
    if (document['url'] != null) {
      await FirebaseStorage.instance.refFromURL(document['url']).delete();
    }
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
                title: 'Exit',
                desc: 'Are you sure you want to sign out?',
                btnCancelOnPress: () {},
                btnOkOnPress: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) {
                        return const HomePage();
                      },
                    ),
                    (route) => false,
                  );
                },
              ).show();
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
        title: const Text('Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection(category)
                .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading data'),
                );
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              } else {
                final data = snapshot.data!.docs;
                return GridView.builder(
                    itemCount: data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      final document = data[index];
                      return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SubcollectionNoteView(
                                  CategoryId: document.id,
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.bottomSlide,
                              title: 'Delete',
                              desc: 'Are you sure you want to delete this item?',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                deleteData(document);
                                setState(() {
                                  data.removeAt(index);
                                });
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
                                      if (document['url'] != null)
                                        Expanded(
                                          child: Image.network(
                                            document['url'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${document['title']}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: -10,
                                child: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EditView(
                                              oldTitle: document['title'],
                                              docId: document.id,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ));
                    });
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const AddView();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
