import 'package:assets/entities/color_pallete.dart';
import 'package:assets/entities/widgets/text/custom_text.dart';
import 'package:assets/services/metadata_services.dart';
import 'package:assets/services/news_api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedArticlesPage extends StatefulWidget {
  const SavedArticlesPage({super.key});

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  final NewsService _newsService = NewsService();
  bool _isReloading = false;
  int _reloadKey = 0;

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return userDoc.data();
  }

  Future<void> _deleteFromHistory(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final historyData = Map<String, dynamic>.from(data['history'] ?? {});
        final historyURLs = List<String>.from(historyData['URLs'] ?? []);
        final historyTitles = List<String>.from(historyData['titles'] ?? []);
        final historyDescription = List<String>.from(historyData['description'] ?? []);
        final historyImageURL = List<String>.from(historyData['imageURL'] ?? []);

        if (index < historyURLs.length && 
            index < historyTitles.length && 
            index < historyDescription.length && 
            index < historyImageURL.length) {
          
          historyURLs.removeAt(index);
          historyTitles.removeAt(index);
          historyDescription.removeAt(index);
          historyImageURL.removeAt(index);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'history': {
              'URLs': historyURLs,
              'titles': historyTitles,
              'description': historyDescription,
              'imageURL': historyImageURL,
            }
          });

          _reloadHistory();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article removed from history'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting from history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove article'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'history': {
          'URLs': [],
          'titles': [],
          'description': [],
          'imageURL': [],
        }
      });

      _reloadHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All history cleared'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error clearing history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to clear history'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _reloadHistory() async {
    setState(() {
      _isReloading = true;
    });

    setState(() {
      _reloadKey++;
      _isReloading = false;
    });
  }

  void _showDeleteConfirmation(int index, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from History?'),
        content: Text('Remove "$title" from your reading history?'),
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFromHistory(index);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryColor, 
        title: const Text('Clear All History?'),
        content: const Text('This will remove all articles from your reading history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Reading History'),
        backgroundColor: primaryColor,
        surfaceTintColor: primaryColor,
        foregroundColor: proffessionalBlack,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: _isReloading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(tertiaryColor),
                      ),
                    )
                  : const Icon(Icons.refresh),
              onPressed: _isReloading ? null : _reloadHistory,
              tooltip: 'Refresh History',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: _showClearAllConfirmation,
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _reloadHistory();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: _buildHistorySection(),
      ),
    );
  }

  Widget _buildHistorySection() {
    return FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey<int>(_reloadKey),
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No user data found',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _reloadHistory,
                  style: ButtonStyle(
                    elevation: WidgetStatePropertyAll(0), 
                    backgroundColor: WidgetStatePropertyAll(primaryColor), 
                    surfaceTintColor: WidgetStatePropertyAll(secondaryColor.withAlpha(120)), 
                    overlayColor: WidgetStatePropertyAll(tertiaryColor.withAlpha(30)), 
                  ),
                  child: CustomNormalText(text: 'Retry', fontSize: 15,),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final historyData = data['history'] ?? {};
        final historyURLs = List<String>.from(historyData['URLs'] ?? []);
        final historyTitles = List<String>.from(historyData['titles'] ?? []);
        final historyDescription = List<String>.from(historyData['description'] ?? []);
        final historyImageURL = List<String>.from(historyData['imageURL'] ?? []);

        if (historyURLs.isEmpty || historyTitles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No reading history yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Articles you read will appear here',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                /*ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: _reloadHistory,
                ),*/ 
                ElevatedButton.icon(
                  onPressed: _reloadHistory,
                  style: ButtonStyle(
                    elevation: WidgetStatePropertyAll(0), 
                    backgroundColor: WidgetStatePropertyAll(primaryColor), 
                    surfaceTintColor: WidgetStatePropertyAll(secondaryColor.withAlpha(120)), 
                    overlayColor: WidgetStatePropertyAll(tertiaryColor.withAlpha(30)), 
                    iconColor: WidgetStatePropertyAll(secondaryColor.withAlpha(200)),
                  ),
                  label: CustomNormalText(text: 'Refresh', fontSize: 15,), 
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${historyTitles.length} saved articles',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Clear All History'),
                    onPressed: _showClearAllConfirmation,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: historyTitles.length,
                itemBuilder: (context, index) {
                  final title = historyTitles[index];
                  final url = index < historyURLs.length ? historyURLs[index] : '';
                  final description = (index < historyDescription.length)
                      ? historyDescription[index]
                      : ''; 
                  final imageURL = (index < historyImageURL.length)
                      ? historyImageURL[index]
                      : ''; 
                  return _buildHistoryNewsTile(index, title, url, description, imageURL);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryNewsTile(int index, String title, String url, String description, String imageUrl) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchMetadata(url),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final metadata = snapshot.data ?? {};

        final source = metadata['source'] ?? 'Unknown Source';

        NewsArticle article = NewsArticle(
          title: title,
          description: description,
          url: url,
          imageUrl: imageUrl,
          source: source,
        );

        return Dismissible(
          key: Key('$url-$index-${DateTime.now().millisecondsSinceEpoch}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            _showDeleteConfirmation(index, title);
            return false; 
          },
          child: Stack(
            children: [
              NewsTile(article: article),
              
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), 
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18), 
                    color: Colors.red,
                    onPressed: () => _showDeleteConfirmation(index, title), 
                    tooltip: 'Remove from history',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}