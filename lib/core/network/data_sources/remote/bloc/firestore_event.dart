part of 'firestore_bloc.dart';

/// Events
///
sealed class FirestoreEvent<T> extends Equatable {
  const FirestoreEvent();

  @override
  List<Object?> get props => [];
}

class GetData<T> extends FirestoreEvent<T> {}

class GetMultipleDataByIDs<T> extends FirestoreEvent<T> {
  final List<String> documentIDs;

  const GetMultipleDataByIDs({required this.documentIDs});

  @override
  List<Object?> get props => [documentIDs];
}

class GetDataById<T> extends FirestoreEvent<T> {
  final Object? field;
  final String documentId;

  const GetDataById({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

class GetAllDataWithSameId<T> extends FirestoreEvent<T> {
  final Object? field;
  final String documentId;

  const GetAllDataWithSameId({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

/// For Generating Short UID [GetShortID]
class GetShortID<T> extends FirestoreEvent<T> {}

class RefreshData<T> extends FirestoreEvent<T> {}

class SearchData<T> extends FirestoreEvent<T> {
  /// Query_Term / Search_Term [query]
  final String query;

  /// First_Field_Name[field]
  final Object? field;

  /// Second_Field_Name [optField]
  final Object? optField;

  /// Third_Field_Name[auxField]
  final Object? auxField;

  const SearchData({
    this.field,
    this.optField,
    this.auxField,
    required this.query,
  });

  @override
  List<Object?> get props => [field, optField, auxField, query];
}

class AddData<T> extends FirestoreEvent<T> {
  final T data;

  ///NOTE: If not provided, Firestore will assign a unique ID (documentId) [documentId]
  final String? documentId;

  const AddData({this.documentId, required this.data});

  @override
  List<Object?> get props => [documentId, data];
}

/// T data: Generic Data Update: using Model-Class
///   --OR-- Note:: use Generic or Map data update
/// Map? mapData: `Map<String, dynamic>?` Data Update
class UpdateData<T> extends FirestoreEvent<T> {
  final T? data;
  final Map<String, dynamic>? mapData;
  final String documentId;

  const UpdateData({required this.documentId, this.data, this.mapData});

  @override
  List<Object?> get props => [data, documentId];
}

class DeleteData<T> extends FirestoreEvent<T> {
  final String documentId;

  const DeleteData({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}

/// Internal events for state updates
class _DataLoaded<T> extends FirestoreEvent<T> {
  final List<T> data;

  const _DataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _ShortIDLoaded<T> extends FirestoreEvent<T> {
  final T shortID;

  const _ShortIDLoaded(this.shortID);

  @override
  List<Object?> get props => [shortID];
}

class _SingleDataLoaded<T> extends FirestoreEvent<T> {
  final T data;

  const _SingleDataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _DataLoadError extends FirestoreEvent {
  final String error;

  const _DataLoadError(this.error);

  @override
  List<Object?> get props => [error];
}
