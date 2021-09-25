import 'dart:convert';

import 'package:Project_D_Mobile/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Project_D_Mobile/register.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

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
            buttonReturn()
          ],
        ),
      ),
    );
  }

  registerUser(String nickname, login, password, phoneNumber, datebirthday ) async { /*NOTE: API needs SU_TYPE */
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'SU_NICKNAME': nickname,
      'SU_LOGINNAME': login,
      'SU_PASSWORD': password,
      'SU_PHONENUMBER': phoneNumber,
      'SU_DATEBIRTHDAY': datebirthday,
      'SU_PHOTO': 1, //TODO: hardcoded - implement checkbow with avatar icons.
      'SU_TYPE': 2 // not admin user
    };
    var jsonResponse = null;
    var response = await http.post("https://project-d-api.herokuapp.com/auth/register",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data)
    );

    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);
        nicknameController.text = "";
        emailController.text = "";
        passwordController.text = "";
        phoneController.text = "";
        bdayController.text = "";

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
    Container buttonRegister() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: nicknameController.text == "" /*|| passwordController.text == ""*/
        || emailController.text == "" || phoneController.text == "" || bdayController.text == ""? null : () {
          setState(() {
            _isLoading = true;
          });
          // Method to register the user - add to the database
          registerUser(nicknameController.text,  emailController.text,passwordController.text, phoneController.text, bdayController.text);
        },
        elevation: 0.0,
        color: Colors.purple.shade600,
        child: Text("Cadastrar", style: TextStyle(color: Colors.white70)),
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
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
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
  final TextEditingController bdayController = new TextEditingController();

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
              hintText: "Nickname",
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
              hintText: "Email",
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
              hintText: "Senha",
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
              hintText: "Telefone",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
            ),
            SizedBox(height: 30.0),
            TextFormField(
            controller: bdayController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.date_range, color: Colors.white70),
              hintText: "Data de aniverssario",
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
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Realizar cadastro",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
  // Container headerSection() {

  //   var assetsImage = new AssetImage('assets/images/Logo.png');
  //   var image = new Image(image: assetsImage, fit: BoxFit.cover);

  //   return Container(
  //     width: 250.0,
  //     height: 250,
  //           child: image
  //   );
  // }
}