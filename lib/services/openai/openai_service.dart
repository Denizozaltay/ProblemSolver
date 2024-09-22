import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey =
      "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";

  Future<String?> getPromptFromImage(String imageUrl) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          "role": "system",
          "content":
              "You are a prompt generator. Your task is to convert question images sent to you into plain text, based solely on the language in which the question is written. Only transcribe the question itself without adding any additional information, and please avoid using special characters."
        },
        {
          'role': 'user',
          'content': [
            {
              "type": "image_url",
              "image_url": {"url": imageUrl}
            }
          ]
        }
      ],
      'temperature': 0.0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = responseData['choices'][0]['message']['content'];
        print('Response from GPT-4o-mini: $reply');
        return reply;
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to connect to OpenAI API: $e');
      return null;
    }
  }
}
