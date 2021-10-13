import 'dart:convert';

import 'package:Project_D_Mobile/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

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

  registerUser(String nickname, login, password, phoneNumber, datebirthday ) async {
    
    if(nickname == "" || login == "" || password == "" || phoneNumber == "" || datebirthday == ""){

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

    //Validate inputs
    //email
    Pattern mailPattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(mailPattern.toString());
    if (!regex.hasMatch(login))
    {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return displayAlert("Alerta", "Email inválido!", "VOLTAR");
      },
      );

      setState(() {
        _isLoading = false;
      });

      return;
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

    if(response.statusCode == 201) { // 201 - Created
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        // REVIEW: store auth token?? - user is able to be login with do login.
        // sharedPreferences.setString("token", jsonResponse['token']);

        showDialog(
      context: context,
      builder: (BuildContext context) {
        return displayAlert("Sucesso", "Usuário $nickname cadastrado com sucesso!");
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

  SizedBox avatarContainer() {
    return SizedBox.fromSize(
      child: FittedBox(child:
          Row(children: <Widget>[
          checkBoxSection(2),
          avatarSection('assets/images/avatar.png'),
          checkBoxSection(3),
          avatarSection('assets/images/avatar2.png'),
          checkBoxSection(4),
          avatarSection('assets/images/avatarWoman.png'),
          checkBoxSection(5),
          avatarSection('assets/images/avatarWoman2.png'),
        ]),
        fit: BoxFit.contain,
        )
    );
  }

  Checkbox checkBoxSection(int avatarId) {
    return Checkbox(
          value: avatar_check[avatarId], // NOTE: -2 because avatar list id starts in 2 (2,3,4,5)
          checkColor: Colors.white,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              
              avatar_check[avatarId] = value!;
              
              // deselect others checkBox - apply one the current checkBox
              for(var id in avatar_check.keys)
              {
                if( id != avatarId) {
                  avatar_check[id] = false;
                }
              }

              if( value ){
                selected_avatar = avatarId;
              }
            });
          });
  }
  SizedBox avatarSection(String imagePath) {
    var assetsImage = AssetImage(imagePath);

    return SizedBox(
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
    ),);
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
              hintText: "Email (Ex: exemplo@dominio.com)",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
            TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: const InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Senha",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
            ),
            const SizedBox(height: 30.0),
            TextFormField(
            controller: phoneController,
              inputFormatters: [
              MaskTextInputFormatter(mask: '(##)#####-####', filter: { "#": RegExp(r'[0-9]')}),
            ],
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white70),
            decoration: const InputDecoration(
              icon: Icon(Icons.phone, color: Colors.white70),
              hintText: "Telefone (Ex: (00)-00000-0000)",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
            ),
            const SizedBox(height: 30.0),
            TextFormField(
            controller: bdayController,
            inputFormatters: [
              MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]')}),
            ],
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: const InputDecoration(
              icon: Icon(Icons.date_range, color: Colors.white70),
              hintText: "Data de aniverssario (Ex: 00/00/0000)",
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
      margin: const EdgeInsets.only(top: 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: const Text("Realizar cadastro",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}