import 'dart:convert';
import 'dart:math';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/AI_chat_panel/ai_chat_interface.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/services/AI_recom_services.dart';
import 'package:assets/services/firestore_services.dart';
import 'package:assets/services/webview_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart'; 
// SOME FUNCTIONS AREN'T USED ALL THE TIME, BUT KEEP FOR FUTURE USE 

double cardWidth = 300; 
double cardHeight = cardWidth * 0.56;  

class NewsService {
  final String functionUrl = 'https://us-central1-civicconnect-4012b.cloudfunctions.net/newsProxy';
  String category = 'politics';

  Future<void> testNewsAPI() async {
    print('Testing Firebase Function connection...');
    
    final testUrls = [
      '$functionUrl?category=politics&country=us',
      '$functionUrl?category=general&country=us',
      '$functionUrl?query=technology',
    ];

    for (int i = 0; i < testUrls.length; i++) {
      try {
        final url = Uri.parse(testUrls[i]);
        print('Testing URL ${i + 1}: $url');
        
        final response = await http.get(url);
        print('Response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Total results: ${data['totalResults']}');
          print('Articles found: ${(data['articles'] as List).length}');
          
          if ((data['articles'] as List).isNotEmpty) {
            final firstArticle = data['articles'][0];
            print('Sample article title: ${firstArticle['title']}');
          }
        } else {
          print('Error response: ${response.body}');
        }
      } catch (e) {
        print('Exception: $e');
      }
      print('---');
    }
  }

  Future<String> setCategory(String newCategory) {
    category = newCategory; 
    return Future.value(category);
  }

  Future<NewsArticle?> fetchSpecificArticle(String url, String title) async {
    try {
      final encodedTitle = Uri.encodeComponent(title); 
      final searchUrl = Uri.parse('$functionUrl?query=$encodedTitle');

      final response = await http.get(searchUrl);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final articles = jsonData['articles'] as List;

        for (var articleJson in articles) {
          final article = NewsArticle.fromJson(articleJson); 
          if (article.url.trim() == url.trim()) {
            return article; 
          }
        }

        for (var articleJson in articles) {
          final article = NewsArticle.fromJson(articleJson);
          if (article.title.trim().toLowerCase() == title.trim().toLowerCase()) {
            return article; 
          }
        }

        print("No exact match found, maybe the article expired or URL changed.");
        return null;
      } else {
        print('Failed to fetch specific article: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching specific article: $e');
      return null;
    }
  }

  Future<List<NewsArticle>> fetchNews([String? query]) async {
    print('Fetching news with query: ${query ?? "headlines"}');
    
    String url;
    
    if (query != null && query.isNotEmpty) {
      final encodedQuery = Uri.encodeComponent(query);
      url = '$functionUrl?query=$encodedQuery&pageSize=50';
    } else {
      url = '$functionUrl?category=$category&country=us&pageSize=50';
    }

    print('Firebase Function URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final articles = jsonData['articles'] as List;
        final totalResults = jsonData['totalResults'] ?? 0;
        
        print('API Success - Total results: $totalResults, Raw articles: ${articles.length}');

        if (articles.isNotEmpty) {
          for (int i = 0; i < min(3, articles.length); i++) {
            final article = articles[i];
            print('$i. Title: "${article['title']}"');
          }
        }

        final newsArticles = articles
            .map((article) => NewsArticle.fromJson(article))
            .where((article) {
              final isValid = article.title.isNotEmpty &&
                  article.title != '[Removed]' &&
                  article.title != 'null' &&
                  article.url.isNotEmpty &&
                  article.url != 'null' &&
                  article.source.isNotEmpty;
              
              if (!isValid) {
                print('Filtered out article: "${article.title}"');
              }
              return isValid;
            })
            .toList();

        print('After filtering: ${newsArticles.length} articles');
        
        return newsArticles;
      } else {
        print('API Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network error: $e');
      return [];
    }
  }
  
  Future<Map<String, List<NewsArticle>>> fetchMultipleCategories(
    List<String> categories) async {
    Map<String, List<NewsArticle>> results = {}; 

    for (var category in categories) {
      final url = Uri.parse('$functionUrl?category=$category&country=us&pageSize=20');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body); 
        final articles = jsonData['articles'] as List;
        results[category] = articles.map((a) => NewsArticle.fromJson(a)).toList();
      } else {
        results[category] = [];
      }
    }
    return results;
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
  return NewsArticle(
    title: _cleanString(json['title'] ?? ''),
    description: _cleanString(json['description'] ?? ''),
    url: _cleanString(json['url'] ?? ''),
    imageUrl: _cleanString(json['urlToImage'] ?? ''),
    source: _cleanString(json['source']?['name'] ?? 'Unknown Source'),
  );
}

static String _cleanString(String input) {
  if (input == 'null' || input == '[Removed]' || input == '[Deleted]') {
    return '';
  }
  return input.trim();
}
} 

class NewsWebViewPage extends StatefulWidget {
  final String url;
  final NewsArticle article;

  const NewsWebViewPage({
    super.key, 
    required this.url,
    required this.article,
  });

  @override
  State<NewsWebViewPage> createState() => _NewsWebViewPageState();
}

class _NewsWebViewPageState extends State<NewsWebViewPage> {
  WebViewController? _controller; 
  bool _showChatPanel = true;
  bool _isMobile = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url)); 
      }
    }

    Future<void> _launchURL() async {
      if (await canLaunchUrl(Uri.parse(widget.url))) {
        await launchUrl(
          Uri.parse(widget.url),
          mode: LaunchMode.inAppWebView, 
        );
      }
    }

    void _toggleChatPanel() {
      setState(() {
        _showChatPanel = !_showChatPanel;
      });
    }

    void _closeChatPanel() {
      setState(() {
        _showChatPanel = false;
      });
    }

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      _isMobile = screenWidth < 768;

      /*if (kIsWeb) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: const Color.fromARGB(0, 255, 255, 255),                  
            iconTheme: IconThemeData(color: secondaryColor), 
            title: const CustomNormalText(text: 'News Article'), 
            backgroundColor: Colors.white, 
            foregroundColor: Colors.black, 
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: _launchURL,
                tooltip: 'Open full article',
              ),
              IconButton(
                icon: Icon(_showChatPanel ? Icons.chat : Icons.chat_outlined),
                onPressed: _toggleChatPanel,
                tooltip: _showChatPanel ? 'Hide AI Assistant' : 'Show AI Assistant',
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.article.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.article.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(height: 200, color: Colors.grey[200]),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Source: ${widget.article.source}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.article.description.isNotEmpty 
                          ? widget.article.description 
                          : 'No description available',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Read Full Article'),
                        onPressed: _launchURL,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for chat panel
                  ],
                ),
              ),
              
              // AI Chat Panel
              if (_showChatPanel) 
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: 20,
                  right: 20,
                  left: _isMobile ? 20 : null,
                  child: Material(
                    color: Colors.transparent,
                    child: AIChatPanel(
                      currentArticle: widget.article,
                      isMobile: _isMobile,
                      onClose: _closeChatPanel,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: _isMobile && !_showChatPanel
              ? Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 10),
                  child: FloatingActionButton(
                    onPressed: _toggleChatPanel,
                    backgroundColor: tertiaryColor,
                    child: Icon(Icons.smart_toy, color: Colors.white),
                  ),
                )
              : null,
        );
      } else {*/
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: const Color.fromARGB(0, 255, 255, 255),                  
          iconTheme: IconThemeData(color: secondaryColor), 
          title: const CustomNormalText(text: 'News'), 
          backgroundColor: Colors.white, 
          foregroundColor: Colors.black, 
          elevation: 1,
          actions: [
            if (!_isMobile) ...[
              IconButton(
                icon: Icon(_showChatPanel ? Icons.chat : Icons.chat_outlined),
                onPressed: _toggleChatPanel,
                tooltip: _showChatPanel ? 'Hide AI Assistant' : 'Show AI Assistant',
              ),
            ],
          ],
        ),
        body: Stack(
          children: [
            if (_controller != null) WebViewWidget(controller: _controller!),
            
            if (_showChatPanel) 
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _isMobile ? null : 20,
                bottom: _isMobile ? 10 : 20,
                right: _isMobile ? 10 : 20,
                left: _isMobile ? 10 : null,
                child: Material(
                  color: Colors.transparent,
                  child: AIChatPanel(
                    currentArticle: widget.article,
                    isMobile: _isMobile,
                    onClose: _closeChatPanel,
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: _isMobile && !_showChatPanel
            ? Container(
                margin: const EdgeInsets.only(bottom: 20, right: 10),
                child: FloatingActionButton(
                  onPressed: _toggleChatPanel,
                  backgroundColor: tertiaryColor,
                  child: Icon(Icons.smart_toy, color: Colors.white),
                ),
              )
            : null,
      );
    }
  /*}*/
}


class NewsTile extends StatelessWidget {
  final NewsArticle article;

  const NewsTile({super.key, required this.article}); 

  String _getFaviconUrl(String articleUrl) {
    try {
      final uri = Uri.parse(articleUrl);
      final domain = uri.host;
      
      final faviconServices = [
        'https://www.google.com/s2/favicons?sz=64&domain_url=$domain',
        'https://icons.duckduckgo.com/ip3/$domain.ico',
        'https://favicon.getbootstrap.com/$domain',
        'https://api.faviconkit.com/$domain/64',
      ];
      
      return faviconServices[0]; 
    } catch (e) {
      return ''; 
    }
  }

  Widget _buildSourceIcon() {
    final logoUrl = _getFaviconUrl(article.url);
    
    if (logoUrl.isEmpty) {
      return const Icon(Icons.public, size: 18);
    }
    
    return CachedNetworkImage(
      imageUrl: logoUrl,
      width: 16,
      height: 16,
      errorWidget: (context, url, error) => const Icon(Icons.public, size: 18),
      placeholder: (context, url) => SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    FirestoreService _firestoreService = FirestoreService(); 
    AIRecommendationService ai_recom_services = AIRecommendationService(); 
    final logoUrl = 'https://www.google.com/s2/favicons?sz=64&domain_url=${article.url}';

    return Center(
      child: ConstrainedBox( 
        constraints: BoxConstraints(maxWidth: cardWidth), 
        child: Card(
          elevation: 0, 
          clipBehavior: Clip.antiAlias, 
          color: secondaryColor.withAlpha(30), 
          margin: EdgeInsets.symmetric(vertical: cardHeight/60, horizontal: cardWidth / 50),
          child: InkWell(
            radius: 8, 
            onTap: () async {
              try {
                await _firestoreService.addToHistory(
                  article.url, 
                  article.title, 
                  article.description, 
                  article.imageUrl
                ); 

                final recommendations = await ai_recom_services.generateUserRecommendations(article);
                if (recommendations != null && recommendations.isNotEmpty) {
                  await _firestoreService.saveTopicWeightsToFirestore(recommendations);
                }

                if (kIsWeb) {
                  launchUrl(
                    Uri.parse(article.url),
                    mode: LaunchMode.externalApplication,
                  );
                  
                  WebWindowService.openAIChatWindow(
                    articleTitle: article.title,
                    articleDescription: article.description,
                    articleUrl: article.url,
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsWebViewPage(
                        url: article.url, 
                        article: article,  
                      ), 
                    ),
                  );
                }
              } catch (e) {
                print('Error saving article: $e');
                if (kIsWeb) {
                  launchUrl(
                    Uri.parse(article.url), 
                    mode: LaunchMode.externalApplication, 
                  );
                  WebWindowService.openAIChatWindow(
                    articleTitle: article.title,
                    articleDescription: article.description, 
                    articleUrl: article.url,
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsWebViewPage( 
                        url: article.url, 
                        article: article,  
                      ), 
                    ),
                  );
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                if (article.imageUrl.isNotEmpty && Uri.tryParse(article.imageUrl)?.hasAbsolutePath == true)
                  ClipRRect(
                    borderRadius: const BorderRadius.only( 
                      topLeft: Radius.circular(8),    
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      article.imageUrl,
                      height: cardHeight, 
                      width: double.infinity, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row(
                        children: [
                          if (kIsWeb) 
                            _buildSourceIcon(),
                          if (!kIsWeb)
                            Image.network(
                              _getFaviconUrl(article.url),  
                              width: 16,
                              height: 16,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, size: 18), 
                            ),
                          const SizedBox(width: 6),
                          CustomNormalText(
                            text: article.source,
                            fontSize: cardWidth / 30, 
                            color: proffessionalBlack.withAlpha(170), 
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      SizedBox(height: 6,), 
                      CustomNormalText(
                        text: article.title,
                        maxLines: 2, 
                        fontSize: cardWidth/20,
                        color: proffessionalBlack,
                        overflow: article.description != ''? TextOverflow.ellipsis: TextOverflow.visible,
                      ),

                      const SizedBox(height: 8),
                      CustomNormalText(
                        text: article.description,
                        fontWeight: FontWeight.w300, 
                        maxLines: 3, 
                        fontSize: cardWidth/25,
                        color: proffessionalBlack.withAlpha(125),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}