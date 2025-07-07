import 'dart:async';

import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/remote/repository/firestore_helper.dart';
import 'package:assign_erp/core/network/data_sources/remote/repository/firestore_repository.dart';
import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AgentRepository extends FirestoreRepository {
  late final Box<CacheData> _cacheBox;

  final CollectionType? collectionType;

  final String collectionPath;
  final FirebaseFirestore firestore;
  StreamSubscription? _dataSubscription;

  final StreamController<List<CacheData>> _dataController =
      StreamController<List<CacheData>>.broadcast();
  bool _isDataControllerClosed = false;

  Stream<List<CacheData>> get dataStream => _dataController.stream;

  AgentRepository({
    this.collectionType,
    required this.firestore,
    required this.collectionPath,
    super.collectionRef,
  }) : super(
         collectionType: collectionType,
         firestore: firestore,
         collectionPath: collectionPath,
       ) {
    _init();
  }

  Future<void> _init() async {
    _cacheBox = await _openCacheBox();
    refreshCacheData();
  }

  /** PRIVATE METHODS */

  /// Track last emitted data
  List<CacheData>? _lastEmittedData;

  /// Open/Create Cache Hive-Box [_openCacheBox]
  Future<Box<CacheData>> _openCacheBox() async {
    if (!Hive.isBoxOpen(collectionPath)) {
      return await Hive.openBox<CacheData>(collectionPath);
    }
    return Hive.box<CacheData>(collectionPath);
  }

  /// Emit Data / Add Event to Stream [_emitDataToStream]
  void _emitDataToStream() {
    if (!_isDataControllerClosed) {
      final data = _getFromCache();
      // Emit only if data has changed to avoid duplicate entries in the UI
      if (!listEquals(data, _lastEmittedData)) {
        _dataController.add(data);
        _lastEmittedData = data;
      }
    }
  }

  /// Add to Cache/localStorage [_addToCache]
  /// [key] - The ID of the document to be added to the cache.
  Future<void> _addToCache(String key, CacheData cacheData) async {
    await _cacheBox.put(key, cacheData);
  }

  /// Read/Get all cache data [_getFromCache]
  List<CacheData> _getFromCache() {
    return _cacheBox.values.toList();
  }

  /// Read/Get cache data by id [_getCacheById]
  CacheData? _getCacheById(String id) => _cacheBox.get(id);

  /// Read/Get cache data by index position [_getCacheByIndex]
  CacheData? _getCacheByIndex(int i) => _cacheBox.getAt(i);

  /// Add New BackUp Data to Remote-Server (Firestore) [_backupNewDataToFirestore]
  Future<String> _backupNewDataToFirestore(CacheData item) async {
    final id = (await addData(item.data)).id;
    return id;
  }

  /// Update BackUp Data to Remote-Server (Firestore) [_updateBackupDataToFirestore]
  Future<void> _updateBackupDataToFirestore(CacheData item) async {
    await updateById(item.id, data: item.data);
  }

  /// Helper function to search in local HiveBox
  List<CacheData> _searchLocalCache(Object field, String query) {
    List<CacheData> dataList = [];

    for (int i = 0; i < _cacheBox.length; i++) {
      final cachedData = _getCacheByIndex(i);
      if (cachedData != null && cachedData.data.containsKey(field)) {
        dynamic fieldValue = cachedData.data[field];
        if (fieldValue.toString().toLowerCase().contains(query.toLowerCase())) {
          dataList.add(cachedData);
        }
      }
    }

    return dataList;
  }

  /// Helper function to search in Firestore
  Future<List<CacheData>> _searchRemote(
    Object field,
    String term,
    Object? optField,
    Object? auxField,
  ) async {
    List<CacheData> dataList = [];

    try {
      var querySnapshot = await searchAll(field, term: term);

      if (querySnapshot.size > 0) {
        dataList = _toList(querySnapshot);
      }

      if (dataList.isEmpty && optField != null) {
        querySnapshot = await searchAll(optField, term: term);

        dataList = _toList(querySnapshot);

        if (dataList.isEmpty && auxField != null) {
          querySnapshot = await searchAll(auxField, term: term);
          dataList = _toList(querySnapshot);
        } else if (dataList.isEmpty) {
          var docSnapshot = await findById(term);
          if (docSnapshot.exists && docSnapshot.data() != null) {
            dataList.add(_fromMap(docSnapshot.data()!, docSnapshot.id));
          }
        }
      }
      return dataList;
    } catch (e) {
      return [];
    }
  }

  /// Convert QuerySnapshot to `List<CacheData>` [_toList]
  List<CacheData> _toList(QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    return querySnapshot.size > 0
        ? querySnapshot.docs.map((doc) => _fromMap(doc.data(), doc.id)).toList()
        : [];
  }

  CacheData _fromMap(Map<String, dynamic> data, String id) =>
      CacheData.fromMap(data, documentId: id);

  /// Update/Push to Cache / LocalStorage [_updateCacheWithData]
  void _updateCacheWithData(List<CacheData> data) {
    for (var model in data) {
      _addToCache(model.id, model); // Add or update each item in the cache
    }
    _emitDataToStream(); // Update the stream with the latest data
  }

  /** PUBLIC METHODS */

  /// Add/Create New Data Function [createData]
  Future<void> createData(Map<String, dynamic> data) async {
    final cacheData = CacheData.fromCache(data, '');

    // Add to remote DB
    final docId = await _backupNewDataToFirestore(cacheData);
    // Add to Cache/localStorage
    await _addToCache(docId, cacheData);
    // Update the stream with the latest data
    _emitDataToStream();
  }

  /// Update/Modify Data Function [updateData]
  Future<void> updateData(String id, Map<String, dynamic> data) async {
    final cacheData = CacheData.fromCache(data, id);

    await _addToCache(cacheData.id, cacheData); // Add to Cache/localStorage
    await _updateBackupDataToFirestore(cacheData); // Update to remote DB
    _emitDataToStream(); // Update the stream with the latest data
  }

  /// Delete/Remove Data Function [deleteData]
  Future<void> deleteData(String id) async {
    await _cacheBox.delete(id); // Delete from cache
    await deleteById(id); // Delete from remote Firestore-DB
    _emitDataToStream(); // Update the stream with the latest data
  }

  /// Get All Data [getAllData]
  Stream<List<CacheData>> getAllData() {
    _emitDataToStream();
    return dataStream;
  }

  /// Get All Data By ParentId [getAllByParentId]
  Future<List<CacheData>> getAllByParentId() async {
    List<CacheData> dataList = [];
    final querySnapshot = await findAllByParentId();
    if (querySnapshot.size > 0) {
      dataList = _toList(querySnapshot);
    }
    return dataList;
  }

  /// Get Multiple Data by IDs [getMultipleDataByIDs]
  Future<List<CacheData>> getMultipleDataByIDs(List<String> ids) async {
    List<CacheData> dataList = [];

    for (String id in ids) {
      CacheData? cacheData = _getCacheById(id);

      if (cacheData != null) {
        dataList.add(cacheData);
      } else {
        final docSnapshot = await findById(id);

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = _fromMap(docSnapshot.data()!, docSnapshot.id);
          await _addToCache(id, data);

          dataList.add(data);
        }
      }
    }
    _emitDataToStream();
    return dataList;
  }

  /// Get All Data with Same ID [getAllDataWithSameId]
  Future<List<CacheData>> getAllDataWithSameId(
    String id, {
    Object? field,
  }) async {
    List<CacheData> dataList = [];

    if (field != null && field.toString().isNotEmpty) {
      for (int i = 0; i < _cacheBox.length; i++) {
        final cachedData = _getCacheByIndex(i);

        if (cachedData != null && cachedData.id == id) {
          dataList.add(cachedData);
        } else {
          final querySnapshot = await findAllByAny(field, term: id);

          if (querySnapshot.size > 0) {
            dataList = _toList(querySnapshot);
            _emitDataToStream();
          }
        }
      }
    }
    return dataList;
  }

  /// ⚠️ Note:
  /// - Firestore limits `whereIn` to a maximum of 30 IDs per query + Cost.
  ///   So, if you need to fetch more than 30 documents, you must batch the calls like this [getMultiDataByIds]:
  Future<List<CacheData>> getMultiDataByIds(List<String> ids) async {
    List<CacheData> cached = [];
    List<String> missingIds = [];

    // 1. Get from Cache
    for (String id in ids) {
      final data = _getCacheById(id);
      if (data != null) {
        cached.add(data);
      } else {
        missingIds.add(id);
      }
    }

    // 2. If missing, fetch from Firestore in chunks
    if (missingIds.isNotEmpty) {
      const int batchSize = 30;
      final List<List<String>> chunks = [];

      for (int i = 0; i < missingIds.length; i += batchSize) {
        final end = (i + batchSize < missingIds.length)
            ? i + batchSize
            : missingIds.length;
        chunks.add(missingIds.sublist(i, end));
      }

      // Fetch all in parallel
      final futures = chunks.map((chunk) async {
        final snapshot = await findManyByIds(ids: chunk);
        return snapshot.docs.map((doc) {
          final data = CacheData.fromMap(doc.data(), documentId: doc.id);
          _addToCache(doc.id, data); // Add to cache
          return data;
        }).toList();
      });

      final fetchedChunks = await Future.wait(futures);
      final fetched = fetchedChunks.expand((e) => e).toList();
      cached.addAll(fetched);
    }

    // 3. Emit updated data if changed
    _emitDataToStream();

    return cached;
  }

  Future<List<CacheData>> getClientWorkspacesByAgent() async {
    final clientSnapshot = await findAllByParentId();
    if (clientSnapshot.size == 0) return [];

    // Step 1: Extract client data maps
    final clientDataList = clientSnapshot.docs
        .map((doc) => doc.data())
        .toList();

    // Step 2: Extract workspace IDs
    final workspaceIds = clientDataList
        .map((c) => c['clientWorkspaceId'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    // Step 3: Get cached + missing workspace data
    final cached = <CacheData>[];
    final missingIds = <String>[];

    for (final id in workspaceIds) {
      final cachedData = _getCacheById(id);
      bool isValid =
          cachedData != null && cachedData.data['clientWorkspace'] != null;
      if (isValid) {
        cached.add(cachedData);
        prettyPrint('✅ Cached workspace doc', cachedData.data);
      } else {
        missingIds.add(id);
        prettyPrint('❌ Missing workspace doc', id);
      }
    }

    // Step 4: Batch fetch from Firestore if needed
    const batchSize = 30;
    final List<List<String>> chunks = [];

    for (int i = 0; i < missingIds.length; i += batchSize) {
      final end = (i + batchSize < missingIds.length)
          ? i + batchSize
          : missingIds.length;
      chunks.add(missingIds.sublist(i, end));
    }

    final futures = chunks.map((chunk) async {
      final snapshot = await _workspacesRef(ids: chunk); // Fetch workspace docs
      return snapshot.docs
          .map((doc) => CacheData.fromMap(doc.data(), documentId: doc.id))
          .toList();
    });

    final fetchedChunks = await Future.wait(futures);
    final fetched = fetchedChunks.expand((e) => e).toList();
    cached.addAll(fetched);

    // Step 5: Create map for merging
    final workspaceMap = {for (var ws in cached) ws.id: ws.data};

    // Step 6: Merge and wrap into CacheData
    final List<CacheData> enrichedCacheData = clientDataList.map((client) {
      final workspaceId = client['clientWorkspaceId'];
      final workspaceData = workspaceMap[workspaceId];

      final enrichedMap = {
        'clientWorkspaceId': workspaceId,
        'commission': client['commission'] ?? [],
        'assignedAt': client['assignedAt'],
        'clientWorkspace': workspaceData,
      };
      final enriched = CacheData(id: workspaceId, data: enrichedMap);
      _addToCache(
        workspaceId,
        enriched,
      ); // ✅ Now cache full enriched client+workspace

      // prettyPrint('📌 Merged map', enrichedMap);
      return enriched;
    }).toList();

    /*prettyPrint(
      '✅ Repo loadedData',enrichedCacheData.map((e) => e.data).join('\n'),
    );*/

    return enrichedCacheData;
  }

  // get all workspaces if role is developer
  Future<List<CacheData>> getAllClientsWorkspaces() async {
    final snapshot = await _workspacesRef(isDeveloper: true);
    return snapshot.docs.map((doc) {
      final data = CacheData.fromMap(doc.data(), documentId: doc.id);
      _addToCache(doc.id, data); // Add to cache
      return data;
    }).toList();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _workspacesRef({
    List<String> ids = const [],
    bool isDeveloper = false,
  }) {
    final fireHelper = FirestoreHelper();
    final collectionRef = fireHelper.getCollectionRef(
      collectionType: CollectionType.global,
      workspaceUserDBCollectionPath,
    );
    return isDeveloper
        ? collectionRef.get()
        : collectionRef.where(FieldPath.documentId, whereIn: ids).get();
  }

  /// Get Single Data by ID [getDataById]
  Future<CacheData?> getDataById(String id, {Object? field}) async {
    CacheData? data = _getCacheById(id);

    if (data != null) {
      return data;
    } else {
      if (field != null && field.toString().isNotEmpty) {
        final query = await findOneByAny(field, term: id);

        final data = _toList(query).firstOrNull;
        if (data != null) {
          await _addToCache(data.id, data);
          return data;
        }
      } else {
        final docSnapshot = await findById(id);
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = _fromMap(docSnapshot.data()!, docSnapshot.id);
          await _addToCache(id, data);
          return data;
        }
        return null;
      }
    }
    return null;
  }

  /// Search Specific Data By field-Name(s) [searchData]
  Future<List<CacheData>> searchData({
    required Object field,
    required String query,
    Object? optField,
    Object? auxField,
  }) async {
    try {
      List<CacheData> dataList = [];

      dataList = _searchLocalCache(field, query);

      if (dataList.isEmpty) {
        dataList = await _searchRemote(field, query, optField, auxField);
      }

      return dataList;
    } catch (e) {
      throw Exception('Error searching dataList: $e');
    }
  }

  /// Manually BackUp Data by Admin/User using Button Click to Remote-Server (Firestore) [manualBackupDataToFirestore]
  Future<void> manualBackupDataToFirestore() async {
    try {
      final allData = _getFromCache();
      // final firestore = _subscriberRepository.firestore; // Get the Firestore instance
      final batch = firestore.batch();
      final snapshot = await findAll();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      for (final data in allData) {
        await updateById(data.id, data: data.data);
      }
    } catch (e) {
      // Handle the error appropriately
    }
  }

  /// Load Remote Data to Cache / LocalStorage [refreshCacheData]
  Future<void> refreshCacheData({Completer<void>? completer}) async {
    await _dataSubscription?.cancel();

    _dataSubscription = getDataStream().listen(
      (snapshot) {
        final List<CacheData> data = _toList(snapshot);
        // Add Data to Cache/LocalStorage
        _updateCacheWithData(data);
        completer?.complete(); //Notify once update is done
        // Emit updated data to stream
        // _emitDataToStream();
      },
      onError: (e) {
        debugPrint('Data-Repository Error: $e');
        completer?.completeError(e); // Optional: report error
      },
    );
  }

  /// Dispose or cancel Subscription [cancelDataSubscription]
  void cancelDataSubscription() {
    _dataSubscription?.cancel();
    _closeStreamController();
  }

  /// Close the stream controller [_closeStreamController]
  void _closeStreamController() {
    if (!_isDataControllerClosed) {
      _dataController.close();
      _isDataControllerClosed = true;
    }
  }
}
