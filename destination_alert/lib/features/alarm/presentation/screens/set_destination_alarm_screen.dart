import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/firestore_database_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/places_search_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../map_picker/presentation/widgets/destination_map_view.dart';
import '../../domain/entities/destination_search_result.dart';

/// Screen for searching destinations on a live OpenStreetMap, selecting alert radius, and saving destination alarms to Cloud Firestore.
class SetDestinationAlarmScreen extends StatefulWidget {
  final PlacesSearchService? placesSearchService;
  final FirestoreDatabaseService? firestoreDatabaseService;
  final LocationService? locationService;
  final VoidCallback? onAlarmSaved;

  const SetDestinationAlarmScreen({
    super.key,
    this.placesSearchService,
    this.firestoreDatabaseService,
    this.locationService,
    this.onAlarmSaved,
  });

  @override
  State<SetDestinationAlarmScreen> createState() =>
      _SetDestinationAlarmScreenState();
}

class _SetDestinationAlarmScreenState extends State<SetDestinationAlarmScreen> {
  late final PlacesSearchService _searchService;
  late final FirestoreDatabaseService _firestoreService;
  late final LocationService _locationService;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<DestinationSearchResult> _searchResults = [];
  DestinationSearchResult? _selectedDestination;
  LatLng? _currentLocation;
  bool _isSearching = false;
  bool _isLocating = false;
  bool _isSaving = false;
  String? _formError;

  // Selected alarm parameters
  double _radiusMeters = 500.0;
  String _selectedTone = 'Chime Alert';
  bool _vibrate = true;

  final List<double> _presetRadii = [100, 250, 500, 1000, 2000];
  final List<String> _alarmTones = [
    'Chime Alert',
    'Digital Alarm',
    'Gentle Radar',
    'Metro Beep',
  ];

  @override
  void initState() {
    super.initState();
    _searchService = widget.placesSearchService ?? PlacesSearchService();
    _firestoreService =
        widget.firestoreDatabaseService ?? FirestoreDatabaseService.instance;
    _locationService = widget.locationService ?? LocationService.instance;

    _fetchDeviceLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchDeviceLocation() async {
    setState(() => _isLocating = true);
    final pos = await _locationService.getCurrentPosition();
    if (mounted && pos != null) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLocation = latLng;
        _isLocating = false;
      });
      if (_selectedDestination == null) {
        _mapController.move(latLng, 14.0);
      }
    } else {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _searchService.searchDestinations(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectDestination(DestinationSearchResult destination) {
    FocusScope.of(context).unfocus();
    final destLatLng = LatLng(destination.latitude, destination.longitude);

    setState(() {
      _selectedDestination = destination;
      _searchResults = [];
      _formError = null;
      _searchController.text = destination.name;
    });

    _mapController.move(destLatLng, 15.0);
  }

  Future<void> _onMapTapped(LatLng latLng) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedDestination = DestinationSearchResult(
        name: 'Selected Pin Location',
        formattedAddress:
            '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}',
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        category: 'Custom Pin',
      );
      _searchController.text = 'Pin Location';
      _searchResults = [];
      _formError = null;
    });

    // Reverse geocode in background to obtain street address
    final address = await _searchService.reverseGeocode(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );

    if (mounted &&
        _selectedDestination?.latitude == latLng.latitude &&
        _selectedDestination?.longitude == latLng.longitude) {
      setState(() {
        _selectedDestination = DestinationSearchResult(
          name: address.split(',').first,
          formattedAddress: address,
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          category: 'Selected Place',
        );
        _searchController.text = address.split(',').first;
      });
    }
  }

  String _formatRadius(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return '${km.toStringAsFixed(km.truncateToDouble() == km ? 0 : 1)} km';
    }
    return '${meters.toInt()} m';
  }

  String? _calculateDistanceFromUser() {
    if (_currentLocation == null || _selectedDestination == null) return null;

    final distanceMeters = _locationService.calculateDistanceMeters(
      startLatitude: _currentLocation!.latitude,
      startLongitude: _currentLocation!.longitude,
      endLatitude: _selectedDestination!.latitude,
      endLongitude: _selectedDestination!.longitude,
    );

    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km away';
    }
    return '${distanceMeters.toInt()} m away';
  }

  Future<void> _handleSaveAlarm() async {
    if (_isSaving) return;

    if (_selectedDestination == null) {
      setState(() {
        _formError = 'Please search and select a destination stop.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      await _firestoreService.saveDestinationAlarm(
        destinationName: _selectedDestination!.name,
        address: _selectedDestination!.formattedAddress,
        latitude: _selectedDestination!.latitude,
        longitude: _selectedDestination!.longitude,
        radiusMeters: _radiusMeters,
        alarmTone: _selectedTone,
        vibrate: _vibrate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alarm set for ${_selectedDestination!.name}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        if (widget.onAlarmSaved != null) {
          widget.onAlarmSaved!();
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _formError = 'Failed to save destination alarm: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distanceText = _calculateDistanceFromUser();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Set Destination Alarm',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          if (_isLocating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Field
              Text(
                'Where are you going?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _formError != null
                        ? AppColors.error
                        : AppColors.inputBorder,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  key: const Key('set_alarm_search_field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _performSearch,
                  decoration: InputDecoration(
                    hintText:
                        'Search station, stop, landmark, or coordinates...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondaryLight.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _selectedDestination = null;
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              // Search Results Dropdown List
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                AppCard(
                  key: const Key('set_alarm_search_results_card'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  backgroundColor: Colors.white,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        key: Key('search_result_item_$index'),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.accentBlueSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          item.formattedAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        onTap: () => _selectDestination(item),
                      );
                    },
                  ),
                ),
              ],

              // Interactive OpenStreetMap Live Map View
              const SizedBox(height: 16),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.inputBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: DestinationMapView(
                  mapController: _mapController,
                  initialCenter: _selectedDestination != null
                      ? LatLng(
                          _selectedDestination!.latitude,
                          _selectedDestination!.longitude,
                        )
                      : (_currentLocation ?? const LatLng(23.0225, 72.5714)),
                  currentLocation: _currentLocation,
                  destination: _selectedDestination != null
                      ? LatLng(
                          _selectedDestination!.latitude,
                          _selectedDestination!.longitude,
                        )
                      : null,
                  radiusMeters: _radiusMeters,
                  onMapTapped: _onMapTapped,
                  onRecenter: _currentLocation != null
                      ? () => _mapController.move(_currentLocation!, 15.0)
                      : _fetchDeviceLocation,
                ),
              ),

              // Selected Destination Card
              if (_selectedDestination != null) ...[
                const SizedBox(height: 14),
                AppCard(
                  key: const Key('set_alarm_selected_destination_card'),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.accentBlueSoft,
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDestination!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _selectedDestination!.formattedAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  'GPS: ${_selectedDestination!.latitude.toStringAsFixed(4)}, ${_selectedDestination!.longitude.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (distanceText != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '• $distanceText',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Radius Selector Section
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alarm Alert Radius',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatRadius(_radiusMeters),
                      key: const Key('set_alarm_radius_label'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'The radius circle is displayed on the map above and updates automatically.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),

              // Radius Preset Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _presetRadii.map((radius) {
                  final isSelected = _radiusMeters == radius;
                  return ChoiceChip(
                    key: Key('radius_chip_${radius.toInt()}'),
                    label: Text(_formatRadius(radius)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inputBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _radiusMeters = radius);
                    },
                  );
                }).toList(),
              ),

              // Slider for custom precision
              Slider(
                key: const Key('set_alarm_radius_slider'),
                value: _radiusMeters,
                min: 50.0,
                max: 3000.0,
                divisions: 59,
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey.shade300,
                onChanged: (val) {
                  setState(() => _radiusMeters = val);
                },
              ),

              // Sound & Vibration Settings
              const SizedBox(height: 18),
              Text(
                'Alarm Sound & Tone',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.white,
                child: Column(
                  children: [
                    // Tone dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Ringtone',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _selectedTone,
                          underline: const SizedBox(),
                          items: _alarmTones.map((tone) {
                            return DropdownMenuItem(
                              value: tone,
                              child: Text(tone),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTone = val);
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    // Vibration toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.vibration_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Vibrate with alarm',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _vibrate,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) => setState(() => _vibrate = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Error Banner
              if (_formError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Save Action Button
              const SizedBox(height: 28),
              PrimaryButton(
                key: const Key('set_alarm_submit_button'),
                text: 'Save Destination Alarm',
                isLoading: _isSaving,
                icon: const Icon(
                  Icons.alarm_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _handleSaveAlarm,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
