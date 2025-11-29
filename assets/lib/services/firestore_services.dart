import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  Future<void> addToHistory(String articleUrl, String title, String description, String imageURL) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userDoc.set({
        'email': user.email,
        'name': user.displayName ?? '',
        'history': {
          'URLs': FieldValue.arrayUnion([articleUrl]), 
          'titles': FieldValue.arrayUnion([title]),
          'description': FieldValue.arrayUnion([description]), 
          'imageURL': FieldValue.arrayUnion([imageURL])
        },
      }, SetOptions(merge: true));
      
      print('Article saved to history: $title');
    } catch (e) {
      print('Error saving to history: $e');
    }
  } 

  Future<void> addToFavorites(String articleUrl) async { 
    final user = FirebaseAuth.instance.currentUser; 
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection('users') 
        .doc(user.uid);
    await userDoc.update({
      'favorites': FieldValue.arrayUnion([articleUrl]),
    });
  }

  Future<void> updateTopicWeights(Map<String, dynamic> newWeights) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid); 

    final doc = await docRef.get(); 

    final currWeightsPreferences = doc['preferences'] ?? {}; 
    /*Map<String, dynamic>.from(doc['preferences']['topicWeights']*/
    final currWeights = Map<String, double>.from(currWeightsPreferences['weights'] ?? {});  

    newWeights.forEach((topic, score) {
      print("TOPIC WEIGHT TOPIC: $topic");
      print("TOPIC WEIGHT SCORE: $score");

      double currentValue = (currWeights[topic] ?? 0.0).toDouble(); 
      double newValue = (score is num ? score.toDouble() : 0.0);
      double notRoundedValue = currentValue * 0.9 + newValue * 0.1; 
      double RoundedValue = (notRoundedValue * 100000).roundToDouble() / 100000; 
      currWeights[topic] = RoundedValue;
    });

    await docRef.update({
      'preferences.topicWeights': currWeights,
    });

    print("UPDATED WEIGHTS: $currWeights");
  } 

  Future<void> saveTopicWeightsToFirestore(String jsonResponse) async {
  try {
    final Map<String, dynamic> data = jsonDecode(jsonResponse);
    final Map<String, dynamic> newWeights =
        Map<String, dynamic>.from(data['weights'] ?? {}); // Add null check

    final uid = FirebaseAuth.instance.currentUser?.uid; // Make nullable
    if (uid == null) {
      print('No user logged in');
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);     

    final userDoc = await docRef.get();
    final existingWeights = Map<String, dynamic>.from(
        userDoc.data()?['preferences']?['topicWeights'] ?? {} 
    );

    newWeights.forEach((topic, weight) {
      double oldValue = (existingWeights[topic] ?? 0.0).toDouble(); 
      double newValue = (weight is num) ? weight.toDouble() : 0.0;
      existingWeights[topic] = oldValue * 0.9 + newValue * 0.1;
    });

    await docRef.set({
      'preferences': {
        'topicWeights': existingWeights,
      }
    }, SetOptions(merge: true));

    print("Updated preference weights: $existingWeights");
  } catch (e) {
    print('Error saving topic weights: $e');
  }
}

  Future<Map<String, double>> getUserTopicWeights() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) 
          .get();

      if (doc.exists) {
        final preferences = doc.data()?['preferences'];
        if (preferences != null && preferences['topicWeights'] != null) {
          return Map<String, double>.from(preferences['topicWeights']);
        }
      }
    } catch (e) {
      print('Error fetching user topic weights: $e');
    }
    
    return {
      'politics': 0.2,
      'health': 0.2,
      'science': 0.2,
      'technology': 0.2,
      'sports': 0.1,
      'entertainment': 0.1,
    };
  }

  Future<List<String>> getUserTopCategories([int count = 3]) async { 
    final weights = await getUserTopicWeights();
    
    final sortedEntries = weights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries
        .take(count)
        .where((entry) => entry.value > 0.1) 
        .map((entry) => entry.key)
        .toList();
  }

  Map<String, double> calculateTopicWeights(List<Map<String, dynamic>> history) {
    final Map<String, int> counts = {};
    for (final item in history) {
      final category = item['category'] ?? 'other'; 
      final liked = item['liked'] == true;
      counts[category] = (counts[category] ?? 0) + (liked ? 2 : 1); 
    }

    final total = counts.values.fold(0, (a, b) => a + b);
    return counts.map((k, v) => MapEntry(k, v / total));
  }
}
