import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/services/AI_powered_news_fetching_services.dart';
import 'package:assets/services/news_api_services.dart';
import 'package:assets/services/firestore_services.dart';
import 'package:assets/services/political_events_services.dart';
import 'package:flutter/material.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final NewsService _newsService = NewsService();
  final FirestoreService _firestoreService = FirestoreService(); 
  final AINewsService _aiNewsService = AINewsService();
  final PoliticalEventsService _politicalEventsService = PoliticalEventsService();
  
  List<dynamic> _articles = [];
  List<dynamic> _personalizedArticles = [];
  List<dynamic> _aiPersonalizedArticles = [];
  Map<String, double> _userWeights = {};
  List<String> _topCategories = [];
  
  String _politicalSummary = '';
  bool _isLoadingPoliticalSummary = true;
  bool _isLoading = true;
  bool _isLoadingPersonalized = true;
  bool _isLoadingAIPersonalized = true;

  double get cardWidth => 300;
  double get cardHeight => cardWidth * 0.56;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print("Loading user data...");
    
    _userWeights = await _firestoreService.getUserTopicWeights();
    print("User weights: $_userWeights");
    
    _topCategories = await _firestoreService.getUserTopCategories(2);
    print("Top categories: $_topCategories");
    
    await Future.wait([
      _loadAIPersonalizedNews(),
      _loadPersonalizedNews(),
      _loadGeneralNews(),
      _loadPoliticalSummary(),
    ]);
  }

  Future<void> _loadAIPersonalizedNews() async {
    if (!mounted) return;
    setState(() => _isLoadingAIPersonalized = true);
    
    try {
      print("Loading AI-powered personalized news...");
      _aiPersonalizedArticles = await _aiNewsService.getAIPersonalizedNews();
      print("AI personalized articles: ${_aiPersonalizedArticles.length}");
    } catch (e) {
      print('Error loading AI personalized news: $e');
      if (mounted) {
        setState(() => _aiPersonalizedArticles = []);
      }
    }
    
    if (mounted) {
      setState(() => _isLoadingAIPersonalized = false);
    }
  }

  Future<void> _loadPersonalizedNews() async {
    if (!mounted) return;
    setState(() => _isLoadingPersonalized = true);
    
    try {
      if (_topCategories.isNotEmpty) {
        print("Fetching news for categories: $_topCategories");
        final categoryNews = await _newsService.fetchMultipleCategories(_topCategories);
        print("Category news received: ${categoryNews.length} categories");
        
        List<dynamic> allArticles = [];
        categoryNews.forEach((category, articles) {
          print("$category: ${articles.length} articles");
          allArticles.addAll(articles);
        });
        
        if (mounted) {
          setState(() => _personalizedArticles = _removeDuplicates(allArticles));
        }
        print("Personalized articles after deduplication: ${_personalizedArticles.length}");
      } else {
        print("No top categories, falling back to general news");
        final articles = await _newsService.fetchNews();
        if (mounted) {
          setState(() => _personalizedArticles = articles);
        }
      }
    } catch (e) {
      print('Error loading personalized news: $e');
      if (mounted) {
        setState(() => _personalizedArticles = []);
      }
    }
    
    if (mounted) {
      setState(() => _isLoadingPersonalized = false);
    }
  }

  Future<void> _loadGeneralNews() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      print("Loading general news...");
      final articles = await _newsService.fetchNews();
      print("General articles received: ${articles.length}");
      
      if (!mounted) return;
      setState(() { 
        _articles = articles; 
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading general news: $e');
      if (mounted) {
        setState(() {
          _articles = []; 
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPoliticalSummary() async {
    if (!mounted) return;
    setState(() => _isLoadingPoliticalSummary = true);
    
    try {
      print("Loading political events summary...");
      final summary = await _politicalEventsService.getWeeklyPoliticalSummary();
      print("Political summary loaded: ${summary.length} characters");
      
      if (mounted) {
        setState(() => _politicalSummary = summary);
      }
    } catch (e) {
      print('Error loading political summary: $e');
      if (mounted) {
        setState(() {
          _politicalSummary = 'Unable to load political events summary. Please try again later.';
        });
      }
    }
    
    if (mounted) {
      setState(() => _isLoadingPoliticalSummary = false);
    }
  }
  Future<void> _refreshInterestsOnly() async {
    if (!mounted) return;
    
    
    try {
      final newWeights = await _firestoreService.getUserTopicWeights();
      final newCategories = await _firestoreService.getUserTopCategories(2);
      
      if (mounted) {
        setState(() {
          _userWeights = newWeights;
          _topCategories = newCategories;
        });
      }
      
      print("Interests updated - Weights: $_userWeights");
      print("Interests updated - Categories: $_topCategories");
      
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    print("🔄 Manually refreshing all data...");
    
    setState(() {
      _isLoading = true;
      _isLoadingPersonalized = true;
      _isLoadingAIPersonalized = true;
      _isLoadingPoliticalSummary = true;
    });

    try {
      final newWeights = await _firestoreService.getUserTopicWeights();
      final newCategories = await _firestoreService.getUserTopCategories(2);
      
      if (mounted) {
        setState(() {
          _userWeights = newWeights;
          _topCategories = newCategories;
        });
      }
      
      print("New weights: $_userWeights");
      print("New categories: $_topCategories");
      
      await Future.wait([
        _loadAIPersonalizedNews(),
        _loadPersonalizedNews(),
        _loadGeneralNews(),
        _loadPoliticalSummary(),
      ]);
      
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingPersonalized = false;
          _isLoadingAIPersonalized = false;
          _isLoadingPoliticalSummary = false;
        });
      }
    }
  }

  List<dynamic> _removeDuplicates(List<dynamic> articles) {
    final seenUrls = <String>{};
    return articles.where((article) {
      if (article.url == null || article.url.isEmpty) {
        return false; 
      }
      if (seenUrls.contains(article.url)) {
        return false;
      }
      seenUrls.add(article.url);
      return true;
    }).toList();
  }

  Widget _buildTopicChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CustomNormalText(
              textAlign: TextAlign.left,
              text: 'Your Interests',
              color: tertiaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: _refreshInterestsOnly,
              tooltip: 'Refresh interests',
              color: tertiaryColor,
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        if (_userWeights.isEmpty) 
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CustomNormalText(
              text: 'Read articles to build your preferences',
              color: Colors.grey, 
              fontSize: 14,
            ),
          )
        else 
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _userWeights.entries.length,
              itemBuilder: (context, index) {
                final entry = _userWeights.entries.toList()[index];
                final isTopCategory = _topCategories.contains(entry.key);
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(
                      '${entry.key} (${(entry.value * 100).toStringAsFixed(0)}%)', 
                      style: TextStyle(
                        color: isTopCategory ? Colors.white : proffessionalBlack,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: isTopCategory ? tertiaryColor : Colors.grey[300],
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNewsSection(String title, List<dynamic> articles, bool isLoading, {bool isAISection = false}) {
    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (articles.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAISection ? Icons.auto_awesome : Icons.article, 
                size: 40, 
                color: Colors.grey[400]
              ),
              const SizedBox(height: 10),
              CustomNormalText(
                text: isAISection ? 
                  'AI is learning your preferences...' : 
                  'No articles available',
                color: Colors.grey,
                fontSize: 16,
              ),
              const SizedBox(height: 5),
              CustomNormalText(
                text: isAISection ?
                  'Click on more articles to improve recommendations' :
                  'Try refreshing or check your connection',
                color: Colors.grey,
                fontSize: 12,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Row(
            children: [
              CustomNormalText(
                textAlign: TextAlign.left,
                text: title,
                fontSize: 18,
                color: proffessionalBlack.withAlpha(150),
                fontWeight: FontWeight.w500, 
              ),
              if (isAISection) ...[
                const SizedBox(width: 8),
                Icon(Icons.auto_awesome, size: 18, color: tertiaryColor),
              ],
            ],
          ),
        ),
        SizedBox(
          height: cardHeight + 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return NewsTile(article: article);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPoliticalSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: tertiaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tertiaryColor.withAlpha(20),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.flag, color: tertiaryColor, size: 20),
                const SizedBox(width: 8),
                const CustomNormalText(
                  text: 'This Week in Politics',
                  fontSize: 16,
                  fontWeight: FontWeight.w500, 
                  color: tertiaryColor,
                ),
                const Spacer(), 
                _isLoadingPoliticalSummary
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: tertiaryColor),
                      )
                    : IconButton(
                        icon: Icon(Icons.refresh, size: 18, color: tertiaryColor),
                        onPressed: _loadPoliticalSummary,
                        tooltip: 'Refresh summary',
                      ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoadingPoliticalSummary
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _politicalSummary.isEmpty
                    ? const Center(
                        child: CustomNormalText(
                          text: 'No political summary available',
                          color: Colors.grey,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SelectableText(
                        _politicalSummary,
                        style: TextStyle(
                          color: proffessionalBlack,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
          ),
          
          if (!_isLoadingPoliticalSummary && _politicalSummary.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.update, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  CustomNormalText(
                    text: 'Updated ${DateTime.now().toString().split(' ')[0]}',
                    fontSize: 12,
                  ),
                  const Spacer(),
                  CustomNormalText(
                    text: 'Powered by AI',
                    fontSize: 12,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: RefreshIndicator(
        onRefresh: _refreshData, 
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildPoliticalSummarySection(),
              const SizedBox(height: 20),
              
              Container(
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: secondaryColor.withAlpha(20),  
                  borderRadius: BorderRadius.circular(18), 
                ),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopicChips(),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              _buildNewsSection(
                'AI Recommended For You', 
                _aiPersonalizedArticles, 
                _isLoadingAIPersonalized,
                isAISection: true,
              ),
              
              const SizedBox(height: 20),
              _buildNewsSection(
                'Recommended From Your Interests', 
                _personalizedArticles, 
                _isLoadingPersonalized
              ),
              
              const SizedBox(height: 20),
              /*_buildNewsSection(
                'Trending News', 
                _articles, 
                _isLoading
              ),*/
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}