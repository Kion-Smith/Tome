import 'package:flutter/material.dart';

class Modifier {
  final String _name;
  //final Icon _icon;
  final String _image;

  Modifier(this._name, this._image);

  String get modifierName => _name;
  String get modifierImage => _image;
}
