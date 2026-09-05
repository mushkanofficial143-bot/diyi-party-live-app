import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDG_wXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:web:abcdefghijklmnopqrst',
    messagingSenderId: '1234567890',
    projectId: 'diyo-party-live',
    authDomain: 'diyo-party-live.firebaseapp.com',
    storageBucket: 'diyo-party-live.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDG_wXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:android:abcdefghijklmnopqrst',
    messagingSenderId: '1234567890',
    projectId: 'diyo-party-live',
    storageBucket: 'diyo-party-live.appspot.com',
  );
}
