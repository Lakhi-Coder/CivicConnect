import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as html; 
import 'dart:convert'; 

class WebWindowService {
  static void openAIChatWindow({
    required String articleTitle,
    required String articleDescription,
    required String articleUrl,
  }) {
    if (!kIsWeb) return;

    
    final articleData = {
      'title': articleTitle,
      'description': articleDescription, 
      'url': articleUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    html.window.localStorage.setItem('current_article', json.encode(articleData)); 
    print('Saved article data to localStorage');
    print('Title: $articleTitle');
    
    final chatWindow = html.window.open('/', 'CivicConnectAI', 'width=500,height=700,left=200,top=100'); 
    
    if (chatWindow == null) {
      print('Popup blocked. Please allow popups for this site.');
    } else {
      print('Chat window opened successfully');
    }
  }
}