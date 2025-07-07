import 'dart:async';

import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/local/error_logs_cache.dart';
import 'package:assign_erp/features/setup/domain/repository/setup_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'setup_event.dart';
part 'setup_state.dart';

/// SetupBloc
///
class SetupBloc<T> extends Bloc<SetupEvent, SetupState<T>> {
  final SetupRepository _setupRepository;
  // final FirebaseFirestore _firestore;
  final String collectionPath;

  /// toCache/toJson Function [toCache]
  final Map<String, dynamic> Function(T data) toCache;

  /// toJson/toMap Function [toFirestore]
  final Map<String, dynamic> Function(T data) toFirestore;

  /// fromJson/fromMap Function [fromFirestore]
  final T Function(Map<String, dynamic> data, String documentId) fromFirestore;

  // Set up the stream subscription
  late StreamSubscription<List<CacheData>> _subscription;

  SetupBloc({
    required FirebaseFirestore firestore,
    // required String collectionPath,
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
    required this.toCache,
  }) : /*_firestore = firestore,*/
       _setupRepository = SetupRepository(
         firestore: firestore,
         collectionPath: collectionPath,
       ),
       super(LoadingSetup<T>()) {
    _initialize();

    _setupRepository.dataStream.listen(
      (cacheData) => add(_SetupLoaded<T>(_toList(cacheData))),
    );
  }

  Future<void> _initialize() async {
    // on<GetShortIDEvent<T>>(_onGetShortID);
    on<RefreshSetup<T>>(_onRefreshSetup);
    on<GetSetup<T>>(_onGetSetup);
    on<GetSetupById<T>>(_onGetSetupById);
    on<GetMultiSetupByIDs<T>>(_onGetMultiSetupByIDs);
    on<GetAllSetupWithSameId<T>>(_onGetAllSetupWithSameId);
    on<SearchSetup<T>>(_onSearchSetup);
    on<AddSetup<T>>(_onAddSetup);
    on<AddSetup<List<T>>>(_onAddMultiSetup);
    on<UpdateSetup>(_onUpdateSetup);
    on<DeleteSetup>(_onDeleteSetup);
    on<_ShortIDLoaded<T>>(_onShortUIDLoaded);
    on<_SetupLoaded<T>>(_onSetupLoaded);
    on<_SingleSetupLoaded<T>>(_onSingleSetupLoaded);
    on<_SetupLoadError>(_onSetupLoadError);
  }

  Future<void> _onRefreshSetup(
    RefreshSetup<T> event,
    Emitter<SetupState> emit,
  ) async {
    emit(LoadingSetup<T>());
    try {
      // Trigger data refresh in the DataRepository
      await _setupRepository.refreshCacheData();

      // Fetch the updated data from the repository
      final snapshot = await _setupRepository.getAllData().first;
      final data = _toList(snapshot);

      // Emit the loaded state with the refreshed data
      emit(SetupLoaded<T>(data));
    } catch (e) {
      // Emit an error state in case of failure
      emit(SetupError<T>(e.toString()));
    }
  }

  /// Load All Data Function [_onGetSetup]
  Future<void> _onGetSetup(
    GetSetup<T> event,
    Emitter<SetupState<T>> emit,
  ) async {
    emit(LoadingSetup<T>());

    try {
      _subscription = _setupRepository.getAllData().listen(
        (snapshot) async {
          final data = _toList(snapshot);

          // Update internal state in the BLoC to reflect data loaded
          emit(SetupLoaded<T>(data));

          // Trigger an event to handle the loaded data
          // add(_SetupLoadedEvent<T>(data));

          // Optionally, emit another state or handle other logic
          // emit(SetupAddedState<T>()); // For example, notify that data is added
        },
        onError: (e) {
          add(_SetupLoadError('Error loading data: $e'));
        },
      );

      // Await for the subscription to be done (optional)
      await _subscription.asFuture();
    } catch (e) {
      emit(SetupError<T>('Error loading data: $e'));
    } finally {
      // Ensure to cancel the subscription when it's no longer needed
      // This could be in the dispose() method of a widget or BLoC
      _subscription.cancel();
    }
  }

  Future<void> _onGetMultiSetupByIDs(
    GetMultiSetupByIDs<T> event,
    Emitter<SetupState<T>> emit,
  ) async {
    emit(LoadingSetup<T>());
    try {
      final localDataList = await _setupRepository.getMultipleDataByIDs(
        event.documentIDs,
      );

      if (localDataList.isNotEmpty) {
        final data = _toList(localDataList);

        add(_SetupLoaded<T>(data));
        // emit(DataLoadedState<T>(data));
      }
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  Future<void> _onGetSetupById(
    GetSetupById<T> event,
    Emitter<SetupState<T>> emit,
  ) async {
    emit(LoadingSetup<T>());
    try {
      final localData = await _setupRepository.getDataById(
        event.documentId,
        field: event.field,
      );

      if (localData != null) {
        final data = fromFirestore(localData.data, localData.id);
        add(_SingleSetupLoaded<T>(data));
      } else {
        emit(SetupError<T>('Document not found'));
      }
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  Future<void> _onGetAllSetupWithSameId(
    GetAllSetupWithSameId<T> event,
    Emitter<SetupState<T>> emit,
  ) async {
    emit(LoadingSetup<T>());
    try {
      final localData = await _setupRepository.getAllDataWithSameId(
        event.documentId,
        field: event.field,
      );

      if (localData.isNotEmpty) {
        final data = _toList(localData);
        emit(SetupLoaded<T>(data));
      } else {
        emit(SetupError<T>('Data not found'));
      }
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  Future<void> _onSearchSetup(
    SearchSetup<T> event,
    Emitter<SetupState<T>> emit,
  ) async {
    emit(LoadingSetup<T>());
    try {
      List<CacheData> data = await _setupRepository.searchData(
        field: event.field ?? '',
        query: event.query,
        optField: event.optField,
        auxField: event.auxField,
      );

      var localData = _toList(data);
      emit(SetupLoaded<T>(localData));
      // emit(DataLoadedState<T>(data.cast<T>()));
    } catch (e) {
      emit(SetupError<T>('Error searching data: $e'));
    }
  }

  Future<void> _onAddSetup(
    AddSetup<T> event,
    Emitter<SetupState<T>> emit,
  ) async {
    try {
      // Add data to Firestore and update local storage
      await _setupRepository.createData(toCache(event.data));

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data added
      emit(SetupAdded<T>(message: 'Data added successfully'));
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  Future<void> _onAddMultiSetup(
    AddSetup<List<T>> event,
    Emitter<SetupState<T>> emit,
  ) async {
    try {
      for (var item in event.data) {
        // Add data to Firestore
        _setupRepository.createData(toCache(item));
      }

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data added
      emit(SetupAdded<T>(message: 'Data added successfully'));
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  /// Note:: use Generic or Map data update
  Future<void> _onUpdateSetup(
    UpdateSetup event,
    Emitter<SetupState<T>> emit,
  ) async {
    try {
      // Update data in Firestore and update local storage
      final data = event.mapData != null
          ? {'data': event.mapData} // Create a toCache format
          : toCache(event.data as T);

      await _setupRepository.updateData(event.documentId, data);

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data updated
      emit(SetupUpdated<T>(message: 'data updated successfully'));
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  Future<void> _onDeleteSetup(
    DeleteSetup event,
    Emitter<SetupState<T>> emit,
  ) async {
    try {
      // Delete data from Firestore and update local storage
      await _setupRepository.deleteData(event.documentId);

      // Trigger LoadDataEvent to reload the data
      add(GetSetup<T>());

      // Update State: Notify that data deleted
      emit(SetupDeleted<T>(message: 'data deleted successfully'));
    } catch (e) {
      emit(SetupError<T>(e.toString()));
    }
  }

  void _onShortUIDLoaded(_ShortIDLoaded<T> event, Emitter<SetupState<T>> emit) {
    emit(SingleSetupLoaded<T>(event.shortID));
  }

  void _onSetupLoaded(_SetupLoaded<T> event, Emitter<SetupState<T>> emit) {
    emit(SetupLoaded<T>(event.data));
  }

  void _onSingleSetupLoaded(
    _SingleSetupLoaded<T> event,
    Emitter<SetupState<T>> emit,
  ) {
    emit(SingleSetupLoaded<T>(event.data));
  }

  void _onSetupLoadError(_SetupLoadError event, Emitter<SetupState<T>> emit) {
    final errorLogCache = ErrorLogCache();
    errorLogCache.cacheError(error: event.error, fileName: 'setup_bloc');
    emit(SetupError<T>(event.error));
  }

  List<T> _toList(List<CacheData> cacheData) {
    return cacheData
        .map((cache) => fromFirestore(cache.data, cache.id))
        .toList();
  }

  /*Future<String> _generateUniqueID(CollectionReference ref) async {
    String shortId;

    while (true) {
      shortId = shortid.generate();
      final trimNewId = _replaceSpecialCharsWithRandomNumbers(shortId);
      DocumentSnapshot doc = await ref.doc(trimNewId).get();

      if (!doc.exists) {
        break;
      }
    }

    return shortId.toUpperCase();
  }

  String _replaceSpecialCharsWithRandomNumbers(String str) {
    final Random random = Random();
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
    String result = str.replaceAllMapped(regExp, (Match match) {
      return random.nextInt(10).toString();
    });

    return result;
  }*/

  @override
  Future<void> close() {
    _setupRepository.cancelDataSubscription();
    return super.close();
  }
}
