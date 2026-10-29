import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Vector illustration for Onboarding Page 3 showing 3 floating status cards:
/// Early Warning, Final Alarm, and Journey History.
class OnboardingCardsIllustration extends StatelessWidget {
  final double height;

  const OnboardingCardsIllustration({super.key, this.height = 240.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card 1: Early Warning
              _buildFeatureCard(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBgColor: const Color(0xFFDCFCE7),
                title: 'Early Warning',
                subtitle: '500 m away',
              ),
              const SizedBox(height: 12),

              // Card 2: Final Alarm (Prominent Highlighted)
              _buildFeatureCard(
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.brandRed,
                iconBgColor: const Color(0xFFFFE4E6),
                title: 'Final Alarm',
                subtitle: 'You have arrived',
                isHighlighted: true,
              ),
              const SizedBox(height: 12),

              // Card 3: Journey History
              _buildFeatureCard(
                icon: Icons.bookmark_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBgColor: const Color(0xFFDCFCE7),
                title: 'Journey History',
                subtitle: 'Keep track',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? AppColors.brandRed.withValues(alpha: 0.25)
              : AppColors.inputBorder,
          width: isHighlighted ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppColors.brandRed.withValues(alpha: 0.08)
                : AppColors.shadowColor,
            blurRadius: isHighlighted ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isHighlighted)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.brandRed,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
