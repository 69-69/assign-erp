import 'dart:async';

import 'package:assign_erp/core/constants/collection_type_enum.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/local/error_logs_cache.dart';
import 'package:assign_erp/features/manual/domain/repository/manual_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manual_event.dart';
part 'manual_state.dart';

/// ManualBloc
///
class ManualBloc<T> extends Bloc<ManualEvent, ManualState<T>> {
  final ManualRepository _manualRepository;
  // final FirebaseFirestore _firestore;
  final String collectionPath;
  final CollectionType? collectionType;

  /// toCache/toJson Function [toCache]
  final Map<String, dynamic> Function(T data) toCache;

  /// toJson/toMap Function [toFirestore]
  final Map<String, dynamic> Function(T data) toFirestore;

  /// fromJson/fromMap Function [fromFirestore]
  final T Function(Map<String, dynamic> data, String documentId) fromFirestore;

  // Set up the stream subscription
  late StreamSubscription<List<CacheData>> _subscription;

  ManualBloc({
    this.collectionType,
    required FirebaseFirestore firestore,
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
    required this.toCache,
  }) : _manualRepository = ManualRepository(
         collectionType: collectionType,
         firestore: firestore,
         collectionPath: collectionPath,
       ),
       super(LoadingManuals<T>()) {
    _initialize();

    _manualRepository.dataStream.listen(
      (cacheData) => add(_ManualsLoaded<T>(_toList(cacheData))),
    );
  }

  Future<void> _initialize() async {
    on<RefreshManuals<T>>(_onRefreshManuals);
    on<LoadManuals<T>>(_onLoadManuals);
    on<LoadManualById<T>>(_onLoadManualById);
    on<AddManual<T>>(_onAddManual);
    on<AddManual<List<T>>>(_onAddMultiManual);
    on<UpdateManual>(_onUpdateManual);
    on<DeleteManual>(_onDeleteManual);
    on<_ManualLoaded<T>>(_onManualLoaded);
    on<_ManualError>(_onManualLoadError);
    // on<_ManualsLoaded<T>>(_onManualLoaded);
  }

  Future<void> _onRefreshManuals(
    RefreshManuals<T> event,
    Emitter<ManualState> emit,
  ) async {
    emit(LoadingManuals<T>());
    try {
      // Trigger data refresh in the DataRepository
      await _manualRepository.refreshCacheData();

      // Fetch the updated data from the repository
      final snapshot = await _manualRepository.getAllData().first;
      final data = _toList(snapshot);

      // Emit the loaded state with the refreshed data
      emit(ManualsLoaded<T>(data));
    } catch (e) {
      // Emit an error state in case of failure
      emit(ManualError<T>(e.toString()));
    }
  }

  /// Load All Data Function [_onLoadManuals]
  Future<void> _onLoadManuals(
    LoadManuals<T> event,
    Emitter<ManualState<T>> emit,
  ) async {
    emit(LoadingManuals<T>());

    try {
      _subscription = _manualRepository.getAllData().listen(
        (snapshot) async {
          final data = _toList(snapshot);

          // Update internal state in the BLoC to reflect data loaded
          emit(ManualsLoaded<T>(data));

          // Trigger an event to handle the loaded data
          // add(_ManualLoadedEvent<T>(data));

          // Optionally, emit another state or handle other logic
          // emit(ManualAddedState<T>()); // For example, notify that data is added
        },
        onError: (e) {
          add(_ManualError('Error loading data: $e'));
        },
      );

      // Await for the subscription to be done (optional)
      await _subscription.asFuture();
    } catch (e) {
      emit(ManualError<T>('Error loading data: $e'));
    } finally {
      // Ensure to cancel the subscription when it's no longer needed
      // This could be in the dispose() method of a widget or BLoC
      _subscription.cancel();
    }
  }

  Future<void> _onLoadManualById(
    LoadManualById<T> event,
    Emitter<ManualState<T>> emit,
  ) async {
    emit(LoadingManuals<T>());
    try {
      final localData = await _manualRepository.getDataById(
        event.documentId,
        field: event.field,
      );

      if (localData != null) {
        final data = fromFirestore(localData.data, localData.id);
        add(_ManualLoaded<T>(data));
      } else {
        emit(ManualError<T>('Document not found'));
      }
    } catch (e) {
      emit(ManualError<T>(e.toString()));
    }
  }

  Future<void> _onAddManual(
    AddManual<T> event,
    Emitter<ManualState<T>> emit,
  ) async {
    try {
      // Add data to Firestore and update local storage
      await _manualRepository.createData(toCache(event.data));

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data added
      emit(ManualAdded<T>(message: 'Data added successfully'));
    } catch (e) {
      emit(ManualError<T>(e.toString()));
    }
  }

  Future<void> _onAddMultiManual(
    AddManual<List<T>> event,
    Emitter<ManualState<T>> emit,
  ) async {
    try {
      for (var item in event.data) {
        // Add data to Firestore
        _manualRepository.createData(toCache(item));
      }

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data added
      emit(ManualAdded<T>(message: 'Data added successfully'));
    } catch (e) {
      emit(ManualError<T>(e.toString()));
    }
  }

  /// Note:: use Generic or Map data update
  Future<void> _onUpdateManual(
    UpdateManual event,
    Emitter<ManualState<T>> emit,
  ) async {
    try {
      // Update data in Firestore and update local storage
      final data = event.mapData != null
          ? {'data': event.mapData} // Create a toCache format
          : toCache(event.data as T);

      await _manualRepository.updateData(event.documentId, data);

      // Trigger LoadDataEvent to reload the data
      // add(LoadDataEvent<T>());

      // Update State: Notify that data updated
      emit(ManualUpdated<T>(message: 'data updated successfully'));
    } catch (e) {
      emit(ManualError<T>(e.toString()));
    }
  }

  Future<void> _onDeleteManual(
    DeleteManual event,
    Emitter<ManualState<T>> emit,
  ) async {
    try {
      // Delete data from Firestore and update local storage
      await _manualRepository.deleteData(event.documentId);

      // Trigger LoadDataEvent to reload the data
      add(LoadManuals<T>());

      // Update State: Notify that data deleted
      emit(ManualDeleted<T>(message: 'data deleted successfully'));
    } catch (e) {
      emit(ManualError<T>(e.toString()));
    }
  }

  /*void _onManualLoaded(_ManualsLoaded<T> event, Emitter<ManualState<T>> emit) {
    emit(ManualsLoaded<T>(event.data));
  }*/

  void _onManualLoaded(_ManualLoaded<T> event, Emitter<ManualState<T>> emit) {
    emit(ManualLoaded<T>(event.data));
  }

  void _onManualLoadError(_ManualError event, Emitter<ManualState<T>> emit) {
    final errorLogCache = ErrorLogCache();
    errorLogCache.cacheError(error: event.error, fileName: 'manual_bloc');
    emit(ManualError<T>(event.error));
  }

  List<T> _toList(List<CacheData> cacheData) {
    return cacheData
        .map((cache) => fromFirestore(cache.data, cache.id))
        .toList();
  }

  @override
  Future<void> close() {
    _manualRepository.cancelDataSubscription();
    return super.close();
  }
}
