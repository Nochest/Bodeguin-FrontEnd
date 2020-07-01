import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bodeguinapp/login.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bodeguin',
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}
class MainPageState extends State<MainPage> {

  Future<List<Product>> _getProducts() async {
    var data = await http.get("http://192.168.0.18:8080/api/ productos");
    var jsonData =json.decode(data.body);
  
    List<Product> products = [];
    for(var u in jsonData){
      Product product = Product(u["id"], u["nombre"], u["categoria"], u["precio"], u["stock"]);
      products.add(product);
    }

    print(products.length);
    return products;
  }
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    }
  }

  String url= 'http://192.168.0.18:8080/api/productos';
  List data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Bodeguin', style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              sharedPreferences.clear();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text('Log out'),
          ),
        ],
      ),
      body: Container(
         child: FutureBuilder(
           future: _getProducts(),
           builder: (BuildContext context, AsyncSnapshot snapshot){
             if(snapshot.data == null){
               return Container(
                 child: Center(
                   child: Text("Loading. . .") ,
                 ),
               );
             } else {
               return ListView.builder(
                 itemCount: snapshot.data.length,
                 itemBuilder: (BuildContext context, int i) {
                   return ListTile(
                     title: Text(snapshot.data[i].nombre),
                     subtitle: Text("S/. ${snapshot.data[i].precio}")
                   );
                 },
               );
             }
           },
         ),
      ),
      drawer: Drawer(),
    );
  }
}

class Product {
  final int id;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;
  
  Product(this.id, this.nombre, this.categoria, this.precio, this.stock);
}