import 'dart:convert';

import 'package:Project_D_Mobile/login.dart';
import 'package:flutter/foundation.dart';
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

final _messangerKey = GlobalKey<ScaffoldMessengerState>();
bool _isLoading = false;
int selected_avatar = 1; // 1 - no avatar

// NOTE: Here we can know the selected avatar [ avatar_id | if is checked]
Map<int, bool> avatar_check = {
    2: false,
    3: false,
    4: false,
    5: false,
};

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
            avatarContainer(),
            buttonRegister(),
            buttonReturn(),
          ],
        ),
      ),
    );
  }

  registerUser(String nickname, login, password, phoneNumber, datebirthday ) async { /*NOTE: API needs SU_TYPE */
    
    if(nickname == "" || login == "" || password == "" || phoneNumber == "" || datebirthday == ""){
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
    Map data = {
      'SU_NICKNAME': nickname,
      'SU_LOGINNAME': login,
      'SU_PASSWORD': password,
      'SU_PHONENUMBER': phoneNumber,
      'SU_DATEBIRTHDAY': datebirthday,
      'SU_PHOTO': selected_avatar,
      'SU_TYPE': 2 // 2 - not admin user
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

        // TODO: Clear text field - *This code does not work
        nicknameController.clear();
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        bdayController.clear();

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
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //       content: Text('Added added into cart'),
          //       duration: Duration(seconds: 2)
          //       // action: SnackBarAction(label: 'UNDO', onPressed: () {}),
          //     ));
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
        },
        elevation: 0.0,
        color: Colors.purple.shade600,
        child: Text("Voltar", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Container avatarContainer() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          checkBoxSection(2),
          avatarSection('assets/images/avatar.png'),
          checkBoxSection(3),
          avatarSection('assets/images/avatar2.png'),
          checkBoxSection(4),
          avatarSection('assets/images/avatarWoman.png'),
          checkBoxSection(5),
          avatarSection('assets/images/avatarWoman2.png'),
        ]
      ),
    );
  }

  Container checkBoxSection(int avatar_id) {
    return Container(

    child: Checkbox(
          value: avatar_check[avatar_id], // NOTE: -2 because avatar list id starts in 2 (2,3,4,5)
          checkColor: Colors.white,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              
              avatar_check[avatar_id] = value!;
              
              // deselect others checkBox - apply one the current checkBox
              for(var id in avatar_check.keys)
              {
                if( id != avatar_id) {
                  avatar_check[id] = false;
                }
              }

              if( value ){
                selected_avatar = avatar_id;
              }
            });
          }),

    );
  }
  Container avatarSection(String imagePath) {
    var assetsImage = new AssetImage(imagePath);

    return Container(
    child: SizedBox(
    child: CircleAvatar(
      radius: 40.0,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        child: Align(
          alignment: Alignment.bottomRight,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 12.0,
            child: Icon(
              Icons.camera_alt,
              size: 15.0,
              color: Color(0xFF404040),
            ),
          ),
        ),
        radius: 38.0,
        backgroundImage: assetsImage,
      ),
    ),)
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
      margin: EdgeInsets.only(top: 0.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Realizar cadastro",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}