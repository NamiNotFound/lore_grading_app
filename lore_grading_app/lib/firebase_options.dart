import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS config not configured yet.');
      default:
        return web;
    }
  }

  // Web config (placeholder)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: '576163519216',
    projectId: 'grading-app-ee894',
    authDomain: 'grading-app-ee894.firebaseapp.com',
    storageBucket: 'grading-app-ee894.firebasestorage.app',
  );

  // Android config from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB74NiHi32KkSPGuHc6R3oyXmPJkiC9dvQ',
    appId: '1:576163519216:android:30b65fff897fe7988d4035',
    messagingSenderId: '576163519216',
    projectId: 'grading-app-ee894',
    storageBucket: 'grading-app-ee894.firebasestorage.app',
  );
}
