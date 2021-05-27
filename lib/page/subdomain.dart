import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Subdomain extends StatefulWidget {
  const Subdomain({Key key}) : super(key: key);

  @override
  _SubdomainState createState() => _SubdomainState();
}

class _SubdomainState extends State<Subdomain> {
  TextEditingController subdomainController = TextEditingController();
  bool isVisible = false;

  void isLoading() {
    setState(() {
      isVisible = !isVisible;
    });
    print(isVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Virtual Queue'),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
                        'Enter Your Subdomain',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30,
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: subdomainController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Subdomain',
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
                          text: 'Check',
                          onClicked: () => checkSubdomain(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  void checkSubdomain() async {
    try {
      isLoading();
      var subdomain = subdomainController.text;
      var url =
          Uri.parse('https://user1.truhoist.com/api/employee/get-subdomain');
      var response = await http.post(
        url,
        body: {'subdomain': subdomain},
      );
      Map data = jsonDecode(response.body);

      if (data['success'] == 'true') {
        _showToast(context, 'subdomain found!');
        addStringToSF('subdomain', data['data']);
        print(data['data']);
        isLoading();
        Navigator.pushNamed(context, '/');
      } else {
        isLoading();
        _showToast(context, 'sorry, subdomain not found!');
      }
    } catch (e) {
      print(e);
      isLoading();
      _showToast(context, 'something went wrong!');
    }
  }

  //shared preference
  addStringToSF(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  getStringValuesSF(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString(key);
    return stringValue;
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
