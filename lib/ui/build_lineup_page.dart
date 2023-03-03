import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tome/firebase/ember.dart';
import 'package:tome/firebase/firbase_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:tome/game_data/modifier.dart';
import 'package:tome/ui/widgets/image_selector.dart';

class BuildLineupPage extends StatefulWidget {
  final String gameName;
  final String mapName;
  final List<Modifier> modifiers;
  const BuildLineupPage(
      {super.key,
      required this.gameName,
      required this.mapName,
      required this.modifiers});

  @override
  State<StatefulWidget> createState() => _BuildLineupPageState();
}

class _BuildLineupPageState extends State<BuildLineupPage> {
  late String lineupName;
  File? standGameImage;
  File? aimGameImage;
  File? resultGameImage;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select A Lineup"),
        ),
        body: _buildHomePage());
  }

  Widget _buildHomePage() {
    return Form(
        key: formKey,
        child: Center(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  children: [
                    _buildLineupNameField(),
                    SizedBox(
                        width: double.infinity,
                        child: ImageSelectorButton(onSelected: (fileImage) {
                          setState(() {
                            standGameImage = fileImage;
                          });
                        })),
                    // child: ElevatedButton(
                    //     onPressed: () async {
                    //       XFile? image = await ImagePicker()
                    //           .pickImage(source: ImageSource.camera);
                    //       setState(() {
                    //         if (image != null) {
                    //           standGameImage = File(image.path);
                    //         }
                    //       });
                    //     },
                    //     child: const Text("Add stand location"))),
                    SizedBox(
                        width: double.infinity,
                        child: ImageSelectorButton(onSelected: (fileImage) {
                          setState(() {
                            aimGameImage = fileImage;
                          });
                        })),
                    // child: ElevatedButton(
                    //     onPressed: () async {
                    //       XFile? image = await ImagePicker()
                    //           .pickImage(source: ImageSource.camera);

                    //       setState(() {
                    //         if (image != null) {
                    //           aimGameImage = File(image.path);
                    //         }
                    //       });
                    //     },
                    //     child: const Text("Add throw location"))),
                    SizedBox(
                        width: double.infinity,
                        child: ImageSelectorButton(onSelected: (fileImage) {
                          setState(() {
                            resultGameImage = fileImage;
                          });
                        })),
                    // child: ElevatedButton(
                    //     onPressed: () async {
                    //       XFile? image = await ImagePicker()
                    //           .pickImage(source: ImageSource.camera);

                    //       setState(() {
                    //         if (image != null) {
                    //           resultGameImage = File(image.path);
                    //         }
                    //       });
                    //     },
                    //     child: const Text("Add result"))),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildCreateModifierPopUp()),
                            child: const Text("Add Modifier"))),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () async {
                              final bool isValidState =
                                  formKey.currentState?.validate() ?? false;
                              if (isValidState) {
                                formKey.currentState?.save();
                                print(
                                    isValidState.toString() + "" + lineupName);
                                String standImagePath = await Ember.instance
                                    .uploadImageToFirestorage(standGameImage,
                                        "${Ember.instance.getUserId()}/Games/${widget.gameName}/${widget.mapName}/$lineupName/stand/");
                                String aimImagePath = await Ember.instance
                                    .uploadImageToFirestorage(aimGameImage,
                                        "${Ember.instance.getUserId()}/Games/${widget.gameName}/${widget.mapName}/$lineupName/aim/");
                                String resultImagePath = await Ember.instance
                                    .uploadImageToFirestorage(resultGameImage,
                                        "${Ember.instance.getUserId()}/Games/${widget.gameName}/${widget.mapName}/$lineupName/result/");

                                Ember.instance.addLineupToFirebase(
                                    widget.gameName,
                                    widget.mapName,
                                    lineupName,
                                    standImagePath,
                                    aimImagePath,
                                    resultImagePath);
                                // FirebaseFirestore.instance
                                //     .collection(FirebaseAuth.instance.currentUser!.uid)
                                //     .doc(widget.gameName)
                                //     .collection(widget.mapName)
                                //     .doc(lineupName)
                                //     .set(
                                //   {
                                //     "modifiers": [],
                                //     "stand": standImagePath,
                                //     "aim": aimImagePath,
                                //     "result": resultImagePath,
                                //   },
                                // );
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text("Add Line up")))
                  ],
                ))));
  }

  Widget _buildCreateModifierPopUp() {
    return AlertDialog(
      title: const Text(
        "Add A Map",
      ),
      content: Wrap(children: [
        TextFormField(),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {}, child: const Text("Select an image"))),
      ]),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Add")),
      ],
    );
  }

  Widget _buildLineupNameField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Lineup name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))),
      onSaved: (input) {
        setState(() {
          print(input);
          lineupName = input!;
          // print("saving" + mapToAdd);
        });
      },
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "You need to enter a lineup name";
        }
        return null;
      }),
    );
  }
}
