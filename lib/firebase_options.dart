// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAeWrq8Mz211_WdojalZX69aH7l-lXe2ZI',
    appId: '1:919102999079:web:39d37bc2d89d3c81d61c02',
    messagingSenderId: '919102999079',
    projectId: 'flutter-df8aa',
    authDomain: 'flutter-df8aa.firebaseapp.com',
    storageBucket: 'flutter-df8aa.appspot.com',
    measurementId: 'G-QQ00SDG2VB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCI6zMkHpLCpprADh5GbMtOHJIFwKP16_I',
    appId: '1:919102999079:android:496977db79ffe241d61c02',
    messagingSenderId: '919102999079',
    projectId: 'flutter-df8aa',
    storageBucket: 'flutter-df8aa.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAPdWC7BbckfRtvxVi2erlkmIF125dc9LU',
    appId: '1:919102999079:ios:174272994dcaa410d61c02',
    messagingSenderId: '919102999079',
    projectId: 'flutter-df8aa',
    storageBucket: 'flutter-df8aa.appspot.com',
    iosBundleId: 'com.example.flutterRestaurapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAPdWC7BbckfRtvxVi2erlkmIF125dc9LU',
    appId: '1:919102999079:ios:174272994dcaa410d61c02',
    messagingSenderId: '919102999079',
    projectId: 'flutter-df8aa',
    storageBucket: 'flutter-df8aa.appspot.com',
    iosBundleId: 'com.example.flutterRestaurapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAeWrq8Mz211_WdojalZX69aH7l-lXe2ZI',
    appId: '1:919102999079:web:8a8abfa5cedb271dd61c02',
    messagingSenderId: '919102999079',
    projectId: 'flutter-df8aa',
    authDomain: 'flutter-df8aa.firebaseapp.com',
    storageBucket: 'flutter-df8aa.appspot.com',
    measurementId: 'G-YRDRR108LM',
  );
}
