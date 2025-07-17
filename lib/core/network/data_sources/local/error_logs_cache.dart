import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/models/error_logs_model.dart';
import 'package:hive/hive.dart';

/// A service for caching the App Error Logs using Hive local storage.
class ErrorLogCache {
  final Box<CacheData> _dataBox;

  ErrorLogCache() : _dataBox = Hive.box<CacheData>(appErrorLogsCache);

  /// Read/Get cache data by Key [_getCacheByKey]
  CacheData? _getCacheByKey(String key) => _dataBox.get(key);

  // debugPrint('PATH:: ${_dataBox.path}');
  /// Add to Cache/localStorage [_addToCache]
  Future<void> _addToCache(String key, CacheData cacheData) async =>
      await _dataBox.put(key, cacheData);

  /// Retrieves the cached, if it exists.
  ErrorLog? getById(String id) {
    CacheData? cache = _getCacheByKey(id);
    return cache != null ? ErrorLog.fromMap(cache.data) : null;
  }

  List<ErrorLog> getLogs() {
    return _dataBox.values
        .map((e) => ErrorLog.fromMap(Map<String, dynamic>.from(e.data)))
        .toList();
  }

  /// Stores Error Log in local storage.
  Future<void> setError({
    required String error,
    required String fileName,
  }) async {
    final info = ErrorLog(error: error, fileName: fileName);
    final cacheKey = info.id!;
    final cacheData = CacheData.fromCache(
      info.toCache(),
      id: cacheKey,
      scopeId: 'error_logs',
    );

    return await _addToCache(cacheKey, cacheData);
  }

  /// Clears the stored Error Log by ID.
  /// [id] is same as cacheKey
  Future<void> clearById(String id) async => await _dataBox.delete(id);

  /// Clears the stored Error Logs from local storage.
  Future<void> clearLogs() async => await _dataBox.clear();
}
