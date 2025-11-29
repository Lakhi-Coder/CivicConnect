import 'dart:math';

import 'package:assets/entities/widgets/AI_insight/AI_insightful_widget.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:assets/services/webview_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/services/news_api_services.dart';
import 'package:assets/services/AI_recom_services.dart';
import 'package:assets/services/firestore_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web/web.dart' as html;

class NewsSearchPage extends StatefulWidget {
  const NewsSearchPage({super.key});

  @override
  State<NewsSearchPage> createState() => _NewsSearchPageState();
}

class _NewsSearchPageState extends State<NewsSearchPage> {
  final NewsService _newsService = NewsService();
  final AIRecommendationService _aiService = AIRecommendationService();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<NewsArticle> _allNews = [];
  List<NewsArticle> _displayedNews = [];
  List<NewsArticle> _filteredNews = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';
  String _aiSearchContext = '';

  final Map<String, double> _sourceReliability = {
    'associated press': 0.95,
    'reuters': 0.95,
    'bbc news': 0.90,
    'cnn': 0.85,
    'the new york times': 0.90,
    'the washington post': 0.88,
    'npr': 0.87,
    'politico': 0.82,
    'fox news': 0.75,
    'breitbart': 0.65,
  };

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newsService.testNewsAPI();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreNews();
    }
  }

  Future<void> _loadInitialNews() async {
    setState(() {
      _isLoading = true;
    });

    print('🔄 Starting to load initial news...');

    try {
      final news = await _newsService.fetchNews();

      print('📰 Received ${news.length} articles from API');

      if (news.isNotEmpty) {
        _sortNewsByReliability(news);

        setState(() {
          _allNews = news;
          _displayedNews = _allNews.take(20).toList();
          _filteredNews = _displayedNews;
          _isLoading = false;
        });

        print(
          'Initial news loaded: ${_allNews.length} total, ${_displayedNews.length} displayed',
        );

        print('Displayed articles:');
        for (int i = 0; i < min(3, _displayedNews.length); i++) {
          final article = _displayedNews[i];
          print('   $i. ${article.title} - ${article.source}');
        }
      } else {
        print('No news articles received from API');
        setState(() {
          _isLoading = false;
          _allNews = [];
          _displayedNews = [];
          _filteredNews = [];
        });
      }
    } catch (e) {
      print('Error loading initial news: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = _displayedNews.length;
    final endIndex = startIndex + 10;

    if (endIndex >= _allNews.length) {
      setState(() {
        _displayedNews = _allNews;
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _displayedNews = _allNews.take(endIndex).toList();
      _filteredNews = _currentQuery.isEmpty ? _displayedNews : _filteredNews;
      _isLoading = false;
    });
  }

  void _sortNewsByReliability(List<NewsArticle> news) {
    news.sort((a, b) {
      final aScore = _getReliabilityScore(a.source);
      final bScore = _getReliabilityScore(b.source);
      return bScore.compareTo(aScore);
    });
  }

  double _getReliabilityScore(String source) {
    final sourceLower = source.toLowerCase();
    for (var reliableSource in _sourceReliability.keys) {
      if (sourceLower.contains(reliableSource)) {
        return _sourceReliability[reliableSource]!;
      }
    }
    return 0.5;
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _currentQuery = '';
        _filteredNews = _displayedNews;
        _aiSearchContext = '';
      });
      return;
    }

    setState(() {
      _currentQuery = query;
      _isLoading = true;
    });

    print('🔍 Performing search for: "$query"');

    try {
      final dynamicResults = await _newsService.fetchNews(query);
      print('📰 Search API response length: ${dynamicResults.length}');

      List<NewsArticle> searchResults;

      if (dynamicResults is List<NewsArticle>) {
        searchResults = dynamicResults;
        print('Already List<NewsArticle>, length: ${searchResults.length}');
      } else if (dynamicResults is List) {
        searchResults = dynamicResults.whereType<NewsArticle>().toList();
        print(
          'Converted to List<NewsArticle>, length: ${searchResults.length}',
        );
        if (searchResults.isEmpty &&
            dynamicResults.isNotEmpty &&
            dynamicResults.first is Map<String, dynamic>) {
          searchResults =
              dynamicResults.map<NewsArticle>((item) {
                return NewsArticle.fromJson(item as Map<String, dynamic>);
              }).toList();
          print('Created from Map, length: ${searchResults.length}');
        }
      } else {
        print('Unexpected search response type: ${dynamicResults.runtimeType}');
        searchResults = [];
      }

      print('Final search results: ${searchResults.length} articles');

      if (query.length > 3) {
        _aiSearchContext = "AI-enhanced results for: $query";
      } else {
        _aiSearchContext = "Search results for: $query";
      }

      _sortNewsByReliability(searchResults);

      setState(() {
        _filteredNews = searchResults;
        _isLoading = false;
      });

      print('🎉 Search completed: ${_filteredNews.length} results');
    } catch (e) {
      print('Error performing search: $e');
      setState(() {
        _isLoading = false;
        _filteredNews = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _enhanceSearchWithAI(String query) async {
    try {
      final prompt = """
      As a news search assistant, enhance this search query for better news article discovery:
      
      Original query: "$query"
      
      Please return ONLY the enhanced search query without any explanations.
      Make it more specific, include relevant keywords, and focus on current events.
      Keep it concise (max 5-7 words).
      
      Examples:
      - "politics" → "US politics latest developments 2024"
      - "health news" → "healthcare policy medical news today"
      - "technology" → "technology innovation AI developments 2024"
      """;

      final response = await _aiService.replyToUser(prompt);
      return response.trim();
    } catch (e) {
      print('AI search enhancement failed: $e');
      return query;
    }
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _performSearch('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchBar(),
          if (_aiSearchContext.isNotEmpty) _buildAIContextBanner(),
          Expanded(child: _buildNewsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back), // or Icons.arrow_back
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search political news...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SvgPicture.asset(
                      'graphics/icons/app_icons/search_bar_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        secondaryColor.withAlpha(150),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                          : null,
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (_isLoading)
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.tune, color: primaryColor),
              onPressed: () {
                _showFilterOptions();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAIContextBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _aiSearchContext,
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    if (_isLoading && _filteredNews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredNews.isEmpty && _currentQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No news found for "${_currentQuery}"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check your connection',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredNews.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredNews.length) {
          return _buildLoadMoreIndicator();
        }

        final article = _filteredNews[index];
        return _buildNewsTile(article);
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child:
            _isLoading
                ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                )
                : Text(
                  'No more articles',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14), 
                ),
      ),
    );
  }

  Widget _buildNewsTile(NewsArticle article) {
    final reliabilityScore = _getReliabilityScore(article.source);
    final reliabilityColor =
        reliabilityScore > 0.8
            ? Colors.green
            : reliabilityScore > 0.6 
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _firestoreService.addToHistory(
              article.url,
              article.title,
              article.description,
              article.imageUrl,
            );
            
            _openNewsArticle(article);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.imageUrl.isNotEmpty &&
                    Uri.tryParse(article.imageUrl)?.hasAbsolutePath == true)
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(article.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.article, color: Colors.grey[400]),
                  ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            article.source,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: reliabilityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      if (article.description.isNotEmpty)
                        Text(
                          article.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
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

  void _openNewsArticle(NewsArticle article) async {
    print('🎯 Opening: ${article.title}');
    
    try {
      await _firestoreService.addToHistory(
        article.url,
        article.title,
        article.description,
        article.imageUrl,
      );

      final recommendations = await _aiService.generateUserRecommendations(article);
      if (recommendations != null && recommendations.isNotEmpty) {
        await _firestoreService.saveTopicWeightsToFirestore(recommendations);
      }

      if (kIsWeb) {
        html.window.open(article.url, '_blank'); 
        
        WebWindowService.openAIChatWindow(
          articleTitle: article.title,
          articleDescription: article.description,
          articleUrl: article.url,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsWebViewPage(url: article.url, article: article),
          ),
        );
      }
    } catch (e) {
      print('Error: $e'); 
      if (kIsWeb) {
        html.window.open(article.url, '_blank');
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AIPoliticalInsightsWidget(),
              SizedBox(height: 20),
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.update, color: primaryColor),
                title: const Text('Sort by latest'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.verified, color: primaryColor),
                title: const Text('High reliability only'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
