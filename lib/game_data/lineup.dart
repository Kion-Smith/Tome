import 'package:tome/game_data/modifier.dart';

class Lineup {
  final String _name;
  final List<String> _media;
  final List<Modifier> _modifiers;

  Lineup(this._name, this._media, this._modifiers);

  String get lineupName => _name;
  List<String> get getMedia => _media;
  List<Modifier> get getModifiers => _modifiers;

  void printLineupInfo() {
    for (String cur in _media) {
      print("Image ${cur}");
    }

    for (Modifier cur in _modifiers) {
      print("Modifiers ${cur.modifierName}");
    }
  }
}
