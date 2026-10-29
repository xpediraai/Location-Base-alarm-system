/// Result model for destination search and geocoding.
class DestinationSearchResult {
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String category;

  const DestinationSearchResult({
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.category = 'Transit Stop',
  });
}
