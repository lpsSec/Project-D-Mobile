// ignore: import_of_legacy_library_into_null_safe
import 'dart:html' as html;

// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
// ignore: import_of_legacy_library_into_null_safe
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
  // late PDFDocument _doc;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();



    // _initPDF();

    _launchePDF();

  }

  _launchePDF() async {
    html.window.open("https://docs.google.com/gview?embedded=true&url=http://www.africau.edu/images/default/sample.pdf", "name");

    // String url = widget.chapterArchive;
    // debugPrint("URL: $url");

    // if( await canLaunch(url))
    // {
    //   launch(url, forceWebView: true,enableJavaScript: true);
    // }
    // else
    // {
    //   String debug = widget.chapterArchive;
    //   debugPrint("CANNOT LAUNCH: $debug");
    // } 
  }

  // _initPDF() async {
  //   setState(() {
  //     _isLoading = true; 
  //   });
  //   final doc = await PDFDocument.fromURL(widget.chapterArchive);
  //   setState(() {
  //     _doc = doc;
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final archive = widget.chapterArchive;
    final title = widget.mangaTitle;

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
        // WebView(
          // initialUrl: ('https://docs.google.com/gview?embedded=true&url=http://www.africau.edu/images/default/sample.pdf'),
          // javascriptMode: JavascriptMode.unrestricted,
        // ),
        child: Column(
          children: [
            headerSection(),
            Expanded(child: _isLoading ? Center(child: CircularProgressIndicator()) :
            Text(""),
            // PDFViewer(document: _doc),
            // SfPdfViewer.network(widget.chapterArchive),
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