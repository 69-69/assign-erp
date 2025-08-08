part of 'tenant_bloc.dart';

/// State
///
sealed class TenantState<T> extends Equatable {
  const TenantState();

  @override
  List<Object?> get props => [];
}

class LoadingTenants<T> extends TenantState<T> {}

class SubscriptionAdded<T> extends TenantState<T> {
  final String? message;

  const SubscriptionAdded({this.message});

  @override
  List<Object?> get props => [message];
}

// multiple clients
class TenantsLoaded<T> extends TenantState<T> {
  final List<T> data;

  const TenantsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

// single client
class TenantLoaded<T> extends TenantState<T> {
  final T data;

  const TenantLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class TenantUpdated<T> extends TenantState<T> {
  final String? message;

  const TenantUpdated({this.message});

  @override
  List<Object?> get props => [message];
}

class TenantOverridden<T> extends TenantUpdated<T> {
  const TenantOverridden({required super.message});
}

class TenantDeleted<T> extends TenantState<T> {
  final String? message;

  const TenantDeleted({this.message});

  @override
  List<Object?> get props => [message];
}

class TenantError<T> extends TenantState<T> {
  final String error;

  const TenantError(this.error);

  @override
  List<Object?> get props => [error];
}
