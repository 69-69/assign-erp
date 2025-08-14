part of 'procurement_bloc.dart';

/// Events
///
sealed class ProcurementEvent<T> extends Equatable {
  const ProcurementEvent();

  @override
  List<Object?> get props => [];
}

class GetProcurements<T> extends ProcurementEvent<T> {}

class RefreshProcurements<T> extends ProcurementEvent<T> {}

class GetProcurementsByIds<T> extends ProcurementEvent<T> {
  final List<String> documentIDs;

  const GetProcurementsByIds({required this.documentIDs});

  @override
  List<Object?> get props => [documentIDs];
}

class GetProcurementById<T> extends ProcurementEvent<T> {
  final Object? field;
  final String documentId;

  const GetProcurementById({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

class GetProcurementsWithSameId<T> extends ProcurementEvent<T> {
  final Object? field;
  final String documentId;

  const GetProcurementsWithSameId({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

class SearchProcurement<T> extends ProcurementEvent<T> {
  /// Query_Term / Search_Term [query]
  final String query;

  /// First_Field_Name[field]
  final Object? field;

  /// Second_Field_Name [optField]
  final Object? optField;

  /// Third_Field_Name[auxField]
  final Object? auxField;

  const SearchProcurement({
    this.field,
    this.optField,
    this.auxField,
    required this.query,
  });

  @override
  List<Object?> get props => [field, optField, auxField, query];
}

class AddProcurement<T> extends ProcurementEvent<T> {
  final T data;

  ///NOTE: If not provided, Firestore will assign a unique ID (documentId) [documentId]
  final String? documentId;

  const AddProcurement({this.documentId, required this.data});

  @override
  List<Object?> get props => [documentId, data];
}

/// T data: Generic Data Update: using Model-Class
///   --OR-- Note:: use Generic or Map data update
/// Map? mapData: `Map<String, dynamic>` Data Update
class UpdateProcurement<T> extends ProcurementEvent<T> {
  final T? data;
  final Map<String, dynamic>? mapData;
  final String documentId;

  const UpdateProcurement({required this.documentId, this.data, this.mapData});

  @override
  List<Object?> get props => [data, documentId];
}

class DeleteProcurement<T> extends ProcurementEvent<T> {
  final T documentId;

  const DeleteProcurement({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}

/// Internal events for state updates
class _ProcurementLoaded<T> extends ProcurementEvent<T> {
  final List<T> data;

  const _ProcurementLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _ShortIDLoaded<T> extends ProcurementEvent<T> {
  final T shortID;

  const _ShortIDLoaded(this.shortID);

  @override
  List<Object?> get props => [shortID];
}

class _SingleProcurementLoaded<T> extends ProcurementEvent<T> {
  final T data;

  const _SingleProcurementLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _ProcurementLoadError extends ProcurementEvent {
  final String error;

  const _ProcurementLoadError(this.error);

  @override
  List<Object?> get props => [error];
}
