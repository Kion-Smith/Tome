import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tome/firebase/firebase_interface.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:tome/game_data/game.dart';
import 'package:tome/game_data/game_map.dart';

import 'package:path/path.dart';
import 'package:tome/game_data/lineup.dart';
import 'package:tome/game_data/modifier.dart';

class FirebaseOfficial extends FirebaseInterface {
  late UserCredential _userCredential;
  var storageRef;
  //     FirebaseStorage.instanceFor(bucket: "gs://tome-8879a.appspot.com");
  @override
  Future<FirebaseApp> initApp() async {
    return await Firebase.initializeApp().then((value) {
      //print(value);
      storageRef =
          FirebaseStorage.instanceFor(bucket: "gs://tome-8879a.appspot.com");
      return value;
    });
  }

  Future<FirebaseApp> initFirebase() async {
    return await Firebase.initializeApp();
  }

  @override
  bool hasUser() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  String getUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Future<void> setUsersGames(String gameToAdd, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(gameToAdd)
        .set(data);
    //FirebaseFirestore.instance.collection("user").doc(getUserId()).set(data);
  }

  @override
  void signUpToTome(String email, String password) async {
    signInWithEmailAndPassword(email, password);
    //print(_userCredential);
  }

  @override
  createUserWithEmailAndPassword(String email, String password) {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<List<Game>> getGames() async {
    QuerySnapshot<Map<String, dynamic>> userCollection = await FirebaseFirestore
        .instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<Game> games = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> curGame
        in userCollection.docs) {
      List<GameMap> gameMaps = [];
      for (Map<String, dynamic> curMap in curGame.data()["maps"]) {
        String mapName = curMap.keys.first;
        String mapImage = curMap.values.first;
        gameMaps.add(GameMap(mapName, mapImage, []));
      }
      games.add(Game(curGame.id, curGame.data()["image"], gameMaps));
    }

    return games;
  }

  @override
  void setUser(dynamic user) {
    _userCredential = user;
  }

  @override
  Future<String> uploadImageToFirestorage(
      File? selectedGameImage, String filePath) async {
    String result = "";
    if (selectedGameImage == null) {
      return result;
    }

    try {
      final fileName = basename(selectedGameImage.path);
      String imagePath = '$filePath$fileName';
      final ref = storageRef.ref(imagePath);
      var res = await ref.putFile(selectedGameImage);
      if (res.state == TaskState.success) {
        result = imagePath;
      }
    } catch (e) {
      print(e);
    }

    return result;
  }

  @override
  Future getModifiers(String gameName) {
    return FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(gameName)
        .collection("modifiers")
        .get();
  }

  @override
  List<Modifier> buildModifiers(firestoreData) {
    List<Modifier> modifiersList = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? modifiers =
        firestoreData.docs ?? [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> modifier in modifiers!) {
      //
      modifiersList.add(Modifier(modifier.id, modifier.data()["image"]));
    }
    return modifiersList;
  }

  @override
  getMaps(String gameName) {
    return FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(gameName)
        .snapshots();
  }

  @override
  List<GameMap> buildGameMaps(firestoreData) {
    List<GameMap> gameMaps = [];

    for (Map<String, dynamic> curMap in firestoreData.data()["maps"]) {
      String mapName = curMap.keys.first;
      String mapImage = curMap.values.first;
      gameMaps.add(GameMap(mapName, mapImage, []));
    }

    return gameMaps;
  }

  @override
  Future<void> updateGameWithMap(String gameName,
      List<Map<String, String>> maps, String mapToAdd, String imagePath) {
    return FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(gameName)
        .update({
      "maps": FieldValue.arrayUnion(maps +
          [
            {mapToAdd: imagePath}
          ])
    });
  }

  @override
  Stream getLineUpStream(String gameName, String mapName) {
    return FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(gameName)
        .collection(mapName)
        .snapshots();
  }

  @override
  List<Lineup> getLineupInfo(firestoreData) {
    List<Lineup> lineups = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        firestoreData.docs;
    for (QueryDocumentSnapshot<Map<String, dynamic>> cur in documents) {
      List<String> firbaseImagePaths = [];
      firbaseImagePaths.add(cur.data()["stand"]);
      firbaseImagePaths.add(cur.data()["aim"]);
      firbaseImagePaths.add(cur.data()["result"]);
      lineups.add(Lineup(cur.id, firbaseImagePaths, []));
    }

    return lineups;
  }

  @override
  Future<String> getImageURLFromFirebase(String path) async {
    return await storageRef.ref(path).getDownloadURL();
  }

  @override
  Future<void> addLineupToFirebase(
      String gameName,
      String mapName,
      String lineupName,
      String standImagePath,
      String aimImagePath,
      String resultImagePath) {
    return FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc(gameName)
        .collection(mapName)
        .doc(lineupName)
        .set(
      {
        "modifiers": [],
        "stand": standImagePath,
        "aim": aimImagePath,
        "result": resultImagePath,
      },
    );
  }

  @override
  signOutUser() {
    FirebaseAuth.instance.signOut();
  }
}
