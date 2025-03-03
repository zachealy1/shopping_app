
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
    apiKey: 'AIzaSyD74RTC_XjdktMAz6LXg3GgvP46jVs9970',
    appId: '1:1016956675331:web:b4609672cf128b29d3f536',
    messagingSenderId: '1016956675331',
    projectId: 'shopit-5aba6',
    authDomain: 'shopit-5aba6.firebaseapp.com',
    storageBucket: 'shopit-5aba6.firebasestorage.app',
    measurementId: 'G-E1JYQZ477F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAZV4w8Qr8SN6VFh04E2ysJ9_KKUPYDyg',
    appId: '1:1016956675331:android:f1b64e1c5823f4b2d3f536',
    messagingSenderId: '1016956675331',
    projectId: 'shopit-5aba6',
    storageBucket: 'shopit-5aba6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBH5Ij4yiwdDcncmClZL6cDF8pTSY2s_fU',
    appId: '1:1016956675331:ios:d8697ba3fae0f367d3f536',
    messagingSenderId: '1016956675331',
    projectId: 'shopit-5aba6',
    storageBucket: 'shopit-5aba6.firebasestorage.app',
    iosBundleId: 'com.shopit.shoppingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBH5Ij4yiwdDcncmClZL6cDF8pTSY2s_fU',
    appId: '1:1016956675331:ios:d8697ba3fae0f367d3f536',
    messagingSenderId: '1016956675331',
    projectId: 'shopit-5aba6',
    storageBucket: 'shopit-5aba6.firebasestorage.app',
    iosBundleId: 'com.shopit.shoppingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD74RTC_XjdktMAz6LXg3GgvP46jVs9970',
    appId: '1:1016956675331:web:5ab3e024caad84d1d3f536',
    messagingSenderId: '1016956675331',
    projectId: 'shopit-5aba6',
    authDomain: 'shopit-5aba6.firebaseapp.com',
    storageBucket: 'shopit-5aba6.firebasestorage.app',
    measurementId: 'G-54DQ403BPF',
  );
}
