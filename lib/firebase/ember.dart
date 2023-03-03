import 'package:tome/firebase/firbase_utils.dart';
import 'package:tome/firebase/firebase_firedart.dart';
import 'package:tome/firebase/firebase_interface.dart';
import 'package:tome/firebase/firebase_official.dart';

class Ember {
  Ember._privateConstructor();
  static final FirebaseInterface _instance =
      isOfficallySupportedPlatform() ? FirebaseOfficial() : FirebaseFiredart();

  static FirebaseInterface get instance => _instance;
}
