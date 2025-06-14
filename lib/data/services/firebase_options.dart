// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyAiKiRDzjkFekOH1q-6yONwJ1VoWc2kq9Q',
    appId: '1:670594355601:web:0c665f94c3c129157e0a30',
    messagingSenderId: '670594355601',
    projectId: 'notesonshort-a1980',
    authDomain: 'notesonshort-a1980.firebaseapp.com',
    storageBucket: 'notesonshort-a1980.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAa-2G5DW2cIA6oZm3QBXL4OYYchACzUSk',
    appId: '1:670594355601:android:b35a1873b57a59487e0a30',
    messagingSenderId: '670594355601',
    projectId: 'notesonshort-a1980',
    storageBucket: 'notesonshort-a1980.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBE9cBYHbO3AhIXgrIBMrNcanmQNxz4fAY',
    appId: '1:670594355601:ios:1c783ab49d4a03dc7e0a30',
    messagingSenderId: '670594355601',
    projectId: 'notesonshort-a1980',
    storageBucket: 'notesonshort-a1980.firebasestorage.app',
    iosBundleId: 'com.example.notesOnShort',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBE9cBYHbO3AhIXgrIBMrNcanmQNxz4fAY',
    appId: '1:670594355601:ios:1c783ab49d4a03dc7e0a30',
    messagingSenderId: '670594355601',
    projectId: 'notesonshort-a1980',
    storageBucket: 'notesonshort-a1980.firebasestorage.app',
    iosBundleId: 'com.example.notesOnShort',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAiKiRDzjkFekOH1q-6yONwJ1VoWc2kq9Q',
    appId: '1:670594355601:web:18bb619e62d127c97e0a30',
    messagingSenderId: '670594355601',
    projectId: 'notesonshort-a1980',
    authDomain: 'notesonshort-a1980.firebaseapp.com',
    storageBucket: 'notesonshort-a1980.firebasestorage.app',
  );
}
