import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../labor_execution/presentation/sync_view.dart';
import '../../../../core/designsystem/components/farmer_bottom_bar.dart';
import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/designsystem/components/language_toggle_button.dart';
import '../../../../core/designsystem/components/muyu_controls.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../climate_monitoring/application/weather_controller.dart';
import '../../../climate_monitoring/presentation/weather_alert_screen.dart';
import '../../../user_management/application/session_controller.dart';
import '../../../user_management/presentation/profile/farmer_profile_screen.dart';
import '../../../escrow_custody/presentation/payments/payment_history_view.dart';
import '../../application/farmer_plots_controller.dart';
import '../../domain/farmer_plot.dart';
import '../myplots/my_plots_view.dart';

/// Farmer home shell with the five-tab bar from `FarmerHomeScreen` / `MuyuBottomBar`.
class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen> {
  FarmerTab _tab = FarmerTab.home;

  void _select(FarmerTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: MuyuColors.background,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            switch (_tab) {
              FarmerTab.home => _FarmerHomeTab(onGoToPlots: () => _select(FarmerTab.plot)),
              FarmerTab.plot => const SizedBox.expand(
                child: Column(
                  children: [
                    _MyPlotsHeader(),
                    Expanded(child: MyPlotsView(bottomInset: farmerScrollBottomInset)),
                  ],
                ),
              ),
              FarmerTab.profile => const SizedBox.expand(child: FarmerProfileScreen()),
              // Kotlin `PaymentHistoryScreen` opens under "Payment details" with a back arrow.
              FarmerTab.payments => Column(
                children: [
                  GreenTitleHeader(
                    title: es ? 'Detalles del pago' : 'Payment details',
                    onBack: () => _select(FarmerTab.home),
                  ),
                  const Expanded(child: PaymentHistoryView(bottomInset: farmerScrollBottomInset)),
                ],
              ),
              FarmerTab.sync => SyncView(
                bottomInset: farmerScrollBottomInset,
                onBack: () => _select(FarmerTab.home),
              ),
            },
            Align(
              alignment: Alignment.bottomCenter,
              child: MediaQuery.removeViewInsets(
                context: context,
                removeBottom: true,
                child: FarmerBottomBar(selectedTab: _tab, onTabSelected: _select),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The plot used for the header temperature, as Kotlin `farmerPlotForWeather`:
/// the first one with GPS, otherwise the first one.
FarmerPlot? _weatherPlot(List<FarmerPlot> plots) {
  for (final plot in plots) {
    if (plot.latitude != null && plot.longitude != null) return plot;
  }
  return plots.firstOrNull;
}

/// Greeting header and the farmer's plots, as Kotlin `FarmerHomeScreen`.
class _FarmerHomeTab extends ConsumerStatefulWidget {
  const _FarmerHomeTab({required this.onGoToPlots});

  final VoidCallback onGoToPlots;

  @override
  ConsumerState<_FarmerHomeTab> createState() => _FarmerHomeTabState();
}

class _FarmerHomeTabState extends ConsumerState<_FarmerHomeTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final es = Localizations.localeOf(context).languageCode == 'es';
    final user = ref.watch(sessionProvider).user;
    final name = user?.displayName.trim() ?? '';
    final plot = _weatherPlot(ref.watch(farmerPlotsProvider).value ?? const []);
    final temperature = plot == null
        ? null
        : ref.watch(weatherAlertProvider(plot)).value?.temperature;

    return Column(
      children: [
        ColoredBox(
          color: MuyuColors.navBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(29, 22, 30, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.merchantWelcome, style: MuyuTextStyles.welcomeLabel),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MuyuTextStyles.welcomeName,
                            ),
                          ],
                        ),
                      ),
                      const LanguageToggleButton(),
                      const SizedBox(width: 8),
                      _WeatherPill(
                        temperature: temperature,
                        label: es ? 'Clima' : 'Weather',
                        onTap: plot == null
                            ? null
                            : () => Navigator.of(context).push<void>(
                                MaterialPageRoute(builder: (_) => WeatherAlertScreen(plot: plot)),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const PeruFlag(),
                      const SizedBox(width: MuyuSpacing.s4),
                      Text(
                        l10n.farmerCountryPeru,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontSize: 15,
                          color: MuyuColors.field,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _HomeSearchBar(
                    controller: _search,
                    hint: es ? 'Buscar parcelas o GPS...' : 'Search plots or GPS...',
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: MyPlotsView(
            bottomInset: farmerScrollBottomInset,
            searchController: _search,
            homeStyle: true,
            onGoToPlots: widget.onGoToPlots,
          ),
        ),
      ],
    );
  }
}

/// Weather icon and current temperature of the farmer's plot.
class _WeatherPill extends StatelessWidget {
  const _WeatherPill({required this.temperature, required this.label, this.onTap});

  final double? temperature;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/home_weather_sun_cloud.png',
            width: 40,
            height: 36,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 12),
          Text(
            temperature == null ? '—°C' : '${temperature!.toInt()}°C',
            style: const TextStyle(
              fontFamily: MuyuFonts.urbanist,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: MuyuColors.field,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Kotlin `SearchBar` on Home: a white pill with bold text.
class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: MuyuFonts.urbanist,
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.black,
    );
    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 17, right: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              style: textStyle,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: textStyle.copyWith(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotlin `FarmerMyPlotsScreen` header: title and the lime Publish button.
class _MyPlotsHeader extends StatelessWidget {
  const _MyPlotsHeader();

  @override
  Widget build(BuildContext context) {
    final es = Localizations.localeOf(context).languageCode == 'es';
    const bold = TextStyle(fontFamily: MuyuFonts.urbanist, fontWeight: FontWeight.w700);
    return ColoredBox(
      color: MuyuColors.navBar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  es ? 'Mis parcelas' : 'My Plots',
                  style: bold.copyWith(fontSize: 20, color: Colors.white),
                ),
              ),
              Material(
                color: MuyuColors.lime,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => openPublishPlot(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 20, color: MuyuColors.forest),
                        const SizedBox(width: 6),
                        Text(
                          es ? 'Publicar' : 'Publish',
                          style: bold.copyWith(fontSize: 16, color: MuyuColors.forest),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
