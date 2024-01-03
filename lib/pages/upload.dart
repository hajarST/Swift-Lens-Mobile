import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  XFile? _imageFile;
  dynamic? _pickerror;
  String? extracted = 'Recognised Extracted Text Will Appear Here';
  final picker = ImagePicker();

  static String apiEndpoint = 'YOUR_OCR_API_ENDPOINT';

  Future<Null> _read() async {
    try {
      if (_imageFile != null) {
        EasyLoading.show(status: 'loading...');
        String imagePath = _imageFile!.path;
        String ocrResult = await performOCR(imagePath);

        // Assuming your API returns the OCR result in a specific format
        Map<String, dynamic> resultData = json.decode(ocrResult);
        String formattedResult = """
First name: ${resultData['firstName']}
Last Name: ${resultData['lastName']}
Date birth: ${resultData['dateOfBirth']}
City birth: ${resultData['cityOfBirth']}
الاسم الشخصي: ${resultData['personalName']}
اسم العائلة: ${resultData['familyName']}
مكان الولادة: ${resultData['birthPlace']}

""";

        setState(() {
          extracted = formattedResult;
        });
      }
    } catch (e) {
      setState(() {
        extracted = 'Failed to recognize text. Error: $e';
      });
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<String> performOCR(String imagePath) async {
    try {
      var response = await http.post(
        apiEndpoint as Uri,
        body: {'imagePath': imagePath},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Failed to perform OCR. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to perform OCR. Error: $e');
    }
  }

  _imgFromGallery() async {
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
        _read();
      } else {
        setState(() {
          _pickerror = 'Image selection canceled';
        });
      }
    } catch (e) {
      setState(() {
        _pickerror = e.toString();
      });
    }
  }

  Widget preview() {
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path));
    } else if (_pickerror != null) {
      return Text(
        'Error: $_pickerror',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.\nUpload an Image And Wait A few Seconds',
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "OCR App",
      color: Colors.blue,
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Extract text from image",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        body: Material(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Container(
                          decoration: BoxDecoration(color: Colors.blue),
                          child: Center(child: preview()),
                          height: 250,
                          width: 650,
                        ),
                      ),
                      SizedBox(height: 8),
                      Hero(
                        tag: Key("upload"),
                        child: Card(
                          color: Colors.blue,
                          child: InkWell(
                            onTap: () {
                              _imgFromGallery();
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
                                  "Upload Image",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Container(
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SelectableText(
                                extracted.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          width: 500,
          height: 10,
          color: Colors.blue,
        ),
      ),
    );
  }
}
