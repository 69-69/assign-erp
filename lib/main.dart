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

/* Create multiple instances of DataRepository with different collection paths
  final employeeRepo = DataRepository(
    firestore: firestore,
    collectionPath: employeesDBCollectionPath,
  );

  final DataRepository productsRepo = DataRepository(
    firestore: firestore,
    collectionPath: productsDBCollectionPath,
  );

  final DataRepository ordersRepo = DataRepository(
    firestore: firestore,
    collectionPath: ordersDBCollectionPath,
  );

  final miscOrdersRepo = DataRepository(
    firestore: firestore,
    collectionPath: miscOrdersDBCollectionPath,
  );

  final DataRepository purchaseOrdersRepo = DataRepository(
    firestore: firestore,
    collectionPath: purchaseOrdersDBCollectionPath,
  );

  final deliveriesRepo = DataRepository(
    firestore: firestore,
    collectionPath: deliveryDBCollectionPath,
  );

  final salesRepo = DataRepository(
    firestore: firestore,
    collectionPath: salesDBCollectionPath,
  );

  final customersRepo = DataRepository(
    firestore: firestore,
    collectionPath: customersDBCollectionPath,
  );

  final companyStoresRepo = DataRepository(
    firestore: firestore,
    collectionPath: companyStoreDBCollectionPath,
  );

  final companyInfoRepo = DataRepository(
    firestore: firestore,
    collectionPath: companyInfoDBCollectionPath,
  );

  final supplierRepo = DataRepository(
    firestore: firestore,
    collectionPath: supplierDBCollectionPath,
  );

  final requestForQuoteRepo = DataRepository(
    firestore: firestore,
    collectionPath: requestPriceQuoteDBCollectionPath,
  );

  final posSaleRepo = DataRepository(
    firestore: firestore,
    collectionPath: posOrdersDBCollectionPath,
  );

  final posOrderRepo = DataRepository(
    firestore: firestore,
    collectionPath: posSalesDBCollectionPath,
  );

  /////
  employeeRepo: employeeRepo,
  productsRepo: productsRepo,
  miscOrdersRepo: miscOrdersRepo,
  purchaseOrdersRepo: purchaseOrdersRepo,
  deliveriesRepo: deliveriesRepo,
  ordersRepo: ordersRepo,
  salesRepo: salesRepo,
  customersRepo: customersRepo,
  companyStoresRepo: companyStoresRepo,
  companyInfoRepo: companyInfoRepo,
  requestForQuoteRepo: requestForQuoteRepo,
  supplierRepo: supplierRepo,
  posSaleRepo: posSaleRepo,
  posOrderRepo: posOrderRepo,
  */

/*Future<void> initializeSecondary() async {
  FirebaseApp secApp = await Firebase.initializeApp(
    name: 'secondary_app_init_key_',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Firebase.app('secondary_logged_in_user_key_1711641541418').delete();
  debugPrint('Initialized-second-app $secApp');
}*/

/*class AppBlocObserver extends BlocObserver {
  /// {@macro app_bloc_observer}
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) debugPrint('Steve-Cubit-Observer: $change');
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc,
      Transition<dynamic, dynamic> transition,
      ) {
    super.onTransition(bloc, transition);
    debugPrint('Steve-Bloc-Observer: $transition');
  }
}*/
