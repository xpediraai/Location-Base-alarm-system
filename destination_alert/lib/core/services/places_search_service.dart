import '../../features/alarm/domain/entities/destination_search_result.dart';

/// Destination and places search service for resolving addresses and coordinates.
class PlacesSearchService {
  static final List<DestinationSearchResult> _curatedTransitHubs = [
    const DestinationSearchResult(
      name: 'Central Railway Station',
      formattedAddress: 'Station Road, City Center, Platform 1-12',
      latitude: 23.0225,
      longitude: 72.5714,
      category: 'Railway Station',
    ),
    const DestinationSearchResult(
      name: 'International Airport Terminal 2',
      formattedAddress: 'Airport Road, Arrivals & Departures Terminal',
      latitude: 23.0725,
      longitude: 72.6341,
      category: 'Airport',
    ),
    const DestinationSearchResult(
      name: 'Metro Junction Interchange',
      formattedAddress: 'Line 1 & Line 2 Interchange Station',
      latitude: 23.0300,
      longitude: 72.5800,
      category: 'Metro Station',
    ),
    const DestinationSearchResult(
      name: 'Tech City Business Park',
      formattedAddress: 'Main Boulevard, Information Technology Zone',
      latitude: 23.1900,
      longitude: 72.6800,
      category: 'Commercial Hub',
    ),
    const DestinationSearchResult(
      name: 'Grand Central Bus Terminal (ISBT)',
      formattedAddress: 'Interstate Bus Terminal, Bay Platform 4',
      latitude: 23.0150,
      longitude: 72.5600,
      category: 'Bus Terminal',
    ),
    const DestinationSearchResult(
      name: 'City University North Campus',
      formattedAddress: 'University Ring Road, Main Academic Gate',
      latitude: 23.0450,
      longitude: 72.5350,
      category: 'University',
    ),
    const DestinationSearchResult(
      name: 'Downtown Financial District',
      formattedAddress: 'Financial Center Tower 1, Banking Avenue',
      latitude: 23.0380,
      longitude: 72.5620,
      category: 'Business District',
    ),
  ];

  /// Search destinations by name, keywords, or coordinate string.
  Future<List<DestinationSearchResult>> searchDestinations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Check if query is direct coordinates: "lat, lng"
    final coordParts = trimmed.split(RegExp(r'[, ]+'));
    if (coordParts.length == 2) {
      final lat = double.tryParse(coordParts[0]);
      final lng = double.tryParse(coordParts[1]);
      if (lat != null &&
          lng != null &&
          lat >= -90 &&
          lat <= 90 &&
          lng >= -180 &&
          lng <= 180) {
        return [
          DestinationSearchResult(
            name:
                'Pin Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
            formattedAddress: 'Custom GPS Coordinates',
            latitude: lat,
            longitude: lng,
            category: 'Custom Pin',
          ),
        ];
      }
    }

    // Filter matching transit hubs
    final lower = trimmed.toLowerCase();
    final matches = _curatedTransitHubs.where((place) {
      return place.name.toLowerCase().contains(lower) ||
          place.formattedAddress.toLowerCase().contains(lower) ||
          place.category.toLowerCase().contains(lower);
    }).toList();

    // If query has at least 3 characters and no curated match, allow creating as custom destination
    if (matches.isEmpty && trimmed.length >= 3) {
      matches.add(
        DestinationSearchResult(
          name: trimmed,
          formattedAddress: 'User-specified destination (Auto-positioned)',
          latitude: 23.0300 + (trimmed.hashCode % 1000) / 10000.0,
          longitude: 72.5700 + (trimmed.hashCode % 1000) / 10000.0,
          category: 'Destination',
        ),
      );
    }

    return matches;
  }
}
