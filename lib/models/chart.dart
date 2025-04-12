class Chart {
  final Map<String, dynamic> kundali;
  final Map<String, dynamic> navamsa;
  final List<dynamic> vimshottariDasha;
  final Map<String, dynamic> transits;
  final Map<String, dynamic> strengths;

  Chart({
    required this.kundali,
    required this.navamsa,
    required this.vimshottariDasha,
    required this.transits,
    required this.strengths,
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
      kundali: json['kundali'] ?? {},
      navamsa: json['navamsa'] ?? {},
      vimshottariDasha: json['vimshottari_dasha'] ?? [],
      transits: json['transits'] ?? {},
      strengths: {
        'sthana_bala': json['sthana_bala'] ?? {},
        'dig_bala': json['dig_bala'] ?? {},
        'kala_bala': json['kala_bala'] ?? {},
      },
    );
  }
}