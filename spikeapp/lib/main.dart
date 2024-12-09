import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:spikeapp/blank.dart';
import 'package:spikeapp/forum.dart';
import 'package:spikeapp/home.dart';
import 'package:spikeapp/upload.dart';
import 'login.dart';


void main() {
  final PocketBase pb = PocketBase('https://spikestone.site');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'spikeapp',
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWidget(),
        '/home' : (context) => HomePage(),
        '/blank' : (context) => Blank(),
        '/forum' : (context) => ForumPage(),
        '/upload' : (context) => MultipleFileUpload()
      },
    );
  }
}
