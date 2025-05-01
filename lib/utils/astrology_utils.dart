import 'constants.dart';

// Calculate house based on planet sign and ascendant sign
int calculateHouse(String planetSign, String ascendantSign) {
  final signs = Constants.zodiacSigns; // Assuming this exists in constants.dart
  int ascendantIndex = signs.indexOf(ascendantSign);
  int planetIndex = signs.indexOf(planetSign);

  if (ascendantIndex == -1 || planetIndex == -1) {
    print('Warning: Invalid sign provided to calculateHouse. Planet: $planetSign, Asc: $ascendantSign');
    return 0; // Invalid sign
  }

  // Calculate house number (1-based index)
  int house = (planetIndex - ascendantIndex + 12) % 12 + 1;
  return house;
}

// Placeholder for calculating Navamsa sign from longitude
// Requires precise astrological rules
// String calculateNavamsaSign(double longitude) {
//   // Complex calculation based on longitude division
//   // ... implementation needed ...
//   return 'Aries'; // Placeholder
// } 