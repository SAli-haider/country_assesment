class Country {
  final String? commonName;
  final String? flagUrl;
  final String? region;
  final int? population;

  Country({
    this.commonName,
    this.flagUrl,
    this.region,
    this.population,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      commonName: json['name']?['common'] as String?,
      flagUrl: json['flags']?['png'] as String?,
      region: json['region'] as String?,
      population: json['population'] as int?,
    );
  }

}
