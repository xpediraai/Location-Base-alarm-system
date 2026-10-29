import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';

/// Reusable OpenStreetMap view with destination marker, radius circle, and GPS tracking.
class DestinationMapView extends StatefulWidget {
  final LatLng initialCenter;
  final LatLng? currentLocation;
  final LatLng? destination;
  final double radiusMeters;
  final double initialZoom;
  final ValueChanged<LatLng>? onMapTapped;
  final MapController? mapController;
  final VoidCallback? onRecenter;

  const DestinationMapView({
    super.key,
    required this.initialCenter,
    this.currentLocation,
    this.destination,
    this.radiusMeters = 500.0,
    this.initialZoom = 14.5,
    this.onMapTapped,
    this.mapController,
    this.onRecenter,
  });

  @override
  State<DestinationMapView> createState() => _DestinationMapViewState();
}

class _DestinationMapViewState extends State<DestinationMapView> {
  late final MapController _controller;
  bool _tileLoadError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.mapController ?? MapController();
  }

  void _zoomIn() {
    final currentZoom = _controller.camera.zoom;
    _controller.move(
      _controller.camera.center,
      (currentZoom + 1).clamp(3.0, 18.0),
    );
  }

  void _zoomOut() {
    final currentZoom = _controller.camera.zoom;
    _controller.move(
      _controller.camera.center,
      (currentZoom - 1).clamp(3.0, 18.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDestination = widget.destination != null;
    final hasCurrentLocation = widget.currentLocation != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter:
                  widget.destination ??
                  widget.currentLocation ??
                  widget.initialCenter,
              initialZoom: widget.initialZoom,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, latLng) {
                if (widget.onMapTapped != null) {
                  widget.onMapTapped!(latLng);
                }
              },
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.destination_alert',
                errorTileCallback: (tile, error, stackTrace) {
                  if (!_tileLoadError && mounted) {
                    setState(() => _tileLoadError = true);
                  }
                },
              ),

              // Radius Circle Layer (drawn around destination)
              if (hasDestination)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: widget.destination!,
                      radius: widget.radiusMeters,
                      useRadiusInMeter: true,
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderColor: AppColors.primary,
                      borderStrokeWidth: 2.2,
                    ),
                  ],
                ),

              // Marker Layer (Current GPS Location + Destination Pin)
              MarkerLayer(
                markers: [
                  // User Device GPS Marker
                  if (hasCurrentLocation)
                    Marker(
                      point: widget.currentLocation!,
                      width: 44,
                      height: 44,
                      child: Container(
                        key: const Key('current_location_dot'),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cyanAccent.withValues(alpha: 0.25),
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Destination Pin Marker
                  if (hasDestination)
                    Marker(
                      point: widget.destination!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: Column(
                        key: const Key('destination_pin_marker'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.brandRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Container(
                            width: 3,
                            height: 8,
                            color: AppColors.brandRed,
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // OpenStreetMap Attribution
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap contributors'),
              ),
            ],
          ),

          // Map Controls (Zoom In, Zoom Out, Recenter)
          Positioned(
            right: 12,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recenter GPS Button
                if (widget.onRecenter != null) ...[
                  _buildMapControlButton(
                    key: const Key('map_recenter_button'),
                    icon: Icons.my_location_rounded,
                    tooltip: 'Recenter on current location',
                    onPressed: widget.onRecenter!,
                  ),
                  const SizedBox(height: 8),
                ],

                // Zoom In
                _buildMapControlButton(
                  key: const Key('map_zoom_in_button'),
                  icon: Icons.add,
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 6),

                // Zoom Out
                _buildMapControlButton(
                  key: const Key('map_zoom_out_button'),
                  icon: Icons.remove,
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),

          // Tile Load Error / Offline Notice
          if (_tileLoadError)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Map tiles failed to load. Check internet connection.',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _tileLoadError = false),
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          color: AppColors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        key: key,
        icon: Icon(icon, size: 20, color: AppColors.primaryBlue),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
