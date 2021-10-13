// import 'dart:html' as html;
// NOTE: disabled - supported on web device only.


// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Project_D_Mobile/select_chapter.dart';
import 'package:Project_D_Mobile/login.dart';

class PdfVisualizer extends StatefulWidget {
  final String mangaTitle;
  final String chapterArchive;
  final int mangaID;
  // ignore: use_key_in_widget_constructors
  const PdfVisualizer(this.mangaID,this.chapterArchive, this.mangaTitle);

  @override
  _PdfVisualizerState createState() => _PdfVisualizerState();
}

class _PdfVisualizerState extends State<PdfVisualizer> {
    
  late SharedPreferences sharedPreferences;
  bool _isLoading = false;

  String url = "http://www.africau.edu/images/default/sample.pdf";
  String asset = "assets/sample.pdf";

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {

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
          children: [
            headerSection(),
            Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) :
            SfPdfViewer.network(widget.chapterArchive),
            ),
          ],
        )
      )
    );
  }

  checkLoginStatus() async {
  sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
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
        (BuildContext context) => SelChapterPage(widget.mangaID, widget.mangaTitle)), (Route<dynamic> route) => false);
      },
    ),
    const Text("Sair",style: TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }
}