import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenrouterService {
  final String apiKey =
      "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";

  Future<String?> getQuestionAnswer(String question) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'openai/o1-mini',
      'messages': [
        {
          "role": "system",
          "content":
              "You are a teacher. Your goal is to explain and answer the question written to you in the language in which the question is written."
        },
        {'role': 'user', 'content': question}
      ],
      'temperature': 0.0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = responseData['choices'][0]['message']['content'];
        print('Response from openai/o1-mini: $reply');
        return reply;
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to connect to OpenRouter API: $e');
      return null;
    }
  }
}
