import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_code_scanner_example/widget/button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';

class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String qrCode = 'ready to scan';
  TextEditingController numberController = new TextEditingController();

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
                  text: 'Start QR scan',
                  onClicked: () => scanQRCode(),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      setState(() async {
        //fetching api data
        // var url = Uri.parse('https://user1.truhoist.com/api/auth/logout');
        // var url = Uri.parse('https://user1.truhoist.com/api/employee/login');

        var url = Uri.parse(
            'https://user1.truhoist.com/api/qr-code/validate?id=39dsdewr&employee_id=2');
        var token =
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNDFjOWVkNTIzNDJiYzNlOTM2MjVlNGRjNzQ0MzRjMGFlZmRhMTEwYzU3NTgyNTM2OWY0NGRiNmE3MThjZmU0ZTZiMTY0ZmRiNmYwNTBiMDkiLCJpYXQiOjE2MjE2NzI4MzcsIm5iZiI6MTYyMTY3MjgzNywiZXhwIjoxNjUzMjA4ODM3LCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.kav4JgtiMfXPnR2x_XuMk8bfXW8ySEM-m0w3MWof5Get2_YQ2CjUfy_mj5eiEWlEwn3kySBDL0oF-Tv1JoNVOJ34CnViN-zEFQIETxY2qluA3CDrHJRpElJeeYFcRwgw7xvCyiLTHf4cVBtWzZvyWipHII6A6vzFU7lt-GTHBKvR9sKGhGQIntCAEkm3yNjeHwRYcdcolrfzkyFiqDnjlegmBCEFXovQdIBml2rq-13j6sPKpQvC1bQoVcU-EdB0rUmVy_oWRkGLClYwBLNmkb1SHFFRiLCc4FNpkvD2dynsPt70n2PT5Nxfp9wXSGZW7NSqsC0gOiQal-edjQSt4VNs91HAGMB-C2jlZt0HPD22EuRFGuM4hxuOzRpGV55Bqkd0nm4Ep6h9rpKA-u3P3uFGhy7zdm6lZuu-ZV_G2BeSOBFa_Gv7AjkCBREL2SC8n5qsSzhJDGZTRIoNEVpvUSOKyNBE2jzUhJm3wPAY1T7M0-Wyu2Ce953z5DnobovGy8PqROeMPx7ek0EFrTil4b2SfQwtwWFkcB7bD4V_7z3u-C9ldcMS4OyTWvXkp-8fiXpcw5G732YNBN-z3mTbNWHkMBm8-FJ-_SRkPd6c981idladHvHF5-InfvH96sNVuzONc8mV6ICpKOkHgTKfhYV9nPEuTn3UPyI6TWfW3rc';

        var response = await http.post(
          url,
          headers: {'Authorization': 'Bearer $token'},
          body: {'id': qrCode, 'employee_id': '2'},
        );
        Map data = jsonDecode(response.body);
        print(data);
        _showToast(context, data['message']);
        setState(() {
          this.qrCode =
              'QR: ' + qrCode + '\n\n' + 'Response: ' + data['message'];
        });
        Future.delayed(const Duration(seconds: 5), () => scanQRCode());
        //scanQRCode();
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  Future<void> addToQueue() async {
    var mobile = numberController.text;
    try {
      var url = Uri.parse('https://user1.truhoist.com/api/qr-code/scan');
      var token =
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNDFjOWVkNTIzNDJiYzNlOTM2MjVlNGRjNzQ0MzRjMGFlZmRhMTEwYzU3NTgyNTM2OWY0NGRiNmE3MThjZmU0ZTZiMTY0ZmRiNmYwNTBiMDkiLCJpYXQiOjE2MjE2NzI4MzcsIm5iZiI6MTYyMTY3MjgzNywiZXhwIjoxNjUzMjA4ODM3LCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.kav4JgtiMfXPnR2x_XuMk8bfXW8ySEM-m0w3MWof5Get2_YQ2CjUfy_mj5eiEWlEwn3kySBDL0oF-Tv1JoNVOJ34CnViN-zEFQIETxY2qluA3CDrHJRpElJeeYFcRwgw7xvCyiLTHf4cVBtWzZvyWipHII6A6vzFU7lt-GTHBKvR9sKGhGQIntCAEkm3yNjeHwRYcdcolrfzkyFiqDnjlegmBCEFXovQdIBml2rq-13j6sPKpQvC1bQoVcU-EdB0rUmVy_oWRkGLClYwBLNmkb1SHFFRiLCc4FNpkvD2dynsPt70n2PT5Nxfp9wXSGZW7NSqsC0gOiQal-edjQSt4VNs91HAGMB-C2jlZt0HPD22EuRFGuM4hxuOzRpGV55Bqkd0nm4Ep6h9rpKA-u3P3uFGhy7zdm6lZuu-ZV_G2BeSOBFa_Gv7AjkCBREL2SC8n5qsSzhJDGZTRIoNEVpvUSOKyNBE2jzUhJm3wPAY1T7M0-Wyu2Ce953z5DnobovGy8PqROeMPx7ek0EFrTil4b2SfQwtwWFkcB7bD4V_7z3u-C9ldcMS4OyTWvXkp-8fiXpcw5G732YNBN-z3mTbNWHkMBm8-FJ-_SRkPd6c981idladHvHF5-InfvH96sNVuzONc8mV6ICpKOkHgTKfhYV9nPEuTn3UPyI6TWfW3rc';

      var response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: {'employee_id': '1', 'phone': mobile},
      );
      Map data = jsonDecode(response.body);
      print(data);
      setState(() {
        numberController.text = '';
        print(123);
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
}
