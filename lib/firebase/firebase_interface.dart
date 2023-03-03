import 'dart:io';

import 'package:tome/game_data/game.dart';
import 'package:tome/game_data/game_map.dart';
import 'package:tome/game_data/lineup.dart';
import 'package:tome/game_data/modifier.dart';

abstract class FirebaseInterface<T> {
  Future initApp();

  bool hasUser();

  T signInWithEmailAndPassword(String email, String password);

  T createUserWithEmailAndPassword(String email, String password);

  T signOutUser();

  String getUserId();

  Future<T> setUsersGames(String gameToAdd, Map<String, dynamic> data);

  void signUpToTome(String email, String password);

  Future<List<Game>> getGames();

  void setUser(T user);

  Future<T> uploadImageToFirestorage(File? fileToUpload, String path);

  Future<T> getModifiers(String gameName);

  List<Modifier> buildModifiers(T firestoreData);

  Stream<T> getMaps(String gameName);

  List<GameMap> buildGameMaps(T firestoreData);

  Future<void> updateGameWithMap(String gameName,
      List<Map<String, String>> maps, String mapToAdd, String imagePath);

  Stream<T> getLineUpStream(String gameName, String mapName);

  List<Lineup> getLineupInfo(T firestoreData);

  Future<String> getImageURLFromFirebase(String path);

  Future<void> addLineupToFirebase(
      String gameName,
      String mapName,
      String lineupName,
      String standImagePath,
      String aimImagePath,
      String resultImagePath);
}
