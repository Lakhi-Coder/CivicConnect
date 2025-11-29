import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> loginGoogle(BuildContext context, TextEditingController controller) async {
  try {
    print('hello 0'); 
    
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
      
      if (userCredential.user == null) {
        print('False: There is no user'); 
        return false;
      }
      
      controller.text = 'You have successfully logged in to your Google account!';
      return true;
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn( 
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'], 
        clientId: Platform.isIOS ? '181471502632-cc6nd8dvv8h9g4rpe5bo855rl8tku5tt.apps.googleusercontent.com' : null,  
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn(); 

      if (googleUser == null) {
        print('False: There is no user'); 
        return false;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      print("hello 1"); 
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('hello 2'); 

      await FirebaseAuth.instance.signInWithCredential(credential);
      controller.text = 'You have successfully logged in to your Google account!';
      return true;
    }
  } catch (e) {
    controller.text = 'Login error: $e'; 
    print('Login error: $e');
    return false;
  }
}


Future<bool> signUp(context, String email, String password, TextEditingController controller) async {
  try {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    controller.text = 'You have successfully created an account!'; 
    return true; 
  } catch (e) { 
    controller.text = '$e';   
    return false; 
  } 
}

// Sign In
Future<bool> signIn(context, String email, String password, TextEditingController controller) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password); 
    controller.text = 'You have successfully logged into your account!';  
    return true; 
  } catch (e) { 
    controller.text = '$e'; 
    return false; 
  }
}

// Sign Out
Future<void> signOut(BuildContext context, String text) async {
  await _auth.signOut(); 
}
