import 'dart:convert';
import 'package:http/http.dart' as http; 

Future<Map<String, dynamic>>? fetchMetadata(String url) async {
  final response = await http.get(Uri.parse(
    'https://api.linkpreview.net/?key=MYUSER_KEY&q=$url', 
  ));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Failed to load metadata'); 
    return {'none': 0};
  }
}

// NOT IN USE CURRENTLY 