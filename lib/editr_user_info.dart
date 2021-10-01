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

  /* TEST - material app to use scaffoldMessengerKey - Display message error
  return MaterialApp(
    scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
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
            avatarContainer(),
            buttonRegister(),
            buttonReturn(),
          ],
        ),
      ),
    ),
  );
  */
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

  editUserInfo(String nickname, login, password, phoneNumber ) async { /*NOTE: API needs SU_TYPE */
    
    if(nickname == "" || login == "" || password == "" || phoneNumber == "" ){
        /* ON HOLD - Display error message
        _messangerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Preencha os campos!'),
        duration: Duration(seconds: 3),
        // action: SnackBarAction(label: 'OK', onPressed: () {
        //           Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => RegisterPage()), (Route<dynamic> route) => false);
        //         }),
        ));
        */
        // return;
    }

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var token = sharedPreferences.getString("token");
  var user_id = sharedPreferences.getInt("user_id");

  // Create json map according data received
  Map data = {
    'SU_ID': user_id
  };
  if( nickname != "" )
    data['SU_NICKNAME'] = nickname;
  if( login != "" )
    data['SU_LOGINNAME'] = login;
  if( password != "" )
    data['SU_PASSWORD'] = password;
  if( phoneNumber != "" )
    data['SU_PHONENUMBER'] = phoneNumber;

    // Map data = {
    //   'SU_ID': user_id,
    //   'SU_NICKNAME': nickname,
    //   'SU_LOGINNAME': login,
    //   'SU_PASSWORD': password,   //password change is on hold - need to review on API backend
    //   'SU_PHONENUMBER': phoneNumber,
    // };
    var jsonResponse = null;
    var response = await http.post("https://project-d-api.herokuapp.com/user/edit",
    headers: {
      "Content-Type": "application/json",
    "Authorization": 'Baerer ' + token.toString()
    },
    body: jsonEncode(data)
    );

    if(response.statusCode == 201) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);

        // TODO: Clear text field - *This code does not work
        nicknameController.clear();
        emailController.clear();
        passwordController.clear();
        phoneController.clear();

        // TODO: display successful msg if reponse status is 200.
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
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //       content: Text('Added added into cart'),
          //       duration: Duration(seconds: 2)
          //       // action: SnackBarAction(label: 'UNDO', onPressed: () {}),
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