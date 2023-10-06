import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasewithnote/view/note_view.dart';
import 'package:firebasewithnote/widgets/primary_button.dart';
import 'package:firebasewithnote/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController userName;
  late final TextEditingController phoneNumber;
  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    userName = TextEditingController();
    phoneNumber = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    userName.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  bool isLoading = false;
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 80),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Register",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 10),
              const Text(
                "Register to continue using the app",
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Form(
                  key: formState,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("username",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24)),
                            const SizedBox(height: 10),
                            CustomTextFormField(
                                hintText: 'Enter your username',
                                validator: (value) {
                                  if (value!.length < 6) {
                                    return "cen't to be less then six";
                                  }
                                  return null;
                                },
                                controller: userName),
                            const SizedBox(height: 20),
                            const Text("Phone number",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24)),
                            const SizedBox(height: 10),
                            CustomTextFormField(
                              hintText: 'Enter your Phone',
                              keyboardType: TextInputType.number,
                              controller: phoneNumber,
                              validator: (value) {
                                if (value!.length < 6) {
                                  return "cen't to be less then six";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text("Emil",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24)),
                            const SizedBox(height: 10),
                            CustomTextFormField(
                              hintText: 'Enter your email',
                              validator: (value) {
                                if (value!.length < 10) {
                                  return "cen't to be less then ten";
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value!.length < 6) {
                                  return "cen't to be less then six";
                                }
                                return null;
                              },
                              controller: password,
                              obscureText: true,
                            ),
                            const SizedBox(height: 30),
                            CustomButton(
                                onPressed: () async {
                                  if (formState.currentState!.validate()) {
                                    try {
                                      isLoading = true;
                                      setState(() { });
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text,
                                      );
                                      isLoading = false;
                                      setState(() {});
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                        builder: (context) => const NoteView(),
                                      ));
                                    } on FirebaseAuthException catch (e) {
                                      isLoading = false;
                                      setState(() {});
                                      if (e.code == 'weak-password') {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.rightSlide,
                                          title: 'error',
                                          desc:
                                              'The password provided is too weak.',
                                        ).show();
                                      } else if (e.code ==
                                          'email-already-in-use') {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.rightSlide,
                                          title: 'error',
                                          desc:
                                              'The account already exists for that email.',
                                        ).show();
                                      }
                                    } catch (e) {
                                      isLoading = false;
                                      setState(() {});
                                      print(e);
                                    }
                                  }
                                },
                                text: "REGISTER"),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text("Do have an account ? ",
                                      style: TextStyle(fontSize: 20)),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Login",
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
    ));
  }
}
