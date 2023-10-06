import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasewithnote/view/note_view.dart';
import 'package:firebasewithnote/auth/register.dart';
import 'package:firebasewithnote/widgets/custom_logo_image.dart';
import 'package:firebasewithnote/widgets/primary_button.dart';
import 'package:firebasewithnote/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController email;
  late final TextEditingController password;

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                children: [
                  const SizedBox(height: 80),
                  const ImageLogo(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      const Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Login to continue using the app",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      const Text("Emil",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                      Form(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            controller: email,
                          ),
                          const SizedBox(height: 20),
                          const Text("password",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24)),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                              hintText: 'Enter your password',
                              controller: password,
                              obscureText: true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: const Text("forget password click ",
                                    style: TextStyle(fontSize: 20)),
                              ),
                              InkWell(
                                onTap: () {},
                                child: const Text("Here",
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.blue)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                              onPressed: () async {
                                try {
                                  isLoading = true;
                                  setState(() {});
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: email.text,
                                          password: password.text);
                                  isLoading = false;
                                  setState(() {});
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) => const NoteView(),
                                  ));
                                } on FirebaseAuthException catch (e) {
                                  isLoading = false;
                                  setState(() {});
                                  if (e.code == 'user-not-found') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'error',
                                      desc: 'No user found for that email.',
                                    ).show();
                                  } else if (e.code == 'wrong-password') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'error',
                                      desc:
                                          'Wrong password provided for that user.',
                                    ).show();
                                  }
                                }
                              },
                              text: "LOGIN"),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: const Text("Don't have an account ? ",
                                    style: TextStyle(fontSize: 20)),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return const Register();
                                    },
                                  ));
                                },
                                child: const Text("REGISTER",
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.blue)),
                              ),
                            ],
                          ),
                        ],
                      ))
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
