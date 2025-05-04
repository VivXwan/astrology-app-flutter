class PlanetDetails {
  final double longitude;
  final String longitudeDms;
  final String sign;
  final int house;
  final double degreesInSign;
  final String degreesInSignDms;
  final String nakshatra;
  final int pada;
  final bool isRetrograde;

  PlanetDetails({
    required this.longitude,
    required this.longitudeDms,
    required this.sign,
    required this.house,
    required this.degreesInSign,
    required this.degreesInSignDms,
    required this.nakshatra,
    required this.pada,
    this.isRetrograde = false,
  });

  factory PlanetDetails.fromJson(Map<String, dynamic> json) {
    final retrogradeValue = json['retrograde'];
    final bool isRetrograde = retrogradeValue == 'yes' || retrogradeValue == true;
    
    return PlanetDetails(
      longitude: json['longitude'] as double,
      longitudeDms: json['longitude_dms'] as String,
      sign: json['sign'] as String,
      house: json['house'] as int,
      degreesInSign: json['degrees_in_sign'] as double,
      degreesInSignDms: json['degrees_in_sign_dms'] as String,
      nakshatra: json['nakshatra'] as String,
      pada: json['pada'] as int,
      isRetrograde: isRetrograde,
    );
  }

  PlanetDetails copyWith({
    double? longitude,
    String? longitudeDms,
    String? sign,
    int? house,
    double? degreesInSign,
    String? degreesInSignDms,
    String? nakshatra,
    int? pada,
    bool? isRetrograde,
  }) {
    return PlanetDetails(
      longitude: longitude ?? this.longitude,
      longitudeDms: longitudeDms ?? this.longitudeDms,
      sign: sign ?? this.sign,
      house: house ?? this.house,
      degreesInSign: degreesInSign ?? this.degreesInSign,
      degreesInSignDms: degreesInSignDms ?? this.degreesInSignDms,
      nakshatra: nakshatra ?? this.nakshatra,
      pada: pada ?? this.pada,
      isRetrograde: isRetrograde ?? this.isRetrograde,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanetDetails &&
        other.longitude == longitude &&
        other.sign == sign &&
        other.house == house &&
        other.isRetrograde == isRetrograde;
  }

  @override
  int get hashCode => longitude.hashCode ^ sign.hashCode ^ house.hashCode ^ isRetrograde.hashCode;
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