import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_example/page/loading.dart';
import 'package:qr_code_scanner_example/page/qr_scan_page.dart';
import 'package:qr_code_scanner_example/page/subdomain.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var res = await getStringValuesSF('token');
  var subdomain = await getStringValuesSF('subdomain');
  print(res);
  var _route;
  if (res == null || res == '')
    _route = '/subdomain';
  else
    _route = '/home';
  runApp(MyApp(_route, subdomain));
}

class MyApp extends StatelessWidget {
  static final String title = 'Virtual Queue';

  var data;
  var subdomain;
  MyApp(res, subdomain) {
    this.data = res;
    this.subdomain = subdomain;
  }

  //var String initial_route = data;

  @override
  Widget build(BuildContext context) => MaterialApp(
        // initialRoute: data,
        initialRoute: '/loading',
        routes: {
          '/home': (context) => QRScanPage(),
          '/subdomain': (context) => Subdomain(),
          '/loading': (context) => Loading(),
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
  bool isVisible = false;

  void isLoading() {
    setState(() {
      isVisible = !isVisible;
    });
    print(isVisible);
  }

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
                Visibility(
                  visible: isVisible,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    height: 1.0,
                    width: 1.0,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey[900],
                    ),
                  ),
                ),
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
    var subdomain = await getStringValuesSF('subdomain');
    //print(subdomain);
    try {
      isLoading();
      var url = Uri.parse('https://' + subdomain + '/api/employee/login');
      //print(url);

      var response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      Map data = jsonDecode(response.body);
      print(data['data']['id']);
      if (data['message'] == 'employee successfully logged in!') {
        isLoading();
        //saving token in sf
        await addStringToSF('token', data['token']);
        await addIntToSF('employee_id', data['data']['id']);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        isLoading();
        _showToast(context, data['message']);
      }
    } catch (e) {
      isLoading();
      _showToast(context, 'An error occurred!');
      print(e);
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

//add value to sf
addStringToSF(key, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

//get value from sf
getStringValuesSF(key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String stringValue = prefs.getString(key);
  return stringValue;
}

addIntToSF(key, value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}
