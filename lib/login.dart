import 'dart:convert';

import 'package:Project_D_Mobile/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:Project_D_Mobile/main.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
            buttonLogin(),
            buttonRegister()
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

  signIn(String user, pass) async {

    if( user.isEmpty || pass.isEmpty )
    {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return displayAlert("Alerta", "Preencha os campos!", "VOLTAR");
      },
      );

      setState(() {
        _isLoading = false;
      });

      return;
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'SU_NICKNAME': user,
      'SU_PASSWORD': pass
    };
    var jsonResponse = null;
    var response = await http.post("https://project-d-api.herokuapp.com/auth/login",
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data)
    );

    jsonResponse = json.decode(response.body);

    if(response.statusCode == 200) {
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        
        var jsonData = jsonResponse['data'];

        sharedPreferences.setString("token", jsonResponse['token']);
        sharedPreferences.setInt("user_id", jsonData['SU_ID']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      }
    }
    else if(response.statusCode == 401){
      String msg = jsonResponse['mensagem'];

    showDialog(
    context: context,
    builder: (BuildContext context) {
      return displayAlert("Alerta", msg, "VOLTAR");
    },
    );
      setState(() {
        _isLoading = false;
      });
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Container buttonLogin() {
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
          signIn(userController.text, passwordController.text);
        },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Login", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

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
          // TODO: method to redirect to the RegisterPage - onPressed?
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => RegisterPage()), (Route<dynamic> route) => false);
        },
        elevation: 0.0,
        color: Colors.purple.shade600,
        child: Text("Cadastro", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  final TextEditingController userController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: userController,
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
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Senha",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {

    var assetsImage = new AssetImage('assets/images/Logo.png');
    var image = new Image(image: assetsImage, fit: BoxFit.cover);

    return Container(
      width: 250.0,
      height: 250,
            child: image
    );
  }
}