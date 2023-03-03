import 'dart:io';

import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
import 'package:firebase_dart/storage.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:tome/firebase/firbase_utils.dart';
import 'package:tome/firebase/firebase_interface.dart';
import 'package:tome/firebase/pres_store.dart';
import 'package:tome/firebase_options.dart';
import 'package:tome/game_data/game.dart';
import 'package:tome/game_data/game_map.dart';

import 'package:path/path.dart';
import 'package:tome/game_data/lineup.dart';
import 'package:tome/game_data/modifier.dart';

class FirebaseFiredart implements FirebaseInterface {
  late User? _currentUser;
  FirebaseStorage? _storage;
  @override
  Future initApp() async {
    _currentUser = null;
    FirebaseDart.setup();
    var firebaseDart =
        await Firebase.initializeApp(options: officalToFirebaseDartOptions());
    _storage = FirebaseStorage.instanceFor(app: firebaseDart);
    FirebaseAuth.initialize(
        DefaultFirebaseOptions.windows.apiKey, await PreferencesStore.create());
    try {
      _currentUser = await FirebaseAuth.instance.getUser();
      // ignore: empty_catches
    } catch (exception) {}

    return Firestore.initialize(DefaultFirebaseOptions.windows.projectId);
  }

  FirebaseOptions officalToFirebaseDartOptions() {
    return FirebaseOptions(
        storageBucket: "gs://tome-8879a.appspot.com",
        appId: DefaultFirebaseOptions.windows.appId,
        apiKey: DefaultFirebaseOptions.windows.apiKey,
        projectId: DefaultFirebaseOptions.windows.projectId,
        messagingSenderId: DefaultFirebaseOptions.windows.messagingSenderId,
        authDomain: DefaultFirebaseOptions.windows.authDomain);
  }

  @override
  bool hasUser() {
    return _currentUser != null;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) {
    return FirebaseAuth.instance.signIn(email, password);
  }

  @override
  String getUserId() {
    return _currentUser!.id;
  }

  @override
  Future<void> setUsersGames(String gameToAdd, Map<String, dynamic> data) {
    //Firestore.instance.collection("user").document(getUserId()).set(data);
    return Firestore.instance
        .collection(getUserId())
        .document(gameToAdd)
        .set(data);
  }

  @override
  void signUpToTome(String email, String password) {
    createUserWithEmailAndPassword(email, password).then(
      (value) {
        _currentUser = value;
        //setUsersGames({"games": [], "image": ""});
      },
    );
  }

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) {
    return FirebaseAuth.instance.signUp(email, password);
  }

  @override
  Future<List<Game>> getGames() async {
    Page<Document> userCollection =
        await Firestore.instance.collection(_currentUser!.id).get();

    List<Game> games = [];
    for (Document game in userCollection) {
      List<GameMap> gameMaps = [];
      for (Map<String, dynamic> curMap in game.map["maps"]) {
        String mapName = curMap.keys.first;
        String mapImage = curMap.values.first;
        gameMaps.add(GameMap(mapName, mapImage, []));
      }
      games.add(Game(game.id, game.map["image"], gameMaps));
    }

    return games;
  }

  @override
  void setUser(dynamic user) {
    _currentUser = user;
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
      final ref = _storage!.ref(imagePath);
      var res = await ref.putData(selectedGameImage.readAsBytesSync());
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
    return Firestore.instance
        .collection(getUserId())
        .document(gameName)
        .collection("modifiers")
        .get();
  }

  @override
  List<Modifier> buildModifiers(firestoreData) {
    List<Modifier> modifiersList = [];

    Page<Document> doc = firestoreData as Page<Document>;
    for (var element in doc) {
      modifiersList.add(Modifier(element.id, element.map["image"]));
    }
    return modifiersList;
  }

  @override
  getMaps(String gameName) {
    return Firestore.instance.collection(getUserId()).document(gameName).stream;
  }

  @override
  List<GameMap> buildGameMaps(firestoreData) {
    List<GameMap> gameMaps = [];

    Document data = firestoreData as Document;
    data.map["maps"];
    for (Map<String, dynamic> curMap in data.map["maps"]) {
      String mapName = curMap.keys.first;
      String mapImage = curMap.values.first;
      gameMaps.add(GameMap(mapName, mapImage, []));
    }

    return gameMaps;
  }

  @override
  Future<void> updateGameWithMap(String gameName,
      List<Map<String, String>> maps, String mapToAdd, String imagePath) {
    maps.add({mapToAdd: imagePath});
    return Firestore.instance
        .collection(getUserId())
        .document(gameName)
        .update({"maps": maps});
  }

  @override
  Stream getLineUpStream(String gameName, String mapName) {
    return Firestore.instance
        .collection(getUserId())
        .document(gameName)
        .collection(mapName)
        .stream;
  }

  @override
  List<Lineup> getLineupInfo(firestoreData) {
    List<Lineup> lineups = [];

    List<Document> documents = firestoreData as List<Document>;
    for (var curDocument in documents) {
      List<String> firbaseImagePaths = [];
      firbaseImagePaths.add(curDocument.map["stand"]);
      firbaseImagePaths.add(curDocument.map["aim"]);
      firbaseImagePaths.add(curDocument.map["result"]);
      lineups.add(Lineup(curDocument.id, firbaseImagePaths, []));
    }
    // List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
    //     firestoreData.docs;
    // for (QueryDocumentSnapshot<Map<String, dynamic>> cur in documents) {
    //   firbaseImagePaths.add(cur.data()["stand"]);
    //   firbaseImagePaths.add(cur.data()["aim"]);
    //   firbaseImagePaths.add(cur.data()["result"]);
    //   lineups.add(Lineup(cur.id, firbaseImagePaths, []));
    // }

    return lineups;
  }

  @override
  Future<String> getImageURLFromFirebase(String path) async {
    return await _storage!.ref(path).getDownloadURL();
  }

  @override
  Future<void> addLineupToFirebase(
      String gameName,
      String mapName,
      String lineupName,
      String standImagePath,
      String aimImagePath,
      String resultImagePath) {
    return Firestore.instance
        .collection(getUserId())
        .document(gameName)
        .collection(mapName)
        .document(lineupName)
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
