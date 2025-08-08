import 'dart:convert';
import 'dart:io';

import 'package:assign_erp/core/util/debug_printify.dart';
import 'package:assign_erp/features/auth/data/model/geolocation_model.dart';

class GeoLocationService {
  static final GeoLocationService _instance = GeoLocationService._internal();
  factory GeoLocationService() => _instance;

  GeoLocationService._internal();

  GeoLocation? _geoLocation;

  Future<GeoLocation?> getGeoLocation() async {
    if (_geoLocation != null) return _geoLocation;

    _geoLocation = await _fetchFromIpApiCo();

    if (_geoLocation == null) {
      prettyPrint('GeoLocation fallback', 'Trying ip-api.com...');
      _geoLocation = await _fetchFromIpApiCom();
    }

    return _geoLocation;
  }

  Future<GeoLocation?> _fetchFromIpApiCo() async {
    const url = 'https://ipapi.co/json/';
    return _fetchGeoLocation(url, GeoLocation.fromIpApiCoJson);
  }

  Future<GeoLocation?> _fetchFromIpApiCom() async {
    const url = 'http://ip-api.com/json/';
    return _fetchGeoLocation(url, GeoLocation.fromIpApiComJson);
  }

  Future<GeoLocation?> _fetchGeoLocation(
    String url,
    GeoLocation Function(Map<String, dynamic>) fromJson,
  ) async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      final responseBody = await response.transform(utf8.decoder).join();
      // prettyPrint('GeoLocation response status [$url]', response.statusCode);
      // prettyPrint('GeoLocation response body [$url]', responseBody);

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return fromJson(data);
      } else {
        prettyPrint(
          'GeoLocation error [$url]',
          'Non-200: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      prettyPrint('GeoLocation exception [$url]', e.toString());
      prettyPrint('Stack trace [$url]', stack.toString());
    } finally {
      client.close();
    }

    return null;
  }
}
