import 'dart:convert';

import 'package:assets/pages/get_started_page.dart';
import 'package:assets/pages/home_page.dart';
import 'package:assets/entities/color_pallete.dart';
import 'package:assets/pages/navbar_screens/news_search_page.dart';
import 'package:assets/pages/signup_page.dart';
import 'package:assets/pages/standalone_ai_chat_page/standalone_ai_chat_page.dart';
import 'package:assets/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web/web.dart' as html; 

Future<void> _submitEvent() async {
  final user = FirebaseAuth.instance.currentUser;
  (user == null) ? print(user) : print("No user logged in"); 
  final userDoc = FirebaseFirestore.instance.collection('users').doc(user?.uid); 

  await userDoc.set({
    'email': user?.email,
    'name': user?.displayName ?? '',
    'createdAt': FieldValue.serverTimestamp(), 
  }, SetOptions(merge: true));

  final snapshot = await FirebaseFirestore.instance.collection('events').get(); 
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); 
  }
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 
  runApp(MainApp());
  final info = await PackageInfo.fromPlatform();

  final firebase_storage = FirebaseFirestore.instance;
  print('Bundle ID REAL: ${info.packageName}');
  _submitEvent();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget _homeWidget = const Center(child: CircularProgressIndicator());
  bool _isCheckingAIChat = true;

  @override
  void initState() {
    super.initState();
    _determineHomePage();
  }

  void _determineHomePage() async {
    if (kIsWeb) {
      await _checkForAIChatRequest();
    } else {
      _checkLoginStatus();
    }
  }

  Future<void> _checkForAIChatRequest() async {
    if (!kIsWeb) return;
    try {
      final storedArticle = html.window.localStorage.getItem('current_article');
      
      if (storedArticle != null && storedArticle.isNotEmpty) {
        final articleData = json.decode(storedArticle);
        final timestamp = int.tryParse(articleData['timestamp'] ?? '0') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        if (now - timestamp < 300000) { // 5 minutes
          print('Found valid AI chat request');
          print('Title: ${articleData['title']}');
          print('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
          
          setState(() {
            _homeWidget = AIChatPage(
              articleTitle: articleData['title'] ?? '',
              articleDescription: articleData['description'] ?? '',
              articleUrl: articleData['url'] ?? '',
            );
            _isCheckingAIChat = false;
          });

          Future.delayed(const Duration(seconds: 3), () {
            html.window.localStorage.removeItem('current_article');
            print('Cleared article data from storage');
          });
          
          return;
        } else {
          print('Clearing stale article data (too old)');
          html.window.localStorage.removeItem('current_article');
        }
      } else {
        print('No AI chat request found in localStorage');
      }
    } catch (e) {
      print('Error checking for AI chat: $e');
    }
    
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      setState(() {
        _homeWidget = HomePage();
        _isCheckingAIChat = false;
      });
    } else {
      setState(() {
        _homeWidget = GetStartedScrn();
        _isCheckingAIChat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Montserrat',
        textSelectionTheme: TextSelectionThemeData(cursorColor: tertiaryColor), 
      ),
      home: _isCheckingAIChat 
      ? const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading AI Chat...'),
              ],
            ),
          ),
        )
      : _homeWidget,
    );
  }
}