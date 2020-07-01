import 'dart:convert';

import 'package:bodeguinapp/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodeguinapp/main.dart';

class  LoginPage  extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  bool _isLoading = false;

  signIn(String email,  password) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map data = {
      'correo': email,
      'password': password
    };
    var jsonData = null;

    var response = await http.post("http://192.168.0.18:8080/api/usuarios/login", body: data);
    if(response.statusCode == 200){
      jsonData = json.decode(response.body);
      if(jsonData != null){
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonData['password']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      }
    }
    else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white70,
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            Image.asset(
              'assets/images/unknown.png',
              width: 400,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Usuario o correo electronico',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                ),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child:   RaisedButton(
                color: Colors.red,
                child: Text('Login', style: TextStyle(color: Colors.white70),),
                onPressed: (){
                  setState(() {
                    _isLoading = true;
                  });
                  signIn(emailController.text,passwordController.text);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
