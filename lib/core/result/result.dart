// lib/core/result/result.dart

/// A sealed class representing the outcome of an operation.
/// It can be either a [Success] containing the result data,
/// or a [Failure] containing an optional error message.
sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success({required this.data});
}

class Failure<T> extends Result<T> {
  final String? message;
  Failure({this.message});
}
