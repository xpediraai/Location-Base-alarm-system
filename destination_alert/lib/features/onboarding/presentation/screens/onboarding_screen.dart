import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/widgets/app_page_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/onboarding_cards_illustration.dart';
import '../widgets/onboarding_commuter_illustration.dart';
import '../widgets/onboarding_map_radar_illustration.dart';

/// Data model representing an onboarding flow step.
class OnboardingStepData {
  final String title;
  final String description;
  final Widget illustration;

  const OnboardingStepData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

/// Production-ready onboarding screen matching Destination Alert reference design.
class OnboardingScreen extends StatefulWidget {
  final LocalStorageService? storageService;

  const OnboardingScreen({super.key, this.storageService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  late final LocalStorageService _storageService;
  int _currentPage = 0;

  final List<OnboardingStepData> _steps = const [
    OnboardingStepData(
      title: 'Never Miss Your Destination',
      description:
          'Set location-based alarms and get notified when you arrive.',
      illustration: OnboardingCommuterIllustration(),
    ),
    OnboardingStepData(
      title: 'Choose Your Destination',
      description: 'Find places easily, select your destination, and set your arrival radius.',
      illustration: OnboardingMapRadarIllustration(),
    ),
    OnboardingStepData(
      title: 'Travel with Confidence',
      description: 'Create alarms, receive arrival alerts, and manage your journeys with ease.',
      illustration: OnboardingCardsIllustration(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _storageService = widget.storageService ?? LocalStorageService.instance;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Page Content (Illustration, Title, Description)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Description
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            step.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Illustration
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: step.illustration,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 28.0),
              child: isLastPage
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppPageIndicator(
                          count: _steps.length,
                          currentIndex: _currentPage,
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Get Started',
                          height: 52,
                          borderRadius: 26,
                          onPressed: _completeOnboarding,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip Action
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Center Page Indicator
                        AppPageIndicator(
                          count: _steps.length,
                          currentIndex: _currentPage,
                        ),

                        // Next Pill Button
                        PrimaryButton(
                          text: 'Next',
                          width: 104,
                          height: 44,
                          borderRadius: 22,
                          onPressed: _nextPage,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
