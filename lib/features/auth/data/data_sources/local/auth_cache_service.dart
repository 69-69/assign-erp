import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/features/setup/data/models/employee_model.dart';
import 'package:hive/hive.dart';

class AuthCacheService {
  static const String _empCacheKey = Employee.cacheKey;
  static const String _workCacheKey = Workspace.cacheKey;

  final Box<CacheData> _dataBox;

  AuthCacheService() : _dataBox = Hive.box<CacheData>(userAuthCache);

  /// Read/Get cache data by id [_getCacheById]
  CacheData? _getCacheById(String id) => _dataBox.get(id);

  // debugPrint('PATH:: ${_dataBox.path}');
  /// Add to Cache/localStorage [_addToCache]
  /// [docId] is the cache key
  Future<void> _addToCache(String docId, CacheData cacheData) async =>
      await _dataBox.put(docId, cacheData);

  /// Clear & delete Cache/localStorage [_clearCache]
  Future<void> _clearCache(String key) async {
    await Future.wait([_dataBox.delete(key), _dataBox.clear()]);
  }

  Workspace? getWorkspace() {
    CacheData? cache = _getCacheById(_workCacheKey);
    return cache != null ? Workspace.fromMap(cache.data) : null;
  }

  Employee? getEmployee() {
    CacheData? cache = _getCacheById(_empCacheKey);
    return cache != null ? Employee.fromMap(cache.data) : null;
  }

  Future<void> cacheWorkspace(Workspace workspace) async {
    final cacheData = CacheData.fromCache(workspace.toCache(), _workCacheKey);
    // Add to Cache/localStorage
    await _addToCache(_workCacheKey, cacheData);
  }

  Future<void> cacheEmployee(Employee employee) async {
    final cacheData = CacheData.fromCache(employee.toCache(), _empCacheKey);
    // Add to Cache/localStorage
    await _addToCache(_empCacheKey, cacheData);
  }

  Future<void> deleteWorkspace() async => _clearCache(_workCacheKey);

  Future<void> deleteEmployee() async => _clearCache(_empCacheKey);
}
