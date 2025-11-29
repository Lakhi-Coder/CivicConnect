import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:assets/services/AI_recom_services.dart';
import 'package:assets/services/firestore_services.dart';
import 'package:assets/services/news_api_services.dart';

class AINewsService {
  final AIRecommendationService _aiService = AIRecommendationService();
  final FirestoreService _firestoreService = FirestoreService();
  final NewsService _newsService = NewsService();

  Future<List<dynamic>> getAIPersonalizedNews() async {
    print("=== AI PERSONALIZED NEWS FETCHING STARTED ===");
    
    final userWeights = await _firestoreService.getUserTopicWeights();
    final topCategories = await _firestoreService.getUserTopCategories(3);
    
    print("User weights: $userWeights");
    print("Top categories: $topCategories");

    final urls = await _aiService.generateNewsAPIUrls(userWeights, topCategories);
    
    List<dynamic> allArticles = []; 
    
    for (String url in urls) {
      try {
        print("Fetching from: $url");
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final articles = jsonData['articles'] as List;
          
          final newsArticles = articles.map((article) => NewsArticle.fromJson(article)).toList();
          allArticles.addAll(newsArticles);
          
          print("Fetched ${newsArticles.length} articles from this URL");
        } else {
          print("Failed to fetch from URL: ${response.statusCode}");
        }
      } catch (e) {
        print("Error fetching from URL $url: $e");
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }

    allArticles = _removeDuplicates(allArticles);
    allArticles = allArticles.where((article) => 
        article.title.isNotEmpty && 
        article.url.isNotEmpty &&
        article.title != '[Removed]').toList();

    print("=== AI PERSONALIZED NEWS COMPLETE: ${allArticles.length} articles ===");
    return allArticles;
  }

  List<dynamic> _removeDuplicates(List<dynamic> articles) {
    final seenUrls = <String>{};
    return articles.where((article) {
      if (article.url == null || article.url.isEmpty) return false;
      if (seenUrls.contains(article.url)) return false;
      seenUrls.add(article.url);
      return true;
    }).toList();
  }

  Future<List<dynamic>> getFallbackPersonalizedNews() async {
    final topCategories = await _firestoreService.getUserTopCategories(2);
    
    if (topCategories.isNotEmpty) {
      final categoryNews = await _newsService.fetchMultipleCategories(topCategories);
      List<dynamic> allArticles = [];
      categoryNews.forEach((category, articles) {
        allArticles.addAll(articles);
      });
      return _removeDuplicates(allArticles);
    } else {
      return await _newsService.fetchNews();
    }
  }
}