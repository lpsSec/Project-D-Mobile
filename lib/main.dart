// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:async';

import 'package:Project_D_Mobile/editr_user_info.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:Project_D_Mobile/login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "YourManga",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
        accentColor: Colors.white70
      ),
    );
  }
}

class Manga{
    final int id;
    final String title;
    final String img_path;
    final int num_chapters;
    final String archive;

    Manga( this.id, this.title, this.img_path, this.num_chapters, this.archive );
}

Card mangaCard(String title, String imgPath, int numChapters, String archive) {
    var bgImg = NetworkImage(imgPath);
    var description = 'Descrição padrão do manga.';
    
    return Card(
        elevation: 4.0,
        child: Column(
          children: [
            ListTile(
              title: Text(title),
              // subtitle: Text(subheading),
              trailing: Icon(Icons.menu_book_rounded),
            ),
            Container(
              height: 200.0,
              child: Ink.image(
                image: bgImg,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Column(children: [
                Container(child: Text(description),),
                SizedBox(height: 10),
                Container(child: Text("Quantidade de capitulos: $numChapters."))
              ],)
            ),
            ButtonBar(
              children: [
                TextButton(
                  child: const Text('LER', textScaleFactor: 1.5),
                  onPressed: () async {
                    // launch(archive);
                    debugPrint("Manga clicked: $title \nArchive: $archive\n\n");

                    {//TEST
                    // late SharedPreferences sharedPreferences;
                    //   sharedPreferences = await SharedPreferences.getInstance();
                    //   var token = sharedPreferences.getString("token");

                    //     var jsonResponse = null;int id = 1;
                    //     var response = await http.get("https://project-d-api.herokuapp.com/manga/chapters/$id",
                    //     headers: {
                    //       "Authorization": 'Baerer ' + token.toString()
                    //     },
                    //     );
                    //     jsonResponse = json.decode(response.body);
                    //     debugPrint("MANGA INFO: $jsonResponse");
                    }

                   //TODO: Go to 'select chapters page' passing manga id as parameter to get all manga chapters.
                   //
                   // 
                    },
                ),
              ],
            )
          ],
        ));
  }

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  late SharedPreferences sharedPreferences;
  bool _isLoading = false;

  final List<Manga> mangaList = []; 

  Future<List<Manga>> _getMangas() async {

    return mangaList;
  }


  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  final TextEditingController searchController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YourManga", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body:
      Column(
        children: <Widget> [
          Row(
  children: <Widget>[
    Expanded(
      child: _isLoading ? Center(child: CircularProgressIndicator()) :
      TextField(
              controller: searchController,
              autofocus: false,
              decoration:
              InputDecoration(
              icon: Icon(Icons.arrow_forward_ios_rounded),
              hintText: 'Pesquisar...'),
              onChanged: (text) {
              },
            )
    ),
      SizedBox(height: 75),
      IconButton( onPressed: () {

        if( searchController.text.length < 3 )
        {
          showDialog(
          context: context,
          builder: (BuildContext context) {
          return displayAlert("Alerta", "A busca deve conter pelo menos 3 caracteres.", "VOLTAR");
          },
          );

          setState(() {
            _isLoading = false;
          });

          return;
        } 
        var search = searchController.text;
        searchForManga(search);
      },
      icon: const Icon(Icons.search),
      ),
  ],
),
mangaList.isEmpty? Text("Nenhum manga encontrado."):

Expanded(child:
Container(
      child: FutureBuilder(
initialData: [],
future: _getMangas(), 
builder: (BuildContext context, AsyncSnapshot snapshot ){
  return ListView.builder(
    itemCount: snapshot.data.length,
    itemBuilder: (BuildContext context, int index){
      String title = snapshot.data[index].title;
      String link = snapshot.data[index].archive;
      String img = snapshot.data[index].img_path;
      int num_chapters = snapshot.data[index].num_chapters;

      // using card
      return mangaCard(title, img, num_chapters, link );
    }
  );
},
),
),
),


        ],
      ),

      // Drawer
      drawer: Drawer(
        child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Editar"),
                subtitle: Text("editar minhas informações pessoais."),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => EditPage()), (Route<dynamic> route) => false);
                }
               )
            ],),
      ),
    );
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

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  searchForManga( String search ) async {
    sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    Map data = {
      'MG_TITLE': search
    };

    var jsonResponse = null;
    var response = await http.post("https://project-d-api.herokuapp.com/manga/byName",
    // var response = await http.get("https://project-d-api.herokuapp.com/manga/",
    headers: {
      "Content-Type": "application/json",
      "Authorization": 'Baerer ' + token.toString()
    },
    body: jsonEncode(data)
    );

    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });

        var jsonData = jsonResponse['data'];

        // DEBUG: display response
        // debugPrint("\nSearch: $jsonData");

        //Clear manga list
        mangaList.clear();

      // Looping through all response itens
        for (var item in jsonData) {
          int ID = item['MG_ID'];
          var title = item['MG_TITLE'];
          var imgPath = item['MGP_PATH'];
          var numChapters = item['MGC_SEQCHAPTER'];
          var archive = item['MGC_ARCHIVE'];

          debugPrint("ID: $ID");
          debugPrint("Title: $title");
          debugPrint("Img Path: $imgPath");
          debugPrint("Archive: $archive");
          debugPrint("Chapters: $numChapters\n\n");

          Manga manga = Manga(item['MG_ID'],
                              item['MG_TITLE'],
                              item['MGP_PATH'],
                              item['MGC_SEQCHAPTER'],
                              item['MGC_ARCHIVE']);

          mangaList.add(manga);

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

}