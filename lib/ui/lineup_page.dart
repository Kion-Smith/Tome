// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tome/firebase/ember.dart';
import 'package:tome/firebase/firbase_utils.dart';
import 'package:tome/game_data/lineup.dart';
import 'package:tome/game_data/modifier.dart';

class LineupPage extends StatefulWidget {
  late Lineup _lineup;
  late List<Modifier> _modifiers;
  LineupPage({super.key, required lineup, required modifiers}) {
    _lineup = lineup;
    _modifiers = modifiers;
  }

  @override
  State<StatefulWidget> createState() => _LineupPageState();
}

class _LineupPageState extends State<LineupPage> {
  @override
  void initState() {
    super.initState();
  }

  //final Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget._lineup.lineupName),
        ),
        body: buildListOfLineups());
  }

  Widget buildListOfLineups() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 50),
      itemCount: widget._lineup.getMedia.length,
      itemBuilder: (context, index) {
        if (widget._lineup.getMedia[index].isEmpty) {
          return Container();
        }
        String name = "";
        switch (index) {
          case 0:
            name = "Stand";
            break;
          case 1:
            name = "Aim";
            break;
          case 2:
            name = "Throw";
            break;
          default:
            name = "Error";
        }

        print(index.toString() + name);

        return buildTile(name, widget._lineup.getMedia[index]);
      },
    );
  }

  Widget buildTile(String nameOfTile, String imageContents) {
    return ListTile(
        title: Center(child: Text(nameOfTile)),
        subtitle: buildImage(imageContents));
  }

  Widget buildImage(String path) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRect(
            child: FutureBuilder(
                future: Ember.instance.getImageURLFromFirebase(path),
                builder: ((context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Unable to load image");
                  }
                  if (snapshot.hasData) {
                    // return PhotoView(
                    //     maxScale: PhotoViewComputedScale.contained,
                    //     minScale: PhotoViewComputedScale.contained,
                    //     imageProvider: NetworkImage(snapshot.data!));

                    return GestureDetector(
                      child: buildPhotoView(snapshot.data!, 1, 1, true),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                _buildImagePopUp(snapshot.data!));
                      },
                    );
                  }

                  return _loadingScreen();
                }))));
  }

  Widget buildPhotoView(String imageURL, double maxScale, double minScale,
      bool shouldDisableGestures) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: PhotoView(
            backgroundDecoration:
                BoxDecoration(color: const Color.fromARGB(0, 0, 0, 0)),
            disableGestures: shouldDisableGestures,
            maxScale: PhotoViewComputedScale.contained * maxScale,
            minScale: PhotoViewComputedScale.contained * minScale,
            imageProvider: NetworkImage(imageURL)));
  }

  Widget _loadingScreen() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildImagePopUp(String imageURL) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      content: buildPhotoView(imageURL, 5, 1, false),
      // actions: [
      //   ElevatedButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //       child: const Text("Go back")),
      // ],
    );
  }
}
