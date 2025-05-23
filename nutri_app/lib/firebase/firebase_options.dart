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
    apiKey: 'AIzaSyDeGZLNjufr_fhsow-ZjWglXdxBPI7f2L8',
    appId: '1:386693907771:web:6266cae40803b0cc55a31e',
    messagingSenderId: '386693907771',
    projectId: 'nutriclin-f4e29',
    authDomain: 'nutriclin-f4e29.firebaseapp.com',
    storageBucket: 'nutriclin-f4e29.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAvyFXMsyMTI26pACuuErq_EsmBUCWrT6E',
    appId: '1:386693907771:ios:c5407af3d8669d9855a31e',
    messagingSenderId: '386693907771',
    projectId: 'nutriclin-f4e29',
    storageBucket: 'nutriclin-f4e29.firebasestorage.app',
    iosBundleId: 'com.example.nutriApp',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAvyFXMsyMTI26pACuuErq_EsmBUCWrT6E',
    appId: '1:386693907771:ios:c5407af3d8669d9855a31e',
    messagingSenderId: '386693907771',
    projectId: 'nutriclin-f4e29',
    storageBucket: 'nutriclin-f4e29.firebasestorage.app',
    iosBundleId: 'com.example.nutriApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAViaKtP-7ULdGMGvyfsNxoaaufrpvzL5Y',
    appId: '1:386693907771:android:9a441f722d90957255a31e',
    messagingSenderId: '386693907771',
    projectId: 'nutriclin-f4e29',
    storageBucket: 'nutriclin-f4e29.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDeGZLNjufr_fhsow-ZjWglXdxBPI7f2L8',
    appId: '1:386693907771:web:642e771dd0547bd855a31e',
    messagingSenderId: '386693907771',
    projectId: 'nutriclin-f4e29',
    authDomain: 'nutriclin-f4e29.firebaseapp.com',
    storageBucket: 'nutriclin-f4e29.firebasestorage.app',
  );

}