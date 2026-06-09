import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Replace values by running: dart pub global activate flutterfire_cli && flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA09qsALt3E5jTsCBxYeroKXVLpMUPQg7I',
    authDomain: 'paarth-hcm.firebaseapp.com',
    projectId: 'paarth-hcm',
    storageBucket: 'paarth-hcm.firebasestorage.app',
    messagingSenderId: '41365150454',
    appId: '1:41365150454:web:33ed8339496fff711eaad7',
    measurementId: 'G-Y85GNP2PH8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJHN29vu_IHBJbrRIsLPFSUFDV2dQcCnA',
    appId: '1:41365150454:android:7384ffc6a4cc2e7f1eaad7',
    messagingSenderId: '41365150454',
    projectId: 'paarth-hcm',
    storageBucket: 'paarth-hcm.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'macha-f890f',
    storageBucket: 'macha-f890f.firebasestorage.app',
    iosBundleId: 'com.paarthholidays.client.paarthHolidays',
  );
}
