import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OpenAIService {
  final String apiKey =
      "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";

  Future<String?> getPromptFromImageFile(XFile? image) async {
    if (image == null) {
      return null;
    }

    final base64Image = base64Encode(await image.readAsBytes());

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
              "You are a prompt generator. Your task is to convert question images sent to you into plain text, based solely on the language in which the question is written. Only transcribe the question itself without adding any additional information, and please avoid using special characters. Do not include the question number."
        },
        {
          'role': 'user',
          'content': [
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
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

  Future<String?> getQuestionAnswer(String question) async {
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
              "You are a teacher. Your goal is to explain and answer the question written to you in the language in which the question is written."
        },
        {
          'role': 'user',
          'content': [
            {"type": "text", "text": question}
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
