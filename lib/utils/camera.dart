import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  static String apiEndpoint = 'https://localhost:8080/ocr';

  Future<void> _read() async {
    try {
      // Capture image using camera
      String imagePath = await captureImage();

      String ocrResult = await performOCR(imagePath);

      // Display or process OCR result as needed
      print('OCR Result: $ocrResult');
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to recognize text. Error: $e'),
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

    if (!mounted) return;
    setState(() {});
  }

  Future<String> performOCR(String imagePath) async {
    try {
      var response = await http.post(
        Uri.parse(apiEndpoint),
        body: {'imagePath': imagePath},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        // Assuming your API returns the OCR result as 'text'
        return data['text'];
      } else {
        throw Exception(
            'Failed to perform OCR. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to perform OCR. Error: $e');
    }
  }

  Future<String> captureImage() async {
    final picker = ImagePicker();
    var pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      throw Exception('Image capture canceled');
    }
  }

  void backpressed(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backpressed(context);
        return false;
      },
      child: Card(
        color: Colors.grey.shade700,
        child: InkWell(
          onTap: () {
            _read();
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
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: ScanPage(),
    ),
  ));
}