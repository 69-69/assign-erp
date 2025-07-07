import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/local/index.dart';
import 'package:hive_flutter/adapters.dart';

/// This is the Cache-Data for all CRUD operation [cacheDBAdaptor]
Future<void> cacheDBAdaptor() async {
  // Initialize Hive
  await Hive.initFlutter(appCacheDirectory);

  // Register all adapters
  Hive.registerAdapter(CacheDataAdapter());
  Hive.registerAdapter(SetupPrintOutAdapter());

  // Define a list of box names for CacheData
  final cacheDataBoxes = [
    workspaceUserDBCollectionPath,
    employeesDBCollectionPath,
    companyStoreDBCollectionPath,
    companyInfoDBCollectionPath,
    supplierDBCollectionPath,
    categoryDBCollectionPath,
    customersDBCollectionPath,
    invoiceDBCollectionPath,
    productsDBCollectionPath,
    salesDBCollectionPath,
    deliveryDBCollectionPath,
    ordersDBCollectionPath,
    miscOrdersDBCollectionPath,
    purchaseOrdersDBCollectionPath,
    requestPriceQuoteDBCollectionPath,
    posSalesDBCollectionPath,
    posOrdersDBCollectionPath,
    userManualDBCollectionPath,
    liveChatSupportDBCollectionPath,
    backupFileNamesCache,
    appErrorLogsCache,
    agentClientsDBCollection,
  ];

  // Open AuthCache hiveBox: for Authentication
  await Hive.openBox<CacheData>(userAuthCache);

  // Open DeviceCache hiveBox: for User Device Id
  await Hive.openBox<CacheData>(deviceInfoCache);

  // Open SetupPrintOut hiveBox: for PDFs & Printout Setup
  await Hive.openBox<SetupPrintOut>(printoutSetupCache);

  // Open all CacheData hiveBoxes for app CRUD operations
  await Future.wait(
    cacheDataBoxes.map((path) => Hive.openBox<CacheData>(path)),
  );
}
