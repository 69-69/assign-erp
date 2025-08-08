class GeoLocation {
  final String ip;
  final String network;
  final String version;
  final String city;
  final String region;
  final String regionCode;
  final String country;
  final String countryName;
  final String countryCode;
  final String countryCodeIso3;
  final String countryCapital;
  final String countryTld;
  final String continentCode;
  final bool inEu;
  final String postal;
  final double latitude;
  final double longitude;
  final String timezone;
  final String utcOffset;
  final String countryCallingCode;
  final String currency;
  final String currencyName;
  final String languages;
  final double countryArea;
  final int countryPopulation;
  final String asn;
  final String org;

  GeoLocation({
    required this.ip,
    required this.network,
    required this.version,
    required this.city,
    required this.region,
    required this.regionCode,
    required this.country,
    required this.countryName,
    required this.countryCode,
    required this.countryCodeIso3,
    required this.countryCapital,
    required this.countryTld,
    required this.continentCode,
    required this.inEu,
    required this.postal,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.utcOffset,
    required this.countryCallingCode,
    required this.currency,
    required this.currencyName,
    required this.languages,
    required this.countryArea,
    required this.countryPopulation,
    required this.asn,
    required this.org,
  });

  factory GeoLocation.fromIpApiCoJson(Map<String, dynamic> json) {
    return GeoLocation(
      ip: json['ip'],
      network: json['network'] ?? '',
      version: json['version'] ?? '',
      city: json['city'],
      region: json['region'],
      regionCode: json['region_code'],
      country: json['country'],
      countryName: json['country_name'],
      countryCode: json['country_code'],
      countryCodeIso3: json['country_code_iso3'] ?? '',
      countryCapital: json['country_capital'] ?? '',
      countryTld: json['country_tld'] ?? '',
      continentCode: json['continent_code'] ?? '',
      inEu: json['in_eu'] ?? false,
      postal: json['postal'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'],
      utcOffset: json['utc_offset'] ?? '',
      countryCallingCode: json['country_calling_code'] ?? '',
      currency: json['currency'],
      currencyName: json['currency_name'] ?? '',
      languages: json['languages'] ?? '',
      countryArea: (json['country_area'] as num?)?.toDouble() ?? 0.0,
      countryPopulation: json['country_population'] ?? 0,
      asn: json['asn'] ?? '',
      org: json['org'] ?? '',
    );
  }

  factory GeoLocation.fromIpApiComJson(Map<String, dynamic> json) {
    return GeoLocation(
      ip: json['query'], // not provided by ip-api.com
      network: json['isp'] ?? '',
      version: '',
      city: json['city'],
      region: json['regionName'],
      regionCode: json['region'],
      country: json['country'],
      countryName: json['country'],
      countryCode: json['countryCode'],
      countryCodeIso3: '',
      countryCapital: '',
      countryTld: '',
      continentCode: json['continent'] ?? '',
      inEu: json['eu'] == true,
      postal: json['zip'],
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      timezone: json['timezone'],
      utcOffset: '',
      countryCallingCode: '',
      currency: '',
      currencyName: '',
      languages: '',
      countryArea: 0.0,
      countryPopulation: 0,
      asn: json['as'] ?? '',
      org: json['org'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'network': network,
      'version': version,
      'city': city,
      'region': region,
      'region_code': regionCode,
      'country': country,
      'country_name': countryName,
      'country_code': countryCode,
      'country_code_iso3': countryCodeIso3,
      'country_capital': countryCapital,
      'country_tld': countryTld,
      'continent_code': continentCode,
      'in_eu': inEu,
      'postal': postal,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'utc_offset': utcOffset,
      'country_calling_code': countryCallingCode,
      'currency': currency,
      'currency_name': currencyName,
      'languages': languages,
      'country_area': countryArea,
      'country_population': countryPopulation,
      'asn': asn,
      'org': org,
    };
  }
}
