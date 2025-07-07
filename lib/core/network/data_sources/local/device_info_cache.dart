import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/core/network/data_sources/models/device_info_model.dart';
import 'package:hive/hive.dart';

/// A service for caching the device Info using Hive local storage.
class DeviceInfoCache {
  final Box<CacheData> _dataBox;
  static const _cacheKey = DeviceInfo.cacheKey;

  DeviceInfoCache() : _dataBox = Hive.box<CacheData>(deviceInfoCache);

  /// Read/Get cache data by Key [_getCacheByKey]
  CacheData? _getCacheByKey(String key) => _dataBox.get(key);

  // debugPrint('PATH:: ${_dataBox.path}');
  /// Add to Cache/localStorage [_addToCache]
  Future<void> _addToCache(String key, CacheData cacheData) async =>
      await _dataBox.put(key, cacheData);

  /// Retrieves the cached device Info, if it exists.
  DeviceInfo? getDeviceInfo() {
    CacheData? cache = _getCacheByKey(_cacheKey);
    return cache != null ? DeviceInfo.fromMap(cache.data) : null;
  }

  /// Stores the generated device Info in local storage.
  Future<void> cacheDeviceInfo(Map<String, dynamic> deviceInfo) async {
    final did = DeviceInfo.fromMap(deviceInfo);
    final cacheData = CacheData.fromCache(did.toCache(), _cacheKey);

    return await _addToCache(_cacheKey, cacheData);
  }

  /// Clears the stored device Info from local storage.
  Future<void> clearDeviceInfo() async =>
      await Future.wait([_dataBox.delete(_cacheKey), _dataBox.clear()]);
}
