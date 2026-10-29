import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Vector illustration for Onboarding Page 2 (Phone, Map, and Arrival Radius Radar).
class OnboardingMapRadarIllustration extends StatelessWidget {
  final double height;

  const OnboardingMapRadarIllustration({super.key, this.height = 240.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient soft background glow
            Container(
              width: 260,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE).withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),

            // Angled Smartphone Frame
            Transform.rotate(
              angle: -0.10, // ~6 degrees tilt
              child: Container(
                width: 175,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF1E293B), width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Stack(
                    children: [
                      // Map Background with streets & blocks
                      Positioned.fill(
                        child: CustomPaint(painter: _MapGridPainter()),
                      ),

                      // Concentric Arrival Radar Waves
                      Positioned.fill(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer radius circle
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondaryBlue.withValues(
                                    alpha: 0.12,
                                  ),
                                  border: Border.all(
                                    color: AppColors.secondaryBlue.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Middle radius circle
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondaryBlue.withValues(
                                    alpha: 0.20,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Inner pulse core
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center Destination Alert Pin
                      Center(
                        child: Transform.translate(
                          offset: const Offset(0, -18),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.brandRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandRed.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      // Top phone notch
                      Positioned(
                        top: 4,
                        left: 45,
                        right: 45,
                        height: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for rendering stylized map grid lines and land blocks.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Park green block
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.15, 60, 45),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Water blue block
    final waterPaint = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.65, 65, 50),
        const Radius.circular(10),
      ),
      waterPaint,
    );

    // Road lines
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.45)
      ..moveTo(size.width * 0.4, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.82);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
