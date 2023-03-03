import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:tome/game_data/modifier.dart';

class ModifiersPage extends StatefulWidget {
  final String gameName;
  final String mapName;
  final List<Modifier> modifiers;
  const ModifiersPage(
      {super.key,
      required this.gameName,
      required this.mapName,
      required this.modifiers});
  @override
  State<StatefulWidget> createState() => _ModifiersPageState();
}

class _ModifiersPageState extends State<ModifiersPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Modifiers"),
        ),
        body: _buildHomePage());
  }

  Widget _buildHomePage() {
    return ListView.builder(
      itemCount: widget.modifiers.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.ac_unit_rounded),
          title: Text(widget.modifiers[index].modifierName),
        );
      },
    );
  }

  Widget _buildCreateModifierPopUp() {
    return AlertDialog(
      title: const Text(
        "Add A Modifier",
      ),
      content: Wrap(children: [
        TextFormField(),
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () async {
                  XFile? image =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                },
                child: const Text("Select an image"))),
      ]),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Add")),
      ],
    );
  }
}
