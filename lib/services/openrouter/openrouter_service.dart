import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OpenRouterService {
  final String apiKey =
      "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";

  Future<String?> getPromptFromImageFile(XFile? image) async {
    if (image == null) {
      return null;
    }

    final base64Image = base64Encode(await image.readAsBytes());

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'openai/gpt-4o-mini',
      'messages': [
        {
          "role": "system",
          "content":
              "You are a prompt generator tasked with converting question images into plain text, preserving the original language of each question. Transcribe only the question content without adding any additional information, avoiding the use of special characters, and excluding question numbers. If you encounter a visual question, extract the textual content from the image and include it in the transcription. If the image contains non-textual information, provide a clear and concise description of the visual elements as part of the question."
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
      print('Failed to connect to OpenRouter API: $e');
      return null;
    }
  }

  Future<String?> getTitleFromImageFile(XFile? image) async {
    if (image == null) {
      return null;
    }

    final base64Image = base64Encode(await image.readAsBytes());

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'openai/gpt-4o-mini',
      'messages': [
        {
          "role": "system",
          "content":
              "You are the title generator. Your task is to write a short and concise title that summarizes the question sent to you. This title should be in the same language as the question."
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
      print('Failed to connect to OpenRouter API: $e');
      return null;
    }
  }

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
