import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tome/firebase/ember.dart';
// ignore: depend_on_referenced_packages
import 'package:tome/game_data/lineup.dart';
import 'package:tome/game_data/modifier.dart';
import 'package:tome/ui/build_lineup_page.dart';
import 'package:tome/ui/lineup_page.dart';
import 'package:tome/ui/modifiers_page.dart';

// ignore: must_be_immutable
class LineupSelectionPage extends StatefulWidget {
  final String gameName;
  final String mapName;
  final List<Modifier> modifiers;
  const LineupSelectionPage(
      {super.key,
      required this.gameName,
      required this.mapName,
      required this.modifiers});
  @override
  State<StatefulWidget> createState() => _LineupSelectionPageState();
}

class _LineupSelectionPageState extends State<LineupSelectionPage> {
  late List<Lineup> _lineups;
  @override
  void initState() {
    _lineups = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select A Lineup"),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Modifier',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ModifiersPage(
                            modifiers: widget.modifiers,
                            gameName: widget.gameName,
                            mapName: widget.mapName,
                          )));
                })
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
        body: _buildHomePage());
  }

  Widget _buildHomePage() {
    return StreamBuilder(
      // stream: FirebaseFirestore.instance
      //     .collection(FirebaseAuth.instance.currentUser!.uid)
      //     .doc(widget.gameName)
      //     .collection(widget.mapName)
      //     .snapshots(),
      stream: Ember.instance.getLineUpStream(widget.gameName, widget.mapName),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (kDebugMode) {
            print("<ERROR> :${snapshot.error}");
          }
          return Text("An error has occured: ${snapshot.error.toString()}");
        } else if (snapshot.hasData) {
          _lineups = Ember.instance.getLineupInfo(snapshot.data);
          // List<String> firbaseImagePaths = [];
          // List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
          //     snapshot.data!.docs;
          // for (QueryDocumentSnapshot<Map<String, dynamic>> cur in documents) {
          //   firbaseImagePaths.add(cur.data()["stand"]);
          //   firbaseImagePaths.add(cur.data()["aim"]);
          //   firbaseImagePaths.add(cur.data()["result"]);
          //   _lineups.add(Lineup(cur.id, firbaseImagePaths, []));
          // }
        }
        return buildListOfLineups();
      },
    );
  }

  Widget buildListOfLineups() {
    return _lineups.isEmpty
        ? const Text("No Lineups")
        : ListView.builder(
            itemCount: _lineups.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_lineups[index].lineupName),
                onTap: () {
                  _lineups[index].printLineupInfo();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LineupPage(
                        modifiers: widget.modifiers, lineup: _lineups[index]),
                  ));
                },
              );
            },
          );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BuildLineupPage(
                  modifiers: widget.modifiers,
                  gameName: widget.gameName,
                  mapName: widget.mapName,
                ))));
  }
}
