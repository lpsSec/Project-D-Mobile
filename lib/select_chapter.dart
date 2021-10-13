import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Project_D_Mobile/main.dart';
import 'package:Project_D_Mobile/login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Project_D_Mobile/pdf_visualizer.dart';

Card chapterCard(int mangaId, int chapterId, String archive, String title, BuildContext context) {
    return Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(title),
              trailing: Icon(Icons.library_books),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Column(children: [
                SizedBox(height: 10),
                Container(child: Text("Capítulo número: $chapterId"))
              ],)
            ),
            ButtonBar(
              children: [
                TextButton(
                  child: const Text('LER', textScaleFactor: 1.5),
                  onPressed: () async {
                    //TODO: open manga arhive with some PDF Reader.
                    // debugPrint("Must open $archive");

                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                    (BuildContext context) => PdfVisualizer(mangaId, archive,title)), (Route<dynamic> route) => false);

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
    final int mangaId;
    final int chapter_id;
    final String chapter_archive;

    Chapters( this.mangaId, this.chapter_id, this.chapter_archive);
}

class _SelChapterPageState extends State<SelChapterPage> {

  bool _isLoading = false;
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
      body:
       Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.purple, Colors.purple.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          children: <Widget>[
            headerSection(),
            Expanded(child: _isLoading ? Center(child: CircularProgressIndicator()) :
            mangaChapters.isEmpty? Text("Nenhum capítulo encontrado."): 
            FutureBuilder(
            initialData: [],
            future: _getChaters(), 
            builder: (BuildContext context, AsyncSnapshot snapshot ){
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index){
            int mangaId = snapshot.data[index].mangaId;
            int chapterId = snapshot.data[index].chapter_id;
            String archive = snapshot.data[index].chapter_archive;
            
            // using card
            return chapterCard(mangaId,chapterId, archive, widget.mangaTitle, context);
                }
              );
            },
            ),
            )
          ],
        ),
      )
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

    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });

      var jsonData = jsonResponse['data'];

      //Clear chapters list
      mangaChapters.clear();

      // Looping through all response itens
      for (var item in jsonData) {
        int managaId = item['MG_ID'];
        int chapterId = item['MGC_ID'];
        String archive = item['MGC_ARCHIVE'];

        Chapters chapter = Chapters(managaId, chapterId, archive );
        mangaChapters.add( chapter );

        // DEBUG
        // debugPrint("\n\nManga: $managaId | Capitulo: $chapterId | Arhcive: $archive\n");

        }
      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
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
        const SizedBox(height: 100),
        IconButton(
      icon: const Icon(Icons.arrow_back),
      iconSize: 40,
      color: Colors.black,
      onPressed: (){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
        (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      },
    ),
    const Text("Voltar ao menu",style: TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }
}