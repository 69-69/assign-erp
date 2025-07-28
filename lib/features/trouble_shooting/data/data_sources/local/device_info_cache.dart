import 'package:assign_erp/core/constants/app_db_collect.dart';
import 'package:assign_erp/core/network/data_sources/local/cache_data_model.dart';
import 'package:assign_erp/features/trouble_shooting/data/models/device_info_model.dart';
import 'package:hive/hive.dart';

/// A service for caching the device Info using Hive local storage.
class DeviceInfoCache {
  final Box<CacheData> _dataBox;
  static const _cacheKey = DeviceInfo.cacheKey;
  static const String _onboardingCacheKey = 'hide_onboarding';

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
  Future<void> setDeviceInfo(Map<String, dynamic> info) async {
    final did = DeviceInfo.fromMap(info);
    final cacheData = CacheData.fromCache(
      did.toCache(),
      id: _cacheKey,
      scopeId: 'device_info',
    );

    return await _addToCache(_cacheKey, cacheData);
  }

  Future<void> setOnboarding() async {
    final cacheData = CacheData.fromCache(
      id: _onboardingCacheKey,
      scopeId: 'on_boarding',
      {
        'data': {'hide': true},
      },
    );
    // Add to Cache/localStorage
    await _addToCache(_onboardingCacheKey, cacheData);
  }

  bool get hideOnboarding =>
      _getCacheByKey(_onboardingCacheKey)?.data['hide'] ?? false;

  /// Clears the stored device Info from local storage.
  Future<void> clearDeviceInfo() async =>
      await Future.wait([_dataBox.delete(_cacheKey), _dataBox.clear()]);
}
