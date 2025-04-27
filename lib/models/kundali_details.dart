class PlanetDetails {
  final double longitude;
  final String longitudeDms;
  final String sign;
  final int house;
  final double degreesInSign;
  final String degreesInSignDms;
  final String nakshatra;
  final int pada;

  PlanetDetails({
    required this.longitude,
    required this.longitudeDms,
    required this.sign,
    required this.house,
    required this.degreesInSign,
    required this.degreesInSignDms,
    required this.nakshatra,
    required this.pada,
  });

  factory PlanetDetails.fromJson(Map<String, dynamic> json) {
    return PlanetDetails(
      longitude: json['longitude'] as double,
      longitudeDms: json['longitude_dms'] as String,
      sign: json['sign'] as String,
      house: json['house'] as int,
      degreesInSign: json['degrees_in_sign'] as double,
      degreesInSignDms: json['degrees_in_sign_dms'] as String,
      nakshatra: json['nakshatra'] as String,
      pada: json['pada'] as int,
    );
  }
}

class AscendantDetails {
  final double longitude;
  final String longitudeDms;
  final String sign;

  AscendantDetails({
    required this.longitude,
    required this.longitudeDms,
    required this.sign,
  });

  factory AscendantDetails.fromJson(Map<String, dynamic> json) {
    return AscendantDetails(
      longitude: json['longitude'] as double,
      longitudeDms: json['longitude_dms'] as String,
      sign: json['sign'] as String,
    );
  }
}

class KundaliDetails {
  final double ayanamsa;
  final String ayanamsaType;
  final AscendantDetails ascendant;
  final double midheaven;
  final String midheavenDms;
  final Map<String, PlanetDetails> planets;
  final double tzOffset;

  KundaliDetails({
    required this.ayanamsa,
    required this.ayanamsaType,
    required this.ascendant,
    required this.midheaven,
    required this.midheavenDms,
    required this.planets,
    required this.tzOffset,
  });

  factory KundaliDetails.fromJson(Map<String, dynamic> json) {
    // Convert planets map
    final planetsJson = json['planets'] as Map<String, dynamic>;
    final planets = planetsJson.map((key, value) => 
      MapEntry(key, PlanetDetails.fromJson(value as Map<String, dynamic>))
    );

    return KundaliDetails(
      ayanamsa: json['ayanamsa'] as double,
      ayanamsaType: json['ayanamsa_type'] as String,
      ascendant: AscendantDetails.fromJson(json['ascendant'] as Map<String, dynamic>),
      midheaven: json['midheaven'] as double,
      midheavenDms: json['midheaven_dms'] as String,
      planets: planets,
      tzOffset: json['tz_offset'] as double,
    );
  }
}