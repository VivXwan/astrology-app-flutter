class Chart {
  final Map<String, dynamic> data;

  Chart(this.data);

  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(json);
  }

  String get ascendantSign => data['kundali']['ascendant']?['sign'] ?? 'Aries';
  Map<String, dynamic> get planets => data['kundali']['planets'] ?? {};
  Map<String, dynamic> get kundali => data['kundali'] ?? {};
}