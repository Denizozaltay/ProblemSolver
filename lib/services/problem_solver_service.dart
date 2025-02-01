import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProblemSolverService {
  final String baseUrl;

  ProblemSolverService({required this.baseUrl});

  Future<String?> getPromptFromImageFile(XFile? image) async {
    if (image == null) return null;

    final uri = Uri.parse('$baseUrl/api/openrouter/prompt');
    final request = http.MultipartRequest('POST', uri);

    final fileBytes = await image.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('image', fileBytes, filename: image.name),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Prompt Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Prompt isteğinde hata oluştu: $e');
      return null;
    }
  }

  Future<String?> getTitleFromImageFile(XFile? image) async {
    if (image == null) return null;

    final uri = Uri.parse('$baseUrl/api/openrouter/title');
    final request = http.MultipartRequest('POST', uri);

    final fileBytes = await image.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('image', fileBytes, filename: image.name),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Title Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in title request: $e');
      return null;
    }
  }

  Future<String?> getQuestionAnswer(String question) async {
    final uri = Uri.parse('$baseUrl/api/openrouter/question');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'question': question});

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Question Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in question request: $e');
      return null;
    }
  }
}
