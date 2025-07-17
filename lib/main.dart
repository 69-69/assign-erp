import 'package:assign_erp/core/network/data_sources/local/cache_db_adaptor.dart';
import 'package:assign_erp/features/app.dart';
import 'package:assign_erp/features/auth/domain/repository/auth_repository.dart';
import 'package:assign_erp/features/refresh_entire_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

Future<void> main({bool testing = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;

  // Init Local DB/Cache all Server Operation data
  await cacheDBAdaptor();
  // await PrintoutService.init();

  // Disable screen orientation to PORTRAIT-UP ONLY
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Force System UI to use my defined colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Init Country Codes
  // await CountryCodes.init();

  // Note: to Override HTTPS security -> for dev only
  // HttpOverrides.global = MyHttpOverrides();
  // end-HttpOverrides dev only

  // Check if App is not in TEST MODE(Integration, Widget, Unit Testing)
  // isTesting = testing;

  final AuthRepository authRepository = AuthRepository(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );

  // Observe bloc changes
  // Bloc.observer = const AppBlocObserver();
  // Run the app: App()
  // Reload App via this Custom ReloadApp(child: App())
  runApp(
    RefreshEntireApp(
      child: App(fireStore: firestore, authRepo: authRepository),
    ),
  );
}

Future<void> initializeApp() async {
  FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Initialized-default-app $app');
}
