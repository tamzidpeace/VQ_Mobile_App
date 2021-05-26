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

class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String qrCode = 'ready to scan';
  TextEditingController numberController = new TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(MyApp.title),
            centerTitle: true,
            automaticallyImplyLeading: false),
        body: Center(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: numberController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Mobile Number',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ButtonWidget(text: 'Add To Q', onClicked: () => addToQueue()),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: ButtonWidget(
                  text: 'Start QR Scan',
                  onClicked: () => scanQRCode(),
                ),
              ),
            ],
          ),
        ),
      );

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
        var previous_qr = await getStringValuesSF('qr');
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
        await addStringToSF('qr', qrCode);
        //await new Future.delayed(const Duration(seconds: 5));
      });

      if (!mounted) return;
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  Future<Map> validateQrCode(qrCode) async {
    var url = Uri.parse('https://user1.truhoist.com/api/qr-code/validate');
    var token = await getStringValuesSF('token');
    var response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: {'id': qrCode, 'employee_id': '2'},
    );
    Map data = jsonDecode(response.body);
    return data;
  }

  Future<void> addToQueue() async {
    var mobile = numberController.text;
    try {
      var url = Uri.parse('https://user1.truhoist.com/api/qr-code/scan');
      var token = await getStringValuesSF('token');
      var response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: {'employee_id': '1', 'phone': mobile},
      );
      Map data = jsonDecode(response.body);
      setState(() {
        numberController.text = '';
      });
      _showToast(context, 'Added to queue');
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
}
