import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/responsive/media_query.dart';
import 'package:assets/entities/widgets/AI_insight/AI_insightful_widget.dart';
import 'package:assets/entities/widgets/bills/bills_display.dart';
import 'package:assets/entities/widgets/button/button.dart';
import 'package:assets/entities/widgets/navbar/custom_main_nav.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/entities/widgets/text_field/text_field.dart';
import 'package:assets/pages/navbar_screens/ai_suggestions_page.dart';
import 'package:assets/pages/navbar_screens/calendar_organizer_scrn.dart';
import 'package:assets/pages/navbar_screens/explore_new_page.dart';
import 'package:assets/pages/navbar_screens/news_feed_page.dart';
import 'package:assets/pages/navbar_screens/saved_articles_page.dart';
import 'package:assets/pages/place_holder.dart';
import 'package:assets/services/google_civic_services.dart';
import 'package:assets/services/news_api_services.dart';
import 'package:flutter/material.dart';

double desktopWidthToggle = 260; 
double extendedWidthToggle = 260; 

List<Map<String, Object>> drawerItems = [
  {'iconPath': 'graphics/icons/app_icons/home_icon.svg', 'title': 'Home', 'width': 22.0, 'redirectScreen': NewsPage()},
  {'iconPath': 'graphics/icons/app_icons/news_icon.svg', 'title': 'News Feed', 'width': 22.0, 'redirectScreen': NewsFeedPage()},
  {'iconPath': 'graphics/icons/app_icons/calendar_icon.svg', 'title': 'Civic Calendar', 'width': 23.0, 'redirectScreen': CalendarOrganizerScrn()}, 
  {'iconPath': 'graphics/icons/app_icons/explore_icon.svg', 'title': 'Explore News', 'width': 23.0, 'redirectScreen': ExploreNewPage()},    
  {'iconPath': 'graphics/icons/app_icons/saved_icon.svg', 'title': 'Saved Articles', 'width': 22.0, 'redirectScreen': SavedArticlesPage()}, 
  {'iconPath': 'graphics/icons/app_icons/suggest_icon.svg', 'title': 'Suggestions', 'width': 26.0, 'redirectScreen': AISuggestionsPage()},
];


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState(); 
}

class _HomePageState extends State<HomePage> { 
  int _selectedIndex = 0; 
  void _toggleSidebar() {
    setState(() {
      desktopWidthToggle = desktopWidthToggle == extendedWidthToggle ? 100 : extendedWidthToggle;   
    }); 
  }
  
  void _onSelect(int index) {
    setState(() => _selectedIndex = index);
    if (getScreenSize(context) == 'mobile') {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      drawer: getScreenSize(context) == 'mobile'
        ? Drawer(
            backgroundColor: primaryColor,
            child: CustomDrawer(
              desktopWidthToggle: desktopWidthToggle,
              extendedWidthToggle: extendedWidthToggle, 
              drawerItems: drawerItems,
              selectedIndex: _selectedIndex,
              onSelect: _onSelect,
            ),
          )
        : null,
      body: SafeArea(
        child: getScreenSize(context) == 'mobile'
            ? MainHomeView(
                toggleSidebar: _toggleSidebar, 
                selectedIndex: _selectedIndex, 
                onSelect: _onSelect, 
              )
            : Row(
                children: [
                  GestureDetector(
                    onTap: _toggleSidebar,
                    child: HomeBar(width: desktopWidthToggle, onSelect: _onSelect, selectedIndex: _selectedIndex,), 
                  ),
                  Expanded(
                    child: MainHomeView(
                      toggleSidebar: _toggleSidebar, 
                      selectedIndex: _selectedIndex,
                      onSelect: _onSelect,
                    ),
                  ),
                ],
              ),
      )
    );
  }
}


class HomeBar extends StatelessWidget {
  const HomeBar({
    super.key,
    required this.width,
    required this.selectedIndex, 
    required this.onSelect, 
  });

  final double width;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = getScreenSize(context) == 'tablet' ? 100 : width; 
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), 
      clipBehavior: Clip.hardEdge, 
      curve: Curves.decelerate, 
      width: sidebarWidth, 
      
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255), 
        
      ),
      child: ClipRect(child: CustomDrawer(
        desktopWidthToggle: desktopWidthToggle, 
        extendedWidthToggle: extendedWidthToggle, 
        drawerItems: drawerItems, 
        selectedIndex: selectedIndex,
        onSelect: onSelect,
        )
      )
    );
  }
}


class MainHomeView extends StatelessWidget {
  const MainHomeView({
    super.key,
    required this.toggleSidebar,
    required this.selectedIndex,
    required this.onSelect,
  });

  final VoidCallback toggleSidebar;
  final int selectedIndex; 
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: _CenterContent(selectedIndex: selectedIndex),
          ),

          if (getScreenSize(context) == 'mobile')
            Positioned(
              top: 16,
              left: 16,
              child: CustomIconFilledButton(
                icon: const Icon(Icons.menu, size: 22),
                borderColor: Colors.transparent,
                width: 50,
                height: 50,
                radius: 55,
                fillColor: proffessionalBlack,
                iconColor: Colors.white,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

          if (getScreenSize(context) != 'mobile')
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                    colors: [Color.fromARGB(5, 229,199,182), Color.fromARGB(0,229,199,182)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CenterContent extends StatelessWidget {
  const _CenterContent({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedIndex,
      children: const [
        /*Home*/             NewsPage(), 
        /*News Feed*/        NewsFeedPage(),
        /*Civic Calendar*/   CalendarOrganizerScrn(), 
        /*Explore News*/     ExploreNewPage(), 
        /*Saved Articles*/   SavedArticlesPage(),
        /*Suggestions*/      AISuggestionsPage(), 
      ],
    );
  }
}


class SideHomeView extends StatelessWidget { 
  const SideHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NewsPage(), 
    );  
  }
}



class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsService _newsService = NewsService(); 
  List<dynamic> _articles = [];
  List<dynamic>? _political_articles = []; 
  bool _isLoading = true; 
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews({String? query}) async {
    setState(() => _isLoading = true);
    _newsService.setCategory('politics');
    final articles = await _newsService.fetchNews(query);
    final political_articles = await _newsService.fetchMultipleCategories(['politics']); 
    if (!mounted) return; 
    setState(() {
      _articles = articles; 
      _political_articles = political_articles['politics']; 
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /*SizedBox(
            height: 50, 
            child: Padding(
              padding: getScreenSize(context) == 'mobile'? EdgeInsets.only(left: 62, right: 0): EdgeInsets.only(left: 12, right: 250),  
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0), 
                child: CustomSearchBar(
                  controller: TextEditingController(),
                  onSubmitted: (value) {
                    setState(() => _query = value);   
                    _loadNews(query: value);
                  },
                ),
              ),
            ),
          ), */
          SizedBox(height: 100, child: EventsPage()), 
          
      
          SizedBox(height: 10,), 
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20), 
                child: CustomNormalText( 
                  textAlign: TextAlign.left, 
                  text: 'Trending Top News', 
                  color: proffessionalBlack.withAlpha(150),  
                  fontSize: 18, 
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.transparent), 
                    onTap: () => {
                      context.findAncestorStateOfType<_HomePageState>()?._onSelect(3) 
                    }, 
                    child: CustomNormalText( 
                      textAlign: TextAlign.right,
                      fontWeight: FontWeight.w500, 
                      text: 'View More', 
                      color: tertiaryColor,  
                      fontSize: 15, 
                    ),
                  ),
                ),
              ),
            ],
          ), 

          SizedBox(height: 10,), 
      
          SizedBox(
            height: cardHeight + 150,  
            child: _isLoading
            ? const Center(child: CircularProgressIndicator()) 
            : _articles.isEmpty
            ? const Center(child: Text('No articles found.')) 
            : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _articles.length, 
              itemBuilder: (context, index) => NewsTile(article: _articles[index]), 
            ),
          ),

          SizedBox(height: 26,), 

          AIPoliticalInsightsWidget(), 
          
          RecentBillsWidget(),
        ],
      ),
    );
  }
}