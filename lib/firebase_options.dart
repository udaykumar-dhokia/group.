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
    apiKey: 'AIzaSyB75KRqMRme7zZNpGEJzwlF9USG-DQnrxQ',
    appId: '1:930848386622:web:b39cdd3ef38bd6438bab6f',
    messagingSenderId: '930848386622',
    projectId: 'group-5afb4',
    authDomain: 'group-5afb4.firebaseapp.com',
    storageBucket: 'group-5afb4.appspot.com',
    measurementId: 'G-MRLKT5Z4HG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfWZ9XL3BNLhLVoeZ2LAHFg8-EadEZe8A',
    appId: '1:930848386622:android:c21f6511b14a93d08bab6f',
    messagingSenderId: '930848386622',
    projectId: 'group-5afb4',
    storageBucket: 'group-5afb4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAaPk7MhGh9ZheXAlXTFoRe0xONnVCdA_8',
    appId: '1:930848386622:ios:f521265b3a5dc6508bab6f',
    messagingSenderId: '930848386622',
    projectId: 'group-5afb4',
    storageBucket: 'group-5afb4.appspot.com',
    iosBundleId: 'com.example.group',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAaPk7MhGh9ZheXAlXTFoRe0xONnVCdA_8',
    appId: '1:930848386622:ios:f521265b3a5dc6508bab6f',
    messagingSenderId: '930848386622',
    projectId: 'group-5afb4',
    storageBucket: 'group-5afb4.appspot.com',
    iosBundleId: 'com.example.group',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB75KRqMRme7zZNpGEJzwlF9USG-DQnrxQ',
    appId: '1:930848386622:web:9815f276bf0454c48bab6f',
    messagingSenderId: '930848386622',
    projectId: 'group-5afb4',
    authDomain: 'group-5afb4.firebaseapp.com',
    storageBucket: 'group-5afb4.appspot.com',
    measurementId: 'G-7YMPRB2NXM',
  );
}
