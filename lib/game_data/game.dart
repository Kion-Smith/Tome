import 'package:tome/game_data/game_map.dart';

class Game {
  final String _title;
  final String _image;
  final List<GameMap> _maps;

  Game(this._title, this._image, this._maps);

  String get gameName => _title;

  List<GameMap> get gameMaps => _maps;

  void printMaps() {
    for (GameMap curMap in _maps) {
      print(curMap.mapName);
    }
  }
}
