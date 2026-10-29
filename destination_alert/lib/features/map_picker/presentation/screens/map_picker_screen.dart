import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/places_search_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../alarm/domain/entities/destination_search_result.dart';
import '../widgets/destination_map_view.dart';

/// Full-screen interactive map picker for selecting destination coordinates and address.
class MapPickerScreen extends StatefulWidget {
  final LatLng? initialDestination;
  final double initialRadius;
  final PlacesSearchService? placesSearchService;
  final LocationService? locationService;

  const MapPickerScreen({
    super.key,
    this.initialDestination,
    this.initialRadius = 500.0,
    this.placesSearchService,
    this.locationService,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final PlacesSearchService _searchService;
  late final LocationService _locationService;
  final MapController _mapController = MapController();

  LatLng _currentCenter = const LatLng(23.0225, 72.5714);
  LatLng? _currentLocation;
  LatLng? _selectedDestination;
  String _selectedName = 'Tap on map to select';
  String _selectedAddress = 'Move around or tap anywhere on the map';
  bool _isLocating = false;
  bool _isReverseGeocoding = false;

  @override
  void initState() {
    super.initState();
    _searchService = widget.placesSearchService ?? PlacesSearchService();
    _locationService = widget.locationService ?? LocationService.instance;

    if (widget.initialDestination != null) {
      _selectedDestination = widget.initialDestination;
      _currentCenter = widget.initialDestination!;
    }

    _fetchDeviceLocation();
  }

  Future<void> _fetchDeviceLocation() async {
    setState(() => _isLocating = true);
    final pos = await _locationService.getCurrentPosition();
    if (mounted && pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLocation = latLng;
        _isLocating = false;
        if (_selectedDestination == null) {
          _currentCenter = latLng;
        }
      });
      _mapController.move(latLng, 14.5);
    } else {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _onMapTapped(LatLng latLng) async {
    setState(() {
      _selectedDestination = latLng;
      _selectedName = 'Selected Destination';
      _selectedAddress =
          '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
      _isReverseGeocoding = true;
    });

    final address = await _searchService.reverseGeocode(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );

    if (mounted) {
      setState(() {
        _selectedAddress = address;
        _selectedName = address.split(',').first;
        _isReverseGeocoding = false;
      });
    }
  }

  void _confirmSelection() {
    if (_selectedDestination == null) return;

    final result = DestinationSearchResult(
      name: _selectedName,
      formattedAddress: _selectedAddress,
      latitude: _selectedDestination!.latitude,
      longitude: _selectedDestination!.longitude,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Destination on Map'),
        centerTitle: true,
        actions: [
          if (_isLocating)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Live Map View
          Positioned.fill(
            child: DestinationMapView(
              mapController: _mapController,
              initialCenter: _currentCenter,
              currentLocation: _currentLocation,
              destination: _selectedDestination,
              radiusMeters: widget.initialRadius,
              onMapTapped: _onMapTapped,
              onRecenter: _currentLocation != null
                  ? () => _mapController.move(_currentLocation!, 15.0)
                  : _fetchDeviceLocation,
            ),
          ),

          // Bottom Destination Details & Confirm Floating Panel
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: AppCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              borderRadius: 18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlueSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _isReverseGeocoding
                                  ? 'Fetching address...'
                                  : _selectedAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    key: const Key('map_confirm_selection_btn'),
                    text: 'Confirm Destination',
                    icon: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _selectedDestination != null
                        ? _confirmSelection
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
