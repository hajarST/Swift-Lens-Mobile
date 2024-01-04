import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanPage extends StatelessWidget {
  // Endpoint de l'API OCR
  static const String apiEndpoint = 'localhost:8080/ocr';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Appel de la méthode _onBackPressed lors du retour arrière
        _onBackPressed(context);
        return false;
      },
      child: Card(
        color: Colors.blue,
        child: InkWell(
          onTap: () {
            // Appel de la méthode _read lors du tap sur la carte
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

  // Méthode pour effectuer la reconnaissance optique de caractères (OCR)
  Future<void> _read(BuildContext context) async {
    try {
      // Capture de l'image
      String imagePath = await _captureImage();
      // Exécution de l'OCR sur l'image capturée
      String ocrResult = await _performOCR(imagePath);
      // Affichage du résultat OCR dans la console
      print('OCR Result: $ocrResult');
    } catch (e) {
      // Affichage d'une boîte de dialogue en cas d'erreur
      _showErrorDialog(context, 'Failed to recognize text. Error: $e');
    }
  }

  // Méthode pour effectuer l'OCR
  Future<String> _performOCR(String imagePath) async {
    try {
      // Appel de l'API OCR avec l'image capturée
      var response = await http.post(
        Uri.parse(apiEndpoint),
        body: {'imagePath': imagePath},
      );

      if (response.statusCode == 200) {
        // Décodage de la réponse JSON
        Map<String, dynamic> data = json.decode(response.body);
        // Récupération du texte OCR à partir des données décodées
        return data['text'];
      } else {
        // En cas d'échec de l'OCR, une exception est levée
        throw Exception(
            'Failed to perform OCR. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur lors de l'OCR, une exception est levée
      throw Exception('Failed to perform OCR. Error: $e');
    }
  }

  // Méthode pour capturer une image
  Future<String> _captureImage() async {
    // Implémentez ici la logique de capture d'image
    // Exemple avec image_picker :
    // final picker = ImagePicker();
    // var pickedFile = await picker.getImage(source: ImageSource.camera);
    // return pickedFile.path;
    return 'PATH_TO_YOUR_IMAGE';
  }

  // Méthode pour gérer le retour arrière
  void _onBackPressed(BuildContext context) {
    Navigator.pop(context);
  }

  // Méthode pour afficher une boîte de dialogue d'erreur
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
  // Lancement de l'application Flutter
  runApp(MaterialApp(
    home: Scaffold(
      body: ScanPage(),
    ),
  ));
}
