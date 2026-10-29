import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Vector illustration for Onboarding Page 1 (Commuter, Bus Stop, and Destination Pin).
class OnboardingCommuterIllustration extends StatelessWidget {
  final double height;

  const OnboardingCommuterIllustration({super.key, this.height = 240.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 320.0;

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Soft background ambient glow
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: width * 0.85,
                    height: height * 0.65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(height * 0.35),
                    ),
                  ),
                ),

                // Road / Ground platform
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: width * 0.9,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Bus & Transit Scene
                Positioned(left: 16, bottom: 24, child: _buildBusGraphic()),

                // Bus stop shelter pole & roof
                Positioned(
                  right: 36,
                  bottom: 24,
                  child: _buildBusStopShelter(),
                ),

                // Commuter with backpack
                Positioned(
                  right: 76,
                  bottom: 24,
                  child: _buildCommuterGraphic(),
                ),

                // Floating Destination Alert Pin with Glow
                Positioned(
                  top: 8,
                  right: width * 0.28,
                  child: _buildFloatingPin(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusGraphic() {
    return Container(
      width: 140,
      height: 94,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // White lower stripe
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 24,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
            ),
          ),
          // Front windshield & side windows
          Positioned(
            top: 14,
            left: 10,
            right: 12,
            height: 38,
            child: Row(
              children: [
                // Front windshield
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFBAE6FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Side window 1
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Side window 2
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bus Wheels
          Positioned(left: 20, bottom: -6, child: _buildWheel()),
          Positioned(right: 20, bottom: -6, child: _buildWheel()),
          // Headlights
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE047),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFF334155),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF94A3B8),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildBusStopShelter() {
    return SizedBox(
      width: 46,
      height: 125,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Pole
          Positioned(
            bottom: 0,
            child: Container(
              width: 5,
              height: 115,
              color: const Color(0xFF64748B),
            ),
          ),
          // Shelter roof
          Positioned(
            top: 0,
            child: Container(
              width: 44,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Bus stop sign
          Positioned(
            top: 24,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommuterGraphic() {
    return SizedBox(
      width: 50,
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Legs
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          // Torso & T-shirt
          Positioned(
            bottom: 35,
            child: Container(
              width: 26,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444), // Coral Red shirt
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Backpack
          Positioned(
            bottom: 36,
            left: 2,
            child: Container(
              width: 14,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A), // Navy backpack
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Head
          Positioned(
            top: 10,
            child: Container(
              width: 20,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFFDBA74), // Skin tone
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Hair
          Positioned(
            top: 8,
            child: Container(
              width: 20,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPin() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandRed.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Red Map Pin Outer Shape
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.brandRed,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
