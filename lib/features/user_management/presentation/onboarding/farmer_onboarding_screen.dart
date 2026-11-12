import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';
import '../../domain/user.dart';

class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  const FarmerOnboardingScreen({super.key, this.onFinished});

  final Future<void> Function()? onFinished;

  @override
  ConsumerState<FarmerOnboardingScreen> createState() => _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState extends ConsumerState<FarmerOnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    if (widget.onFinished case final callback?) {
      await callback();
    } else {
      await ref.read(sessionProvider.notifier).chooseRole(UserRole.farmer);
      if (mounted) context.go(AppRoutes.farmerHome);
    }
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_page == 0) {
      context.go(AppRoutes.role);
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      _OnboardingData(
        title: l10n.onboardingPlotTitle,
        body: l10n.onboardingPlotBody,
        asset: 'assets/images/onboarding_plot.png',
        imageLabel: l10n.onboardingPlotImage,
        imageTop: 279.4,
        imageWidth: 195.373,
        imageHeight: 129.824,
      ),
      _OnboardingData(
        title: l10n.onboardingEscrowTitle,
        body: l10n.onboardingEscrowBody,
        asset: 'assets/images/onboarding_escrow.png',
        imageLabel: l10n.onboardingEscrowImage,
        imageTop: 254.56,
        imageWidth: 137.904,
        imageHeight: 167.315,
      ),
      _OnboardingData(
        title: l10n.onboardingWeatherTitle,
        body: l10n.onboardingWeatherBody,
        asset: 'assets/images/onboarding_weather.png',
        imageLabel: l10n.onboardingWeatherImage,
        imageTop: 187.09,
        imageWidth: 261.252,
        imageHeight: 234.782,
      ),
    ];

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 402,
                height: 874,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (value) => setState(() => _page = value),
                      itemBuilder: (context, index) => _OnboardingPage(data: pages[index]),
                    ),
                    Positioned(
                      left: 10,
                      top: 8,
                      child: IconButton(
                        tooltip: l10n.onboardingBack,
                        onPressed: _finishing ? null : _back,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
                      ),
                    ),
                    Positioned(
                      left: 158,
                      top: 717.39,
                      child: _PageIndicator(current: _page, count: pages.length),
                    ),
                    Positioned(
                      left: _page == pages.length - 1 ? 55.5 : 41,
                      top: 760.28,
                      child: _OnboardingActions(
                        isLast: _page == pages.length - 1,
                        finishing: _finishing,
                        skipLabel: l10n.onboardingSkip,
                        nextLabel: l10n.onboardingNext,
                        startLabel: l10n.onboardingStart,
                        onSkip: _finish,
                        onNext: _next,
                        onStart: _finish,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.title,
    required this.body,
    required this.asset,
    required this.imageLabel,
    required this.imageTop,
    required this.imageWidth,
    required this.imageHeight,
  });

  final String title;
  final String body;
  final String asset;
  final String imageLabel;
  final double imageTop;
  final double imageWidth;
  final double imageHeight;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        top: data.imageTop,
        left: (402 - data.imageWidth) / 2,
        width: data.imageWidth,
        height: data.imageHeight,
        child: Image.asset(data.asset, fit: BoxFit.contain, semanticLabel: data.imageLabel),
      ),
      Positioned(
        left: 20,
        right: 20,
        top: 436.9,
        child: Semantics(
          header: true,
          child: Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
              color: Colors.black,
            ),
          ),
        ),
      ),
      Positioned(
        left: 34.5,
        width: 333,
        top: 479.34,
        child: Text(
          data.body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: MuyuFonts.urbanist,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            height: 1.2,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.current, required this.count});

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${current + 1} / $count',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final selected = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: selected ? 32 : 8,
          height: 8,
          margin: EdgeInsets.only(right: index == count - 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: selected ? MuyuColors.action : Colors.white,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    ),
  );
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.isLast,
    required this.finishing,
    required this.skipLabel,
    required this.nextLabel,
    required this.startLabel,
    required this.onSkip,
    required this.onNext,
    required this.onStart,
  });

  final bool isLast;
  final bool finishing;
  final String skipLabel;
  final String nextLabel;
  final String startLabel;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    if (isLast) {
      return SizedBox(
        width: 291,
        height: 60,
        child: _OnboardingButton(
          label: startLabel,
          background: MuyuColors.action,
          foreground: Colors.white,
          onPressed: finishing ? null : onStart,
        ),
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 60,
          child: _OnboardingButton(
            label: skipLabel,
            background: MuyuColors.skip,
            foreground: Colors.black,
            onPressed: finishing ? null : onSkip,
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 150,
          height: 60,
          child: _OnboardingButton(
            label: nextLabel,
            background: MuyuColors.action,
            foreground: Colors.white,
            onPressed: finishing ? null : onNext,
          ),
        ),
      ],
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: const TextStyle(
        fontFamily: MuyuFonts.urbanist,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}
