import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIChatApi {
  final String _endpointUrl =
      'https://us-central1-ai-app-v1.cloudfunctions.net/chat';

  Future<String> sendPrompt(String prompt) async {
    final response = await http.post(
      Uri.parse(_endpointUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'prompt': prompt,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to call OpenAI Chat API: ${response.body}');
    }
  }
}
