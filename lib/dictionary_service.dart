import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  Future<Map<String, dynamic>?> fetchWord(String word) async {
    final url =
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data[0];
    } else {
      return null;
    }
  }
}
