import 'dart:convert';

import 'package:assets/config/config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIRecommendationService {
  final String apiKey = ApiConfig.geminiApiKey; 
  late final GenerativeModel _model;

  AIRecommendationService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  String _formatAIResponse(String response) {
    String formatted = response;
    
    Map<String, String> encodingFixes = {
      'â€¢': '•',      // Bullet point
      'â€"': '—',      // Em dash
      'â€"': '–',      // En dash 
      'â€™': "'",     // Apostrophe
      'â€œ': '"',      // Left double quote
      'â€': '"',       // Right double quote
      'â€˜': "'",      // Single quote
      'Ã©': 'é',       // Accented e
      'Ã¨': 'è',       // Accented e
      'Ã¢': 'â',       // Accented a
      'Ã®': 'î',       // Accented i
      'Ã´': 'ô',       // Accented o
      'Ã¹': 'ù',       // Accented u
      'Ã§': 'ç',       // Cedilla
      'Â': '',         // Remove unwanted Â
    };
    
    encodingFixes.forEach((key, value) {
      formatted = formatted.replaceAll(key, value);
    });
    
    formatted = formatted
      .replaceAll('```', '')           // Remove code blocks
      .replaceAll('`', '')             // Remove inline code
      .replaceAll('**', '')            // Remove bold
      .replaceAll('*', '•')            // Convert asterisks to bullets
      .replaceAll('#', '')             // Remove headers
      .trim();
    
    return formatted;
  }

  Future<String> generateUserRecommendations(article) async {
    String prompt = """
    Classify this news into topics from the list:
    [politics, health, science, technology, sports, entertainment]
    Some may sound a little bit on a different topic leading to skewed data. 
    Please think carefully on the data given. 
    NEVER INCLUDE: ```json in your string

    Return ONLY valid JSON with no backticks:
    {
      "categories": [],  
      "weights": {}
    }

    Example Response: 
    {
    "categories": ["[TOPIC]"],  
    "weights": {
      "politics": [SCALE FROM 0-1],
      "health": [SCALE FROM 0-1],
      "science": [SCALE FROM 0-1],
      "technology": [SCALE FROM 0-1],
      "sports": [SCALE FROM 0-1],
      "entertainment": [SCALE FROM 0-1]
      }
    }

    News:
    "${article.title}. ${article.description}. ${article.url}" 
    """; 
    print("ARTICLE DESCRIPTION: " + article.description); 
    final response = await _model.generateContent([Content.text(prompt)]);  
    print('GEMINI RESPONSE: ${response.text}'); 
    return response.text ?? 'No recommendations found';
  }

  Future<String> replyToUser(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]); 
    print('GEMINI RESPONSE: ${response.text}'); 
    return response.text ?? 'No recommendations found';
  }

  Future<List<String>> generateSearchQueries(Map<String, double> userWeights, List<String> topCategories) async {
    String prompt = """
    Based on the user's topic preferences, generate 3-5 specific search queries for news articles.
    
    User Topic Weights:
    ${userWeights.entries.map((e) => "${e.key}: ${(e.value * 100).toStringAsFixed(0)}%").join('\n')}
    
    Top Categories: ${topCategories.join(', ')}
    
    Generate specific, current, and relevant search queries that would fetch interesting news articles matching these interests.
    Return ONLY a JSON array of strings, no other text or formatting.
    
    Example: ["US politics latest developments", "technology innovation 2024", "healthcare policy updates"]
    
    Requirements:
    - Make queries specific and timely
    - Mix broad and specific topics
    - Include current events when relevant
    - Return 3-5 queries maximum
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? '[]';
      
      responseText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> queries = jsonDecode(responseText);
      return queries.cast<String>();
    } catch (e) {
      print('Error generating search queries: $e');
      return topCategories.map((category) => "latest $category news").toList();
    }
  }

  Future<List<String>> generateNewsAPIUrls(Map<String, double> userWeights, List<String> topCategories) async {
    final queries = await generateSearchQueries(userWeights, topCategories);
    
    final functionUrl = 'https://us-central1-civicconnect-4012b.cloudfunctions.net/newsProxy';
    List<String> urls = []; 
    
    for (String query in queries) {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$functionUrl?query=$encodedQuery&pageSize=20';
      urls.add(url);
    }

    for (String category in topCategories.take(2)) {
      final url = '$functionUrl?category=$category&country=us&pageSize=20';
      urls.add(url);
    }
    
    print("Generated Firebase Function URLs: $urls");
    return urls;
  }

  Future<String> generatePoliticalEventsSummary() async {
    String prompt = """
    Provide a concise summary of the most significant political events that happened in the US in the last 7 days.
    
    Focus on:
    - Major policy announcements
    - Important legislative developments
    - Key political decisions
    - Significant international relations events
    - Major elections or political appointments
    
    Format your response as a well-structured summary with clear sections.
    Keep it informative but concise - maximum 300 words.
    Focus on factual information and avoid speculation.
    
    Return the summary in clean, readable text without markdown formatting.
    Use bullet points with • symbols for clarity.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? 'No political events summary available.'; 

      responseText = _formatAIResponse(responseText);
      return responseText;
    } catch (e) {
      print('Error generating political events summary: $e');
      return 'Unable to fetch political events summary at this time.';
    }
  }
  Future<String> chatWithArticleContext({
    required String userMessage,
    required String articleTitle,
    required String articleDescription,
    required String articleUrl,
  }) async {
    String prompt = """
    You are a political news assistant. The user is reading a news article and has asked you a question about it.

    ARTICLE CONTEXT:
    Title: "$articleTitle"
    Description: "$articleDescription"
    URL: $articleUrl

    USER'S QUESTION: "$userMessage"

    Please provide a helpful, informative response that:
    1. Directly addresses the user's question
    2. References the article content when relevant
    3. Provides additional context or background information
    4. Stays factual and objective
    5. Is concise but comprehensive (2-4 paragraphs maximum)

    If the user's question isn't directly related to the article, still provide a helpful political/news-related response.

    Format your response in clear, readable paragraphs without markdown.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? 'I apologize, but I encountered an error. Please try again.';
      
      responseText = _formatAIResponse(responseText);
      return responseText;
    } catch (e) {
      print('Error in chatWithArticleContext: $e');
      return 'I apologize, but I encountered an error processing your request. Please try again.';
    }
  }

  Future<String> generalPoliticalChat(String userMessage) async {
    String prompt = """
    You are a political news assistant. The user has asked: "$userMessage"

    Please provide a helpful, informative response about political topics, current events, or news-related questions.

    Requirements:
    - Stay factual and objective
    - Provide relevant context
    - Be concise but comprehensive
    - Focus on US politics and current events
    - If discussing specific policies or events, mention their current status

    Format your response in clear, readable paragraphs without markdown.
    Use bullet points with • symbols when listing items for better readability.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String responseText = response.text ?? 'I apologize, but I encountered an error. Please try again.';
      
      responseText = _formatAIResponse(responseText);
      return responseText;
    } catch (e) {
      print('Error in generalPoliticalChat: $e');
      return 'I apologize, but I encountered an error processing your request. Please try again.';
    }
  }
}