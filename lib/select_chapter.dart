import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Project_D_Mobile/main.dart';
import 'package:Project_D_Mobile/login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

Card chapterCard(int chapterId, String archive, String title, BuildContext context) {
    return Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(title),
              trailing: Icon(Icons.menu_book_rounded),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Column(children: [
                SizedBox(height: 10),
                Container(child: Text("Capitulo número: $chapterId"))
              ],)
            ),
            ButtonBar(
              children: [
                TextButton(
                  child: const Text('LER', textScaleFactor: 1.5),
                  onPressed: () async {
                    //TODO: open manga arhive with some PDF Reader.
                    },
                ),
              ],
            )
          ],
        ));
  }

class SelChapterPage extends StatefulWidget {

  final int mangaID;
  final String mangaTitle;
  // ignore: use_key_in_widget_constructors
  const SelChapterPage(this.mangaID, this.mangaTitle);

  @override
  _SelChapterPageState createState() => _SelChapterPageState();
}

class Chapters {
    final int chapter_id;
    final String chapter_archive;

    Chapters( this.chapter_id, this.chapter_archive);
}

class _SelChapterPageState extends State<SelChapterPage> {

  final bool _isLoading = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();

    WidgetsBinding.instance!
    .addPostFrameCallback( (_) => runChapters(widget.mangaID));
  }

  final List<Chapters> mangaChapters = []; 

  Future<List<Chapters>> _getChaters() async {

  return mangaChapters;
  }

  @override
  Widget build(BuildContext context) {
    final mangaID = widget.mangaID;

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

  runChapters(int mangaId) async{
    late SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    var jsonResponse = null;
    var response = await http.get("https://project-d-api.herokuapp.com/manga/chapters/$mangaId",
    headers: {
      "Authorization": 'Baerer ' + token.toString()
    },
    );
    jsonResponse = json.decode(response.body);

    var jsonData = jsonResponse['data'];

    for (var item in jsonData)
    {
      int id = jsonData['MGC_ID'];
      String archive = jsonData['MGC_ARCHIVE'];

      Chapters chapter = Chapters(id, archive );
      mangaChapters.add( chapter );
    }

    debugPrint("\n\nManga Chapters: $jsonData\n");
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  AlertDialog displayAlert(String title, bodyText, [button="OK"] ) {
    AlertDialog alert = AlertDialog(
    title: Text("$title"),
    content: Text("$bodyText"),
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