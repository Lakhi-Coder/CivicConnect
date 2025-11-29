import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:assets/pages/navbar_screens/news_search_page.dart';
import 'package:assets/services/news_api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExploreNewPage extends StatefulWidget {
  const ExploreNewPage({super.key});

  @override
  State<ExploreNewPage> createState() => _ExploreNewPageState(); 
}

class _ExploreNewPageState extends State<ExploreNewPage> {
  final NewsService _newsService = NewsService();
  final List<String> categories = [
    'politics',
    'health',
    'science',
    'technology',
    'business',
    'sports',
    'entertainment', 
  ];
  bool _isLoading = true;
  String _query = '';  
  List<NewsArticle> _searchResults = [];
  Map<String, List<NewsArticle>> _newsByCategories = {};

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews({String? query}) async {
  if (!mounted) return;
    setState(() {
      _isLoading = true;
      _query = query ?? '';
    });

    if (_query.isNotEmpty) {
      final results = await _newsService.fetchNews(_query); 
      if (!mounted) return;
      setState(() {
        _searchResults = results.cast<NewsArticle>();
        _isLoading = false;
      });
    } else {
      final articles = await _newsService.fetchMultipleCategories(categories); 
      if (!mounted) return;
      setState(() {
        _newsByCategories = articles;
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, 
                  children: [
                    SizedBox(width: getScreenSize(context) == 'mobile'? 60: 0,),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8), 
                      child: CustomTextIconFilledButton(
                        icon: Icon(Icons.more, size: 15, color: primaryColor), 
                        width: 450,
                        height: 50,
                        fillColor: tertiaryColor,
                        radius: BorderRadius.circular(16),
                        text: CustomNormalText(
                          text: 'See All News + Further AI and Search Tools', 
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ), 
                        onPressed:() {
                          Navigator.of(context).push( 
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const NewsSearchPage(),  
                              transitionDuration: Duration(seconds: 0), 
                            ), 
                          ); 
                        },
                      )
                    ),
                  ],
                ),
                /*SizedBox(
                  height: 50, 
                  child: Padding(
                    padding: getScreenSize(context) == 'mobile'? EdgeInsets.only(left: 0, right: 0): EdgeInsets.only(left: 12, right: 250),  
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: CustomSearchBar(
                        controller: TextEditingController(),
                        onSubmitted: (value) {
                          _loadNews(query: value);
                        },
                      ),
                    ),
                  ),
                ), */
                
                const SizedBox(height: 5),
                ...categories.map((category) {
                  final articles = _newsByCategories[category] ?? []; 
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 8), 
                        child: CustomNormalText(
                          text: category[0].toUpperCase() + category.substring(1), 
                          color: proffessionalBlack.withAlpha(150),
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: cardHeight + 150,
                        child: articles.isEmpty
                            ? const Center(child: Text('No articles found.'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: articles.length,
                                itemBuilder: (context, index) =>
                                    NewsTile(article: articles[index]),
                              ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
  }
}