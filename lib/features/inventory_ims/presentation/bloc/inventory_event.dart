part of 'inventory_bloc.dart';

/// Events
///
sealed class InventoryEvent<T> extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class GetInventories<T> extends InventoryEvent<T> {}

class RefreshInventories<T> extends InventoryEvent<T> {}

class GetInventoriesByIds<T> extends InventoryEvent<T> {
  final List<String> documentIDs;

  const GetInventoriesByIds({required this.documentIDs});

  @override
  List<Object?> get props => [documentIDs];
}

class GetInventoryById<T> extends InventoryEvent<T> {
  final Object? field;
  final String documentId;

  const GetInventoryById({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

class GetInventoriesWithSameId<T> extends InventoryEvent<T> {
  final Object? field;
  final String documentId;

  const GetInventoriesWithSameId({required this.documentId, this.field});

  @override
  List<Object?> get props => [documentId, field];
}

class SearchInventory<T> extends InventoryEvent<T> {
  /// Query_Term / Search_Term [query]
  final String query;

  /// First_Field_Name[field]
  final Object? field;

  /// Second_Field_Name [optField]
  final Object? optField;

  /// Third_Field_Name[auxField]
  final Object? auxField;

  const SearchInventory({
    this.field,
    this.optField,
    this.auxField,
    required this.query,
  });

  @override
  List<Object?> get props => [field, optField, auxField, query];
}

class AddInventory<T> extends InventoryEvent<T> {
  final T data;

  ///NOTE: If not provided, Firestore will assign a unique ID (documentId) [documentId]
  final String? documentId;

  const AddInventory({this.documentId, required this.data});

  @override
  List<Object?> get props => [documentId, data];
}

/// T data: Generic Data Update: using Model-Class
///   --OR-- Note:: use Generic or Map data update
/// Map? mapData: `Map<String, dynamic>` Data Update
class UpdateInventory<T> extends InventoryEvent<T> {
  final T? data;
  final Map<String, dynamic>? mapData;
  final String documentId;

  const UpdateInventory({required this.documentId, this.data, this.mapData});

  @override
  List<Object?> get props => [data, documentId];
}

class DeleteInventory<T> extends InventoryEvent<T> {
  final T documentId;

  const DeleteInventory({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}

/// Internal events for state updates
class _InventoryLoaded<T> extends InventoryEvent<T> {
  final List<T> data;

  const _InventoryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _ShortIDLoaded<T> extends InventoryEvent<T> {
  final T shortID;

  const _ShortIDLoaded(this.shortID);

  @override
  List<Object?> get props => [shortID];
}

class _SingleInventoryLoaded<T> extends InventoryEvent<T> {
  final T data;

  const _SingleInventoryLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class _InventoryLoadError extends InventoryEvent {
  final String error;

  const _InventoryLoadError(this.error);

  @override
  List<Object?> get props => [error];
}
