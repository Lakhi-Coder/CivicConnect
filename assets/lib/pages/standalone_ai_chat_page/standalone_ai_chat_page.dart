import 'dart:math';

import 'package:assets/services/news_api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:assets/entities/widgets/AI_chat_panel/ai_chat_interface.dart';
import 'package:web/web.dart' as html;

class AIChatPage extends StatelessWidget {
  final String articleTitle;
  final String articleDescription;
  final String articleUrl;

  const AIChatPage({
    super.key,
    required this.articleTitle,
    required this.articleDescription,
    required this.articleUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AIChatPanel(
        currentArticle: NewsArticle(
          title: articleTitle,
          description: articleDescription,
          url: articleUrl,
          imageUrl: '',
          source: 'Current Reading', 
        ),
        isMobile: false,
        isStandaloneMode: true,
        onClose: () {
          if (kIsWeb) {
            html.window.close();
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}