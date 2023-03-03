import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:tome/firebase/ember.dart';
import 'package:tome/game_data/game.dart';
import 'package:tome/ui/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  late String email;
  late String password;

  List<Game> _listOfGames = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildLogingScreen());
  }

  Widget _buildLogingScreen() {
    return Center(
        child: Form(
            key: formKey,
            child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 30,
                spacing: 20,
                children: [
                  const Text("Tome"),
                  _buildEmailField(),
                  _buildPasswordField(),
                  ElevatedButton(
                      onPressed: () async {
                        formKey.currentState?.save();
                        FocusScope.of(context).unfocus();
                        try {
                          Ember.instance
                              .signInWithEmailAndPassword(email, password)
                              .then((value) {
                            Ember.instance.setUser(value);
                            print(value);
                            //Ember.instance.setUsersGames({"games": []});
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          });

                          // UserCredential userCredential = await FirebaseAuth
                          //     .instance
                          //     .signInWithEmailAndPassword(
                          //         email: email, password: password);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          }
                        }
                      },
                      child: Text("Login")),
                  ElevatedButton(
                      onPressed: () {
                        formKey.currentState?.save();
                        FocusScope.of(context).unfocus();
                        //print("???" + email + password);

                        // FirebaseFirestore.instance
                        //     .collection("user")
                        //     .doc(userId)
                        //     .set({"games": []});

                        //Ember.instance.signUpToTome(email, password);
                        Ember.instance
                            .createUserWithEmailAndPassword(email, password)
                            .then((value) {
                          Ember.instance.setUser(value);
                          print(value);
                          //Ember.instance.setUsersGames({"games": []});
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        });

                        /*Ember.instance.setUsersGames({"games": []});*/
                        try {
                          // UserCredential userCredential = await FirebaseAuth
                          //     .instance
                          //     .createUserWithEmailAndPassword(
                          //         email: email, password: password);
/*
                          Ember.instance
                              .signInWithEmailAndPassword(email, password);

                          String userId = Ember.instance.getUserId();
                          */

                          // FirebaseFirestore.instance
                          //     .collection("user")
                          //     .doc(userId)
                          //     .set({"games": []});

                          /*Ember.instance.setUsersGames({"games": []});*/

                          //Navigator.of(context).pop();
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                          }
                        } catch (e) {
                          print("error -- " + e.toString());
                        }
                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const HomePage()));
                      },
                      child: Text("Sign up"))
                ])));
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))),
      onSaved: (input) {
        setState(() {
          email = input!;
        });
      },
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "You need to enter an email bozo";
        }
        return null;
      }),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))),
      onSaved: (input) {
        setState(() {
          password = input!;
        });
      },
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "You need to enter an password bozo";
        }
        return null;
      }),
    );
  }
}
