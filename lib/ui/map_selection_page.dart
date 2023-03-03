import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:tome/firebase/ember.dart';
import 'package:tome/firebase/firbase_utils.dart';
import 'package:tome/game_data/game_map.dart';
import 'package:tome/game_data/modifier.dart';
import 'package:tome/ui/lineup_selection_page.dart';
import 'package:tome/ui/widgets/image_selector.dart';

class MapSelectionPage extends StatefulWidget {
  final String gameName;
  final List<GameMap> gameMaps;
  const MapSelectionPage(
      {super.key, required this.gameName, required this.gameMaps});

  @override
  State<StatefulWidget> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  final formKey = GlobalKey<FormState>();
  late String mapToAdd;
  late List<Modifier> _modifiers;
  late List<GameMap> _gameMaps;
  File? selectedGameImage;
  @override
  void initState() {
    _modifiers = [];
    _gameMaps = [];
    mapToAdd = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select A Map"),
        ),
        body: _buildHomePage(), //buildListOfGames(),
        floatingActionButton: _buildFloatingActionButton());
  }

  Widget _buildHomePage() {
    return FutureBuilder(
      // future: FirebaseFirestore.instance
      //     .collection(FirebaseAuth.instance.currentUser!.uid)
      //     .doc(widget.gameName)
      //     .collection("modifiers")
      //     .get(),
      future: Ember.instance.getModifiers(widget.gameName),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (kDebugMode) {
            print("<ERROR> :${snapshot.error}");
          }
          return Text("An error has occured: ${snapshot.error.toString()}");
        } else if (snapshot.hasData && snapshot.data != null) {
          _modifiers = Ember.instance.buildModifiers(snapshot.data);

          // List<QueryDocumentSnapshot<Map<String, dynamic>>>? modifiers =
          //     snapshot.data?.docs ?? [];

          // for (QueryDocumentSnapshot<Map<String, dynamic>> modifier
          //     in modifiers) {
          //   //
          //   _modifiers.add(Modifier(modifier.id, modifier.data()["image"]));
          // }
        } else if (!snapshot.hasData) {
          return _loadingScreen();
        }
        return _buildMapsPage();
      },
    );
  }

  Widget _buildMapsPage() {
    return StreamBuilder(
      // stream: FirebaseFirestore.instance
      //     .collection(FirebaseAuth.instance.currentUser!.uid)
      //     .doc(widget.gameName)
      //     .snapshots(),

      stream: Ember.instance.getMaps(widget.gameName),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (kDebugMode) {
            print("<ERROR> :${snapshot.error}");
          }
          return Text("An error has occured: ${snapshot.error.toString()}");
        } else if (snapshot.hasData && snapshot.data != null) {
          _gameMaps = Ember.instance.buildGameMaps(snapshot.data);
          // _gameMaps = [];
          // for (Map<String, dynamic> curMap in snapshot.data!.data()!["maps"]) {
          //   String mapName = curMap.keys.first;
          //   String mapImage = curMap.values.first;
          //   _gameMaps.add(GameMap(mapName, mapImage, []));
          // }
          return buildListOfGames(_gameMaps);
        } else if (!snapshot.hasData) {
          return _loadingScreen();
        }

        return buildListOfGames([]);
      },
    );
  }

  Widget buildListOfGames(List<GameMap> gameMap) {
    return _gameMaps.isEmpty
        ? const Text("No Maps")
        : ListView.builder(
            itemCount: _gameMaps.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_gameMaps[index].mapName),
                onTap: () {
                  //widget._gameMaps[index].printLineups();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LineupSelectionPage(
                          modifiers: _modifiers,
                          gameName: widget.gameName,
                          mapName: _gameMaps[index].mapName)));
                },
              );
            },
          );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => _buildAddMapPopUp()));
  }

  Widget _buildAddMapPopUp() {
    return AlertDialog(
      title: const Text(
        "Add A Map",
      ),
      content: Form(
          key: formKey,
          child: Wrap(children: [
            _buildMapField(),
            SizedBox(
                width: double.infinity,
                child: ImageSelectorButton(
                  onSelected: (imageFile) {
                    setState(() {
                      selectedGameImage = imageFile;
                    });
                  },
                ))
            // child: ElevatedButton(
            //     onPressed: () async {
            //       XFile? image = await ImagePicker()
            //           .pickImage(source: ImageSource.camera);
            //       setState(() {
            //         if (image != null) {
            //           selectedGameImage = File(image.path);
            //         }
            //       });
            //     },
            //     child: const Text("Select an image"))),
          ])),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () async {
              final bool isValidState =
                  formKey.currentState?.validate() ?? false;
              if (isValidState) {
                String imagePath = "";
                formKey.currentState?.save();
                imagePath = await Ember.instance.uploadImageToFirestorage(
                    selectedGameImage,
                    "${Ember.instance.getUserId()}/Games/${widget.gameName}/$mapToAdd");

                Ember.instance.updateGameWithMap(widget.gameName,
                    getGameMapsAsListMap(), mapToAdd, imagePath);
                // FirebaseFirestore.instance
                //     .collection(FirebaseAuth.instance.currentUser!.uid)
                //     .doc(widget.gameName)
                //     .update(
                //   {
                //     "maps": FieldValue.arrayUnion(getGameMapsAsListMap() +
                //         [
                //           {mapToAdd: imagePath}
                //         ])
                //   },
                // );
              } else {
                if (kDebugMode) {
                  print("invalid value");
                }
              }
              Navigator.of(context).pop();
            },
            child: const Text("Add")),
      ],
    );
  }

  Widget _loadingScreen() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMapField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Map Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))),
      onSaved: (input) {
        setState(() {
          mapToAdd = input!;
          // print("saving" + mapToAdd);
        });
      },
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "You need to enter a map name";
        }
        return null;
      }),
    );
  }

  List<Map<String, String>> getGameMapsAsListMap() {
    List<Map<String, String>> gameMaps = [];

    for (GameMap curMap in _gameMaps) {
      gameMaps.add({curMap.mapName: curMap.mapImage});
    }

    return gameMaps;
  }
}
