import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tome/firebase/ember.dart';
import 'package:tome/game_data/game.dart';
import 'package:tome/ui/login_page.dart';
import 'package:tome/ui/map_selection_page.dart';
import 'package:tome/ui/widgets/image_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  late String gameToAdd;
  File? selectedGameImage;
  List<Game> _listOfGames = [];
  @override
  void initState() {
    gameToAdd = "";
    super.initState();
  }

  //final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games"),
      ),
      body: FutureBuilder(
        future: Ember.instance.initApp(), //_firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              print("<ERROR> :${snapshot.error}");
            }
            return Text("An error has occured: ${snapshot.error.toString()}");
          } else if (snapshot.hasData && !Ember.instance.hasUser()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            });
          } else if (snapshot.hasData && Ember.instance.hasUser()) {
            return _buildHomePage();
          }
          return _loadingScreen();
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_left),
            onPressed: () {
              Ember.instance.signOutUser();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            }),
        title: const Text("Games"),
      ),
      body: _buildHomePage(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  @override
  Widget _buildHomePage() {
    return FutureBuilder(
      // future: FirebaseFirestore.instance
      //     .collection(FirebaseAuth.instance.currentUser!.uid)
      //     .get(),
      future: Ember.instance.getGames(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (kDebugMode) {
            print("<ERROR> :${snapshot.error}");
          }
          return Text("An error has occured: ${snapshot.error.toString()}");
        } else if (snapshot.hasData && snapshot.data != null) {
          _listOfGames = snapshot.data!;

          // List<QueryDocumentSnapshot<Map<String, dynamic>>>? games =
          //     snapshot.data?.docs ?? [];

          // for (QueryDocumentSnapshot<Map<String, dynamic>> curGame in games) {
          //   List<GameMap> gameMaps = [];
          //   for (Map<String, dynamic> curMap in curGame.data()["maps"]) {
          //     String mapName = curMap.keys.first;
          //     String mapImage = curMap.values.first;
          //     gameMaps.add(GameMap(mapName, mapImage, []));
          //   }
          //   _listOfGames.add(Game(curGame.id, "nothing", gameMaps));
          // }
        } else if (!snapshot.hasData) {
          return _loadingScreen();
        }
        return buildListOfGames();
      },
    );
  }

  Widget buildListOfGames() {
    return _listOfGames.isEmpty
        ? const Text("No Games")
        : ListView.builder(
            itemCount: _listOfGames.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_listOfGames[index].gameName),
                onTap: () {
                  setState(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapSelectionPage(
                            gameName: _listOfGames[index].gameName,
                            gameMaps: _listOfGames[index].gameMaps)));
                  });
                  _listOfGames[index].printMaps();
                },
              );
            },
          );
  }

  Widget _loadingScreen() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => _buildAddGamePopUp()));
  }

  Widget _buildAddGamePopUp() {
    return AlertDialog(
      title: const Text(
        "Add A Game",
      ),
      content: Form(
          key: formKey,
          child: Wrap(runSpacing: 15.0, // gap between lines
              children: [
                _buildGameField(),
                ImageSelectorButton(onSelected: (selectedFile) {
                  setState(() {
                    print("Selected files path =${selectedFile?.path}");
                    selectedGameImage = selectedFile;
                  });
                }),
              ])),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () async {
              String imagePath = "";
              final bool isValidState =
                  formKey.currentState?.validate() ?? false;
              if (isValidState) {
                formKey.currentState?.save();
                // imagePath = await uploadFileToFireBase(selectedGameImage,
                //     "${FirebaseAuth.instance.currentUser!.uid}/Games/$gameToAdd");

                imagePath = await Ember.instance.uploadImageToFirestorage(
                    selectedGameImage,
                    "${Ember.instance.getUserId()}/Games/$gameToAdd");

                Ember.instance
                    .setUsersGames(gameToAdd, {"maps": [], "image": imagePath});
                // FirebaseFirestore.instance
                //     .collection(FirebaseAuth.instance.currentUser!.uid)
                //     .doc(gameToAdd)
                //     .set({"maps": [], "image": imagePath});
                print(gameToAdd);
              }

              Navigator.of(context).pop();
            },
            child: const Text("Add")),
      ],
    );
  }

  Widget _buildGameField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Game Name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35))),
      onSaved: (input) {
        setState(() {
          gameToAdd = input!;
        });
      },
      validator: ((value) {
        if (value == null || value.isEmpty) {
          return "You need to enter a game name";
        }
        return null;
      }),
    );
  }
}
