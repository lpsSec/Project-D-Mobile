import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:Project_D_Mobile/login.dart';
import 'package:Project_D_Mobile/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Project_D_Mobile/editr_user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<EditPage> {

//final _messangerKey = GlobalKey<ScaffoldMessengerState>();
bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            headerSection(),
            textSection(),
            buttonRegister(),
            buttonReturn(),
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

  editUserInfo(String nickname, login, password, phoneNumber ) async {
    
    if(nickname == "" && login == "" && password == "" && phoneNumber == "" ){

      showDialog(
      context: context,
      builder: (BuildContext context) {
        return displayAlert("Alerta", "Preencha os campos!");
      },
      );

      setState(() {
        _isLoading = false;
      });

      return;

    }

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var token = sharedPreferences.getString("token");
  var userId = sharedPreferences.getInt("user_id");

  // Create json map according data received
  Map data = {
    'SU_ID': userId
  };
  if( nickname != "" ){
    data['SU_NICKNAME'] = nickname;}
  if( login != "" ){
    data['SU_LOGINNAME'] = login;}
  if( password != "" ){
    data['SU_PASSWORD'] = password;}
  if( phoneNumber != "" ){
    data['SU_PHONENUMBER'] = phoneNumber;}
    
    var jsonResponse = null;
    var response = await http.post("https://project-d-api.herokuapp.com/user/edit",
    headers: {
      "Content-Type": "application/json",
    "Authorization": 'Baerer ' + token.toString()
    },
    body: jsonEncode(data)
    );

    if(response.statusCode == 201) { //201 - HTTP Response 'Created'
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);

        showDialog(
        context: context,
        builder: (BuildContext context) {
        return displayAlert("Sucesso", "Usuário modificado com sucesso!");
      },
      );

      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

final TextEditingController errorMessage = new TextEditingController();
    Container buttonRegister() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          editUserInfo(nicknameController.text,  emailController.text,passwordController.text, phoneController.text);
        },
        elevation: 0.0,
        color: Colors.purple.shade600,
        child: Text("Alterar", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Container buttonReturn() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          // TEST
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //       content: Text('xxxxxxxxxxxxxxx'),
          //       duration: Duration(seconds: 2)
          //       // action: SnackBarAction(label: 'OK', onPressed: () {}),
          //     ));
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
        },
        elevation: 0.0,
        color: Colors.purple.shade600,
        child: Text("Voltar", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController nicknameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: nicknameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.login, color: Colors.white70),
              hintText: "Novo Nickname",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Novo Email",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
            TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Nova Senha",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
            ),
            SizedBox(height: 30.0),
            TextFormField(
            controller: phoneController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.phone, color: Colors.white70),
              hintText: "Novo Telefone",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
            ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 0.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Editar informações",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}