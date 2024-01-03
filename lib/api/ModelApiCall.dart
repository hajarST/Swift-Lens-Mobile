import 'package:http/http.dart' as http;

Future<String> performOCR(String imagePath) async {
  var response = await http.post(
    'localhost:8080/ocr' as Uri,
    body: {'imagePath': imagePath},
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to perform OCR');
  }
}
