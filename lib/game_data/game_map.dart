import 'package:tome/game_data/lineup.dart';

class GameMap {
  final String _name;
  final String _image;
  final List<Lineup> _lineups;

  GameMap(this._name, this._image, this._lineups);

  String get mapName => _name;
  String get mapImage => _image;

  List<Lineup> get mapLineups => _lineups;
}
