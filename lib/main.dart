import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_example/page/qr_scan_page.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Virtual Queue';
//  static final String res = _read();
  static final String initial_route = '/';

  @override
  Widget build(BuildContext context) => MaterialApp(
        initialRoute: '/home',
        routes: {
          '/home': (context) => QRScanPage(),
        },
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: MainPage(
          title: title,
        ),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    @required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /* @override
  void initState() {
    super.initState();
    var res = _read();
    print(res);
    */ /*if (res == '1') {
      Timer.run(() {
        Navigator.of(context).pushNamed('/home');
      });
      print(res);
    } else {
      print(res);
    }*/ /*
    //YOUR CHANGE PAGE METHOD HERE
  }*/

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(10, 100, 10, 0),
          child: Center(
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'VQ Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                        decoration: TextDecoration.underline,
                      ),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ButtonWidget(
                        text: 'Login',
                        onClicked: () => login(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )));

  /*
  * employee login
  * */

  Future<void> login() async {
    var email = nameController.text;
    var password = passwordController.text;

    try {
      var url = Uri.parse('https://user1.truhoist.com/api/employee/login');

      var response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      Map data = jsonDecode(response.body);
      print(data);
      if (data['message'] == 'employee successfully logged in!') {
        // _save(data['token']);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showToast(context, data['message']);
      }
    } catch (e) {
      _showToast(context, 'An error occurred!');
    }
  }

  void _showToast(BuildContext context, message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

/*_save(token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('token', '1');
  //print('saved');
}

_read() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String token = prefs.getString('token');
  //print('read');
  return token;
}*/
