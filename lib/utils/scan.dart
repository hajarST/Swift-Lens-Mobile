import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanPage extends StatelessWidget {
  static const String apiEndpoint = 'localhost:8080/ocr';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackPressed(context);
        return false;
      },
      child: Card(
        color: Colors.blue,
        child: InkWell(
          onTap: () {
            _read(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
            ),
            height: 40,
            width: 400,
            child: Center(
              child: Text(
                "Scan Using Camera",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _read(BuildContext context) async {
    try {
      String imagePath = await _captureImage();
      String ocrResult = await _performOCR(imagePath);
      print('OCR Result: $ocrResult');
    } catch (e) {
      _showErrorDialog(context, 'Failed to recognize text. Error: $e');
    }
  }

  Future<String> _performOCR(String imagePath) async {
    try {
      var response = await http.post(
        Uri.parse(apiEndpoint),
        body: {'imagePath': imagePath},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['text'];
      } else {
        throw Exception('Failed to perform OCR. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to perform OCR. Error: $e');
    }
  }

  Future<String> _captureImage() async {
    
    return 'PATH_TO_YOUR_IMAGE';
  }

  void _onBackPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: ScanPage(),
    ),
  ));
}
