import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/global_helper.dart';

class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String qrCode = 'ready to scan';
  TextEditingController numberController = new TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();
  bool isVisible = false;

  void isLoading() {
    setState(() {
      isVisible = !isVisible;
    });
    print(isVisible);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: getStringValuesSFNT(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            var e_name = snapshot.data['name'];
            var e_type = snapshot.data['type'];
            var can_scan_qr = true;
            if (e_type == 'scanner') can_scan_qr = false;
            return Scaffold(
              appBar: AppBar(
                title: Text(MyApp.title),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  Theme(
                    data: Theme.of(context).copyWith(
                        textTheme: TextTheme().apply(bodyColor: Colors.black),
                        dividerColor: Colors.white,
                        iconTheme: IconThemeData(color: Colors.white)),
                    child: PopupMenuButton<int>(
                      color: Colors.blue,
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 1, child: Text(e_type + ' ' + e_name)),
                        PopupMenuDivider(),
                        PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text("Logout")
                              ],
                            )),
                      ],
                      onSelected: (item) => selectedItemOpr(item),
                    ),
                  ),
                ],
              ),
              body: Center(
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
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: numberController,
                            obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Mobile Number',
                            ),
                            onSubmitted: (numberController) {
                              addToQueue();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ButtonWidget(
                            text: 'Add To Q', onClicked: () => addToQueue()),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Text(
                        'Scan Result',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '$qrCode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 72),
                    Visibility(
                      visible: can_scan_qr,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
                        child: ButtonWidget(
                          text: 'Start QR Scan',
                          // onClicked: () => scanQRCode(),
                          onClicked: () =>
                              Navigator.pushNamed(context, '/qr-scan'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });

    //return
  }

  Future<void> scanQRCode() async {
    try {
      //continuous scan
      var qrCode = '';
      FlutterBarcodeScanner.getBarcodeStreamReceiver(
              "#ff6666", "Cancel", false, ScanMode.QR)
          .listen((barcode) async {
        qrCode = barcode;
        var data = await validateQrCode(qrCode);
        print(data);

        //check previous qr
        var previous_qr = await GlobalHelper.getStringValuesSF('qr');
        if (previous_qr == qrCode) {
          print('same qr');
          return;
        } else {
          print('new qr');
        }

        setState(() {
          if (qrCode != '-1')
            this.qrCode =
                'QR: ' + qrCode + '\n\n' + 'Response: ' + data['message'];
        });

        if (data['message'] == "this qr code doesn't have access now" &&
            qrCode != '-1') {
          AssetsAudioPlayer.newPlayer().open(
            Audio("audio/not_valid.mp3"),
            autoStart: true,
            showNotification: true,
          );
        } else if (data['message'] != "this qr code doesn't have access now" &&
            qrCode != '-1' &&
            data['message'] != "none is in the queue") {
          AssetsAudioPlayer.newPlayer().open(
            Audio("audio/valid.mp3"),
            autoStart: true,
            showNotification: true,
          );
        } else if (data['message'] == "none is in the queue" &&
            qrCode != '-1') {
          AssetsAudioPlayer.newPlayer().open(
            Audio("audio/not_valid.mp3"),
            autoStart: true,
            showNotification: true,
          );
        } else if (qrCode == '-1') {
          AssetsAudioPlayer.newPlayer().open(
            Audio("audio/paused.mp3"),
            autoStart: true,
            showNotification: true,
          );
        }
        await GlobalHelper.addStringToSF('qr', qrCode);
        //await new Future.delayed(const Duration(seconds: 5));
      });

      if (!mounted) return;
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  Future<Map> validateQrCode(qrCode) async {
    var subdomain = await GlobalHelper.getStringValuesSF('subdomain');
    var employee_id = await getIntValuesSF('employee_id');
    var url = Uri.parse('https://' + subdomain + '/api/qr-code/validate');
    var token = await GlobalHelper.getStringValuesSF('token');
    var response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: {'id': qrCode, 'employee_id': employee_id.toString()},
    );
    Map data = jsonDecode(response.body);
    return data;
  }

  Future<void> addToQueue() async {
    var mobile = numberController.text;
    final String subdomain = await GlobalHelper.getStringValuesSF('subdomain');
    final int employee_id = await getIntValuesSF('employee_id');
    try {
      isLoading();
      final Uri _url = Uri.parse('https://' + subdomain + '/api/qr-code/scan');
      final String token = await GlobalHelper.getStringValuesSF('token');
      var response = await http.post(
        _url,
        headers: {'Authorization': 'Bearer $token'},
        body: {'employee_id': employee_id.toString(), 'phone': mobile},
      );
      Map data = jsonDecode(response.body);
      setState(() {
        numberController.text = '';
      });
      isLoading();
      _showToast(context, 'Added to queue');
    } catch (e) {
      isLoading();
      _showToast(context, 'An error occurred!');
      print(e);
    }
  }

  void selectedItemOpr(item) async {
    if (item == 1) {
      print('settings');
    } else if (item == 2) {
      print('logout');
      await logout();
    }
  }

  Future<void> logout() async {
    var subdomain = await GlobalHelper.getStringValuesSF('subdomain');
    try {
      isLoading();
      final Uri _url = Uri.parse('https://' + subdomain + '/api/auth/logout');
      final String token = await GlobalHelper.getStringValuesSF('token');
      var response = await http.post(
        _url,
        headers: {'Authorization': 'Bearer $token'},
      );
      Map data = jsonDecode(response.body);
      print(data);
      //_showToast(context, 'User Logged Out');
      GlobalHelper.addStringToSF('token', '');
      isLoading();
      Navigator.pushReplacementNamed(context, '/subdomain');
      _showToast(context, 'logged out!');
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

  play() async {
    int result = await audioPlayer.play(
        'https://transom.org/wp-content/uploads/2004/03/200206.hodgman8.mp3');
    if (result == 1) {
      // success
      print('audio ok');
    } else {
      print('aduio not ok');
    }
  }

  // //add value to sf
  // addStringToSF(key, value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString(key, value);
  // }

  // //get value from sf
  // Future<String> getStringValuesSF(key) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //Return String
  //   String stringValue = prefs.getString(key);
  //   return stringValue;
  // }

  Future<Map> getStringValuesSFNT() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String name = prefs.getString('name');
    String type = prefs.getString('type');
    Map data = {'name': name, 'type': type};
    return data;
  }

  getIntValuesSF(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    var stringValue = prefs.getInt(key);
    return stringValue;
  }
}
