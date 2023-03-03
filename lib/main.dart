import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tome/firebase/ember.dart';
import 'package:tome/ui/home_page.dart';
import 'package:tome/ui/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: Ember.instance.initApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              print("<ERROR> :${snapshot.error}");
            }
            return Text("An error has occured: ${snapshot.error.toString()}");
          } else if (snapshot.hasData && !Ember.instance.hasUser()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            });
          } else if (snapshot.hasData && Ember.instance.hasUser()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            });
          }
          return _loadingScreen();
        },
      ) //const HomePage(),
      ));
}

Widget _loadingScreen() {
  return const Center(child: CircularProgressIndicator());
}
