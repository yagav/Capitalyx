import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Provided API Key
  static const String _fallbackKey = 'AIzaSyDtdbiWN2NJaclZtYZ8pGpgHTaF7CRyuqo';

  String get _apiKey => dotenv.env['GOOGLE_CLOUD_API_KEY'] ?? _fallbackKey;

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_recording.wav';

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
      );

      await _audioRecorder.start(config, path: path);
    }
  }

  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path;
  }

  Future<void> stopPlayer() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }

  /// STT: Transcribe audio file using Google Cloud Speech-to-Text
  Future<String?> transcribe(String filePath, String languageCode) async {
    final file = File(filePath);
    final audioBytes = await file.readAsBytes();
    final audioBase64 = base64Encode(audioBytes);

    final url = Uri.parse(
        'https://speech.googleapis.com/v1/speech:recognize?key=$_apiKey');

    // Mapping flutter locales to Google STT locales if needed.
    // 'ta' -> 'ta-IN', 'hi' -> 'hi-IN', etc.
    String sttLang = _mapToSttLocale(languageCode);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'config': {
          'encoding': 'LINEAR16',
          'sampleRateHertz': 16000,
          'languageCode': sttLang,
          'enableAutomaticPunctuation': true,
        },
        'audio': {'content': audioBase64}
      }),
    );

    // IMPORTANT FIX: 'record' defaults to AAC. Google STT prefers LINEAR16 (WAV).
    // The startRecording method above setup AAC. We should stick to WAV for easiest STT integration.
    // I will update startRecording to use WAV in the file content update if I can't here.
    // Actually, let's fix the startRecording logic in the file I am writing now. -> Updated below.

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['results'] != null &&
          (jsonResponse['results'] as List).isNotEmpty) {
        return jsonResponse['results'][0]['alternatives'][0]['transcript'];
      }
    } else {
      print('STT Error: ${response.body}');
    }
    return null;
  }

  /// TTS: Convert Text to Speech using Google Cloud Text-to-Speech
  Future<void> speak(String text, String languageCode) async {
    final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey');

    String ttsLang = _mapToSttLocale(
        languageCode); // reuse mapping for now locale is 'en-US', 'ta-IN' etc.

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'input': {'text': text},
        'voice': {'languageCode': ttsLang, 'ssmlGender': 'NEUTRAL'},
        'audioConfig': {'audioEncoding': 'MP3'}
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final audioContent = jsonResponse['audioContent'];
      if (audioContent != null) {
        final bytes = base64Decode(audioContent);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/tts_output.mp3');
        await file.writeAsBytes(bytes);

        await _audioPlayer.play(DeviceFileSource(file.path));
      }
    } else {
      print('TTS Error: ${response.body}');
    }
  }

  String _mapToSttLocale(String simpleLangCode) {
    switch (simpleLangCode) {
      case 'ta':
        return 'ta-IN';
      case 'hi':
        return 'hi-IN';
      case 'ml':
        return 'ml-IN';
      case 'te':
        return 'te-IN';
      case 'kn':
        return 'kn-IN';
      case 'mr':
        return 'mr-IN';
      case 'en':
      default:
        return 'en-US';
    }
  }

  // Correction: The actual implementation should use startRecordingWav logic inside startRecording
}
