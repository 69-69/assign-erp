import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  final String? model;
  final String deviceId;
  final String? storage;
  final String? osVersion;

  const DeviceInfo({
    required this.deviceId,
    this.model,
    this.storage,
    this.osVersion,
  });

  static const String cacheKey = 'device_id_cache_key';

  /// Convert JSON/Map to Model [UserDeviceID.fromMap]
  factory DeviceInfo.fromMap(Map<String, dynamic> map) => DeviceInfo(
    deviceId: map['deviceId'] as String,
    model: map['model'] as String?,
    storage: map['storage'] as String?,
    osVersion: map['osVersion'] as String?,
  );

  /// Convert UserModel to a map for storing in Firestore [toMap]
  /// [id] is device id
  Map<String, dynamic> toMap() => <String, dynamic>{
    'deviceId': deviceId,
    'model': model,
    'storage': storage,
    'osVersion': osVersion,
  };

  /// Convert Model to toCache Function [toCache]
  /// [data] to be stored in cache
  /// [id] to be used as cache key
  Map<String, dynamic> toCache() => <String, dynamic>{
    'id': cacheKey,
    'data': toMap(),
  };

  @override
  List<Object?> get props => [deviceId, model, storage, osVersion];
}
