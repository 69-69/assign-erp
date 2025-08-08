import 'dart:async';

import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/remote/repository/data_repository.dart';
import 'package:assign_erp/features/trouble_shooting/data/data_sources/local/error_logs_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'firestore_event.dart';
part 'firestore_state.dart';

/// FirestoreBloc
///
class FirestoreBloc<T> extends Bloc<FirestoreEvent, FirestoreState<T>> {
  final DataRepository _dataRepository;
  final FirebaseFirestore _firestore;
  final String collectionPath;

  /// toCache/toJson Function [toCache]
  final Map<String, dynamic> Function(T data) toCache;

  /// toJson/toMap Function [toFirestore]
  final Map<String, dynamic> Function(T data) toFirestore;

  /// fromJson/fromMap Function [fromFirestore]
  final T Function(Map<String, dynamic> data, String documentId) fromFirestore;

  // Set up the stream subscription
  late StreamSubscription<List<CacheData>> _subscription;

  FirestoreBloc({
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
    required this.toCache,
  }) : _firestore = firestore,
       _dataRepository = DataRepository(
         firestore: firestore,
         collectionPath: collectionPath,
         collectionRef: firestore.collection(collectionPath),
       ),
       super(LoadingData<T>()) {
    _initialize();
    // Start loading data from Firestore-DB (Remote)
    // to LocalStorage/Cache (Hive) & refresh Cache
    // _dataRepository.refreshCacheData();

    _dataRepository.dataStream.listen(
      (cacheData) => add(_DataLoaded<T>(_toList(cacheData))),
    );
  }

  Future<void> _initialize() async {
    on<RefreshData<T>>(_onRefreshData);
    on<GetShortID<T>>(_onGetShortID);
    on<GetData<T>>(_onGetData);
    on<GetDataById<T>>(_onGetDataById);
    on<GetMultipleDataByIDs<T>>(_onGetMultipleDataByIDs);
    on<GetAllDataWithSameId<T>>(_onGetAllDataWithSameId);
    on<SearchData<T>>(_onSearchData);
    on<AddData<T>>(_onAddData);
    on<AddData<List<T>>>(_onAddMultipleData);
    on<UpdateData>(_onUpdateData);
    on<DeleteData>(_onDeleteData);
    on<_ShortIDLoaded<T>>(_onShortUIDLoaded);
    on<_DataLoaded<T>>(_onDataLoaded);
    on<_SingleDataLoaded<T>>(_onSingleDataLoaded);
    on<_DataLoadError>(_onDataLoadError);
  }

  Future<void> _onRefreshData(
    RefreshData<T> event,
    Emitter<FirestoreState> emit,
  ) async {
    emit(LoadingData<T>());
    try {
      // Trigger data refresh in the DataRepository
      await _dataRepository.refreshCacheData();

      // Fetch the updated data from the repository
      final snapshot = await _dataRepository.getAllCacheData().first;
      final data = _toList(snapshot);

      // Emit the loaded state with the refreshed data
      emit(DataLoaded<T>(data));
    } catch (e) {
      // Emit an error state in case of failure
      emit(DataError<T>(e.toString()));
    }
  }

  Future<void> _onGetShortID(
    GetShortID<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    emit(LoadingData<T>());

    try {
      /// Generate shortId for UI/UX Usage (ex: customer-id)
      var shortId = await _generateUniqueID(
        _firestore.collection(collectionPath),
      );

      if (shortId.isNotEmpty) {
        final data = fromFirestore({'shortId': shortId}, '');
        add(_ShortIDLoaded<T>(data));
      } else {
        emit(DataError<T>('Generating Short Id failed'));
      }
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  /// Load All Data Function [_onGetData]
  Future<void> _onGetData(
    GetData<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    emit(LoadingData<T>());

    try {
      _subscription = _dataRepository.getAllCacheData().listen(
        (snapshot) async {
          final data = _toList(snapshot);

          // Update internal state in the BLoC to reflect data loaded
          emit(DataLoaded<T>(data));

          // Trigger an event to handle the loaded data
          // add(_DataLoadedEvent<T>(data));

          // Optionally, emit another state or handle other logic
          // emit(DataAddedState<T>()); // For example, notify that data is added
        },
        onError: (e) {
          add(_DataLoadError('Error loading data: $e'));
        },
      );

      // Await for the subscription to be done (optional)
      await _subscription.asFuture();

      /*List<CacheData> firstData =  await _dataRepository.getAllData().first; // Ensure await

      final data = _listDoc(firstData);

      emit(DataLoadedState<T>(data));*/
    } catch (e) {
      emit(DataError<T>('Error loading data: $e'));
    } finally {
      // Ensure to cancel the subscription when it's no longer needed
      // This could be in the dispose() method of a widget or BLoC
      _subscription.cancel();
    }
  }

  /*Future<void> _onLoadData2(
      LoadDataEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    emit(LoadingState<T>());

    _dataRepository.getAllData().listen((snapshot) {
      final data = _listDoc(snapshot);

      // Added data to event
      add(_DataLoadedEvent<T>(data));
      // Notify that data is deleted
      emit(DataAddedState<T>());
    }, onError: (e) {
      add(_DataLoadErrorEvent('Error loading data: $e'));
    });
  }*/

  Future<void> _onGetMultipleDataByIDs(
    GetMultipleDataByIDs<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    emit(LoadingData<T>());
    try {
      final localDataList = await _dataRepository.getMultipleDataByIDs(
        event.documentIDs,
      );

      if (localDataList.isNotEmpty) {
        final data = _toList(localDataList);

        add(_DataLoaded<T>(data));
        // emit(DataLoadedState<T>(data));
      }
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  Future<void> _onGetDataById(
    GetDataById<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    emit(LoadingData<T>());
    try {
      final localData = await _dataRepository.getDataById(
        event.documentId,
        field: event.field,
      );

      if (localData != null) {
        final data = fromFirestore(localData.data, localData.id);
        add(_SingleDataLoaded<T>(data));
      } else {
        emit(DataError<T>('Document not found'));
      }
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  Future<void> _onGetAllDataWithSameId(
    GetAllDataWithSameId<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    emit(LoadingData<T>());
    try {
      final localData = await _dataRepository.getAllDataWithSameId(
        event.documentId,
        field: event.field,
      );

      if (localData.isNotEmpty) {
        final data = _toList(localData);
        emit(DataLoaded<T>(data));
      } else {
        emit(DataError<T>('Data not found'));
      }
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  Future<void> _onSearchData(
    SearchData<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    emit(LoadingData<T>());
    try {
      List<CacheData> data = await _dataRepository.searchData(
        field: event.field ?? '',
        query: event.query,
        optField: event.optField,
        auxField: event.auxField,
      );

      var localData = _toList(data);
      emit(DataLoaded<T>(localData));
      // emit(DataLoadedState<T>(data.cast<T>()));
    } catch (e) {
      emit(DataError<T>('Error searching data: $e'));
    }
  }

  Future<void> _onAddData(
    AddData<T> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    try {
      // Add data to Firestore and update local storage
      await _dataRepository.createData(toCache(event.data));

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data added
      emit(DataAdded<T>(message: 'Data added successfully'));
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  Future<void> _onAddMultipleData(
    AddData<List<T>> event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    try {
      for (var item in event.data) {
        // Add data to Firestore
        _dataRepository.createData(toCache(item));
      }

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data added
      emit(DataAdded<T>(message: 'Data added successfully'));
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  /// Note:: use Generic or Map data update
  Future<void> _onUpdateData(
    UpdateData event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    try {
      final isPartialUpdate = event.mapData?.isNotEmpty ?? false;
      final data = isPartialUpdate
          ? {'data': event.mapData}
          : toCache(event.data as T);

      await _dataRepository.updateData(
        event.documentId,
        data: data,
        isPartial: isPartialUpdate, // true if not a full model update
      );

      // Update State: Notify that data updated
      emit(DataUpdated<T>(message: 'data updated successfully'));
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  Future<void> _onDeleteData(
    DeleteData event,
    Emitter<FirestoreState<T>> emit,
  ) async {
    try {
      // Delete data from Firestore and update local storage
      await _dataRepository.deleteData(event.documentId);

      // Trigger LoadDataEvent to reload the data
      add(RefreshData<T>());
      // add(GetData<T>());

      // Update State: Notify that data deleted
      emit(DataDeleted<T>(message: 'data deleted successfully'));
    } catch (e) {
      emit(DataError<T>(e.toString()));
    }
  }

  void _onShortUIDLoaded(
    _ShortIDLoaded<T> event,
    Emitter<FirestoreState<T>> emit,
  ) {
    emit(SingleDataLoaded<T>(event.shortID));
  }

  void _onDataLoaded(_DataLoaded<T> event, Emitter<FirestoreState<T>> emit) {
    emit(DataLoaded<T>(event.data));
  }

  void _onSingleDataLoaded(
    _SingleDataLoaded<T> event,
    Emitter<FirestoreState<T>> emit,
  ) {
    emit(SingleDataLoaded<T>(event.data));
  }

  void _onDataLoadError(_DataLoadError event, Emitter<FirestoreState<T>> emit) {
    final errorLogCache = ErrorLogCache();
    errorLogCache.setError(error: event.error, fileName: 'firestore_bloc');
    emit(DataError<T>(event.error));
  }

  List<T> _toList(List<CacheData> cacheData) {
    return cacheData
        .map((cache) => fromFirestore(cache.data, cache.id))
        .toList();
  }

  Future<String> _generateUniqueID(CollectionReference ref) async {
    String shortId;
    final d = DateTime.now();

    while (true) {
      /*shortId = shortid.generate();
      final trimNewId = _replaceSpecialCharsWithRandomNumbers(shortId);*/
      shortId = '${d.second}${d.minute}-${d.year}${d.hour}${d.day}';
      DocumentSnapshot doc = await ref.doc(shortId).get();

      if (!doc.exists) {
        break;
      }
    }

    return shortId.toUpperCase();
  }

  /*String _replaceSpecialCharsWithRandomNumbers(String str) {
    // Create a random number generator
    final Random random = Random();
    // Define a regular expression to match non-alphanumeric characters
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
    // Use a function to replace matches with random numbers
    String result = str.replaceAllMapped(regExp, (Match match) {
      return random.nextInt(10).toString();
    });

    return result;
  }*/

  @override
  Future<void> close() {
    _dataRepository.cancelDataSubscription();
    return super.close();
  }
}

/* create and implement a cache or localStorage
using dart flutter hive_flutter package  and create
and implement a remote backup from the localStorage to
remote firestore based on the below firestoreBloc:

create and implement a CRUD local cache,
along with a CRUD remote backup to Firestore,
 based on the below firestoreBloc
using these packages: hive, hive_flutter,
path_provider, cloud_firestore, firebase_core, build_runner,
hive_generator package in Dart and Flutter,

*/

/* class FirestoreBloc<T> extends Bloc<FirestoreEvent, FirestoreState<T>> {
  final String collectionPath;
  final FirebaseFirestore _firestore;

  /// toJson/toMap Function [toFirestore]
  final Map<String, dynamic> Function(T data) toFirestore;

  /// fromJson/fromMap Function [fromFirestore]
  final T Function(Map<String, dynamic> data, String documentId) fromFirestore;

  StreamSubscription? _dataSubscription;

  FirestoreBloc({
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
  })  : _firestore = firestore,
        super(LoadingState<T>()) {
    on<LoadShortIDEvent<T>>(_onLoadShortID);
    on<LoadDataEvent<T>>(_onLoadData);
    on<LoadSingleDataEvent>(_onLoadSingleData);
    on<SearchDataEvent<T>>(_onSearchData);
    on<AddDataEvent<T>>(_onAddData);
    on<AddDataEvent<List<T>>>(_onAddMultipleData);
    on<UpdateDataEvent<T>>(_onUpdateData);
    on<UpdateSingleDataEvent<T>>(_onUpdateSingleData);
    on<DeleteDataEvent>(_onDeleteData);
    on<_ShortIDLoadedEvent<T>>(_onShortUIDLoaded);
    on<_DataLoadedEvent<T>>(_onDataLoaded);
    on<_SingleDataLoadedEvent<T>>(_onSingleDataLoaded);
    on<_DataLoadErrorEvent>(_onDataLoadError);
  }

  /// Load Generated Short-UID Function [_onLoadShortID]
  Future<void> _onLoadShortID(
      LoadShortIDEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    emit(LoadingState<T>());

    try {
      /// Generate shortId for UI/UX Usage (ex: customer-id)
      CollectionReference<Map<String, dynamic>> colRef =
          _firestore.collection(collectionPath);

      /// Generate short Unique-ID
      var shortId = await _generateUniqueID(colRef);

      if (shortId.isNotEmpty) {
        final data = fromFirestore({'shortId': shortId}, '');
        add(_ShortIDLoadedEvent<T>(data));
      } else {
        emit(ErrorState<T>('Generating Short Id failed'));
      }
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Load All Data Function [_onLoadData]
  Future<void> _onLoadData(
      LoadDataEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    emit(LoadingState<T>());
    await _dataSubscription?.cancel();
    _dataSubscription =
        _firestore.collection(collectionPath).snapshots().listen((snapshot) {
      final data = _listDoc(snapshot);

      add(_DataLoadedEvent<T>(data));
    }, onError: (e) {
      add(_DataLoadErrorEvent(e.toString()));
    });
  }

  /// Load Specific Data By Doc-Id Function [_onLoadSingleData]
  Future<void> _onLoadSingleData(
      LoadSingleDataEvent event, Emitter<FirestoreState<T>> emit) async {
    emit(LoadingState<T>());
    try {
      final doc = await _firestore
          .collection(collectionPath)
          .doc(event.documentId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = fromFirestore(doc.data()!, doc.id);
        // debugPrint('searched by docId: ${doc.id} ==$data');
        add(_SingleDataLoadedEvent<T>(data));
      } else {
        emit(ErrorState<T>('Document not found'));
      }
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Search Specific Data By field-Name [_onSearchData]
  Future<void> _onSearchData(
      SearchDataEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    emit(LoadingState<T>());
    try {
      /// First search using the first-field
      var querySnapshot = await _querySnapshot(event.field ?? '', event.query);
      var data = _listDoc(querySnapshot);

      /// If no results found...
      if (data.isEmpty) {
        /// then, search using the second-field
        if (event.optField != null) {
          querySnapshot =
              await _querySnapshot(event.optField ?? '', event.query);

          data = _listDoc(querySnapshot);

          /// If no results found, then search using the third-field
          if (event.auxField != null && data.isEmpty) {
            querySnapshot =
                await _querySnapshot(event.auxField ?? '', event.query);

            data = _listDoc(querySnapshot);
          } else {
            /// else, search using document-Id
            var docSnapshot = await _firestore
                .collection(collectionPath)
                .doc(event.query)
                .get();

            if (docSnapshot.exists && docSnapshot.data() != null) {
              data = _listDoc(querySnapshot);
            }
          }
        }
      }

      add(_DataLoadedEvent<T>(data));
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Search Helper Functions-1
  List<T> _listDoc(QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    return querySnapshot.docs
        .map((doc) => fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Search Helper Functions-2
  Future<QuerySnapshot<Map<String, dynamic>>> _querySnapshot(
      Object field, String query) async {
    return await _firestore
        .collection(collectionPath)
        .where(field, isGreaterThanOrEqualTo: query)
        .where(field, isGreaterThanOrEqualTo: '$query\uf8ff')
        .get();
  }

  Future<void> _onAddData2(
      AddDataEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    try {
      String? docId;

      CollectionReference<Map<String, dynamic>> colRef =
          _firestore.collection(collectionPath);

      /// NOTE: If 'documentId' is NULL/Empty, Generate shortId
      if (event.documentId.isNullOrEmpty) {
        /// Generate short Unique-ID
        docId ??= await _generateUniqueID(colRef);
      }

      /// else, 'documentId' is autoAssign, Firestore will auto-generate unique-ID (documentId)
      final docRef = colRef.doc(docId);

      final snapShot = await docRef.get();

      if (snapShot.exists) {
        emit(const ErrorState('Document already exists'));
      } else {
        final data = toCache(event.data);

        var cacheData = CacheData(id: docRef.id, data: data['data']);

        // Add data to Firestore and update local storage
        await _dataRepository.addData(cacheData);

        // Trigger LoadDataEvent to reload the data
        // add(LoadDataEvent<T>());

        // Update State: Notify that data added
        emit(DataAddedState<T>(message: 'Data added successfully'));
      }
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Add/Create New Data Function [_onAddData]
  Future<void> _onAddData(
      AddDataEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    try {
      String? docId;

      CollectionReference<Map<String, dynamic>> colRef =
          _firestore.collection(collectionPath);

      /// NOTE: If 'documentId' is NULL/Empty, Generate shortId
      if (event.documentId.isNullOrEmpty) {
        /// Generate short Unique-ID
        docId ??= await _generateUniqueID(colRef);
      }

      /// else, 'documentId' is autoAssign, Firestore will auto-generate unique-ID (documentId)

      DocumentReference<Map<String, dynamic>> docRef = colRef.doc(docId);

      final snapShot = await docRef.get();

      if (!snapShot.exists) {
        await docRef.set(toFirestore(event.data));
      }

      // Check if Product already exists, else create it
      // snapShot.exists ? snapShot : docRef.set(toFirestore(event.data));

      // _firestore.collection(collectionPath).add(toFirestore(event.data));
      emit(DataAddedState<T>());
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Add A List of New Data Function [_onAddMultipleData]
  Future<void> _onAddMultipleData(
      AddDataEvent<List<T>> event, Emitter<FirestoreState<T>> emit) async {
    try {
      CollectionReference<Map<String, dynamic>> colRef =
          _firestore.collection(collectionPath);

      for (var item in event.data) {
        colRef.add(toFirestore(item));
      }

      emit(DataAddedState<T>());
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Update Data Function [_onUpdateData]
  Future<void> _onUpdateData(
      UpdateDataEvent<T> event, Emitter<FirestoreState<T>> emit) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(event.documentId)
          .update(toFirestore(event.data));

      // Reload to show changes
      add(LoadDataEvent<T>());
      // Notify that data is updated
      emit(DataUpdatedState<T>());
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Update Single Field-Data Function [_onUpdateSingleData]
  /// Field-data(event.data) must be in Map: {'key':'value'}
  Future<void> _onUpdateSingleData(
      UpdateSingleDataEvent event, Emitter<FirestoreState<T>> emit) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(event.documentId)
          .update(event.data);

      // Reload to show changes
      add(LoadDataEvent<T>());
      // Notify that data is updated
      emit(DataUpdatedState<T>());
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  /// Delete Data Function [_onDeleteData]
  Future<void> _onDeleteData(
      DeleteDataEvent event, Emitter<FirestoreState<T>> emit) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(event.documentId)
          .delete();
      // Reload to show changes
      add(LoadDataEvent<T>());
      // Notify that data is deleted
      emit(DataDeletedState<T>());
    } catch (e) {
      emit(ErrorState<T>(e.toString()));
    }
  }

  void _onShortUIDLoaded(
      _ShortIDLoadedEvent<T> event, Emitter<FirestoreState<T>> emit) {
    emit(SingleDataLoadedState<T>(event.shortID));
  }

  void _onDataLoaded(
      _DataLoadedEvent<T> event, Emitter<FirestoreState<T>> emit) {
    emit(DataLoadedState<T>(event.data));
  }

  void _onSingleDataLoaded(
      _SingleDataLoadedEvent<T> event, Emitter<FirestoreState<T>> emit) {
    emit(SingleDataLoadedState<T>(event.data));
  }

  void _onDataLoadError(
      _DataLoadErrorEvent event, Emitter<FirestoreState<T>> emit) {
    emit(ErrorState<T>(event.error));
  }

  Future<String> _generateUniqueID(CollectionReference ref) async {
    String shortId;

    while (true) {
      // Generate a short, unique ID
      shortId = shortid.generate();

      final trimNewId = _replaceSpecialCharsWithRandomNumbers(shortId);

      // Check if a document with this ID already exists
      DocumentSnapshot doc = await ref.doc(trimNewId).get();

      if (!doc.exists) {
        break;
      }
    }

    return shortId.toUpperCase();
  }

  String _replaceSpecialCharsWithRandomNumbers(String str) {
    // Create a random number generator
    final Random random = Random();

    // Define a regular expression to match non-alphanumeric characters
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');

    // Use a function to replace matches with random numbers
    String result = str.replaceAllMapped(regExp, (Match match) {
      return random.nextInt(10).toString();
    });

    return result;
  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }
}*/
