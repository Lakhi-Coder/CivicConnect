import 'package:cloud_firestore/cloud_firestore.dart';

class NewsFirestoreService {
  final CollectionReference _newsCollection = FirebaseFirestore.instance
      .collection('news');

  Future<void> addNewsArticle(Map<String, dynamic> articleData) async {
    await _newsCollection.add({
      ...articleData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchNews() async {
    final snapshot =
        await _newsCollection.orderBy('timestamp', descending: true).get();  
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchByCategory(String category) async {
    final snapshot =
        await _newsCollection
            .where('category', isEqualTo: category)
            .orderBy('timestamp', descending: true) 
            .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
