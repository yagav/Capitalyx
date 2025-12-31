import 'dart:convert';
import 'package:http/http.dart' as http;

class VoiceService {
  final String apiKey; // Would come from secure storage or constants

  VoiceService({this.apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY'});

  /// Sends text to Google Translate API.
  /// This is the "Backend hook" preparation.
  Future<String> sendTextToTranslate(String text,
      {String targetLang = 'en'}) async {
    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$apiKey');

    try {
      final response = await http.post(
        url,
        body: {
          'q': text,
          'target': targetLang,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // data['data']['translations'][0]['translatedText']
        return data['data']['translations'][0]['translatedText'];
      } else {
        throw Exception('Failed to translate: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
