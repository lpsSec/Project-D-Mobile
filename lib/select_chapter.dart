import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Project_D_Mobile/main.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class SelChapterPage extends StatefulWidget {

  final int mangaID;
  // ignore: use_key_in_widget_constructors
  const SelChapterPage(this.mangaID);

  @override
  _SelChapterPageState createState() => _SelChapterPageState();
}

class _SelChapterPageState extends State<SelChapterPage> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mangaID = widget.mangaID;

    debugPrint("MangaID clicked: $mangaID");

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.purple, Colors.purple.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            headerSection()
          ],
        ),
      ),
    );
  }

  AlertDialog displayAlert(String title, body_text, [button="OK"] ) {
    AlertDialog alert = AlertDialog(
    title: Text("$title"),
    content: Text("$body_text"),
    actions: [
      TextButton(
    child: Text("$button"),
    onPressed: () { Navigator.pop(context);  },
  ),
  ],
  );

  return alert;
  }

  Row headerSection() {

    return Row(
      children: [
        IconButton(
      icon: Icon(Icons.arrow_back),
      iconSize: 40,
      color: Colors.white,
      onPressed: (){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      },
    ),
      ],
    );
  }
}