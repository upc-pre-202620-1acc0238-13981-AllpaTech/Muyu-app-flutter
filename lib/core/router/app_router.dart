import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/plot_approval/presentation/home/farmer_home_screen.dart';
import '../../features/plot_financing/presentation/catalog/merchant_catalog_screen.dart';
import '../../features/user_management/application/session_controller.dart';
import '../../features/user_management/presentation/login/login_screen.dart';
import '../../features/user_management/presentation/onboarding/farmer_onboarding_screen.dart';
import '../../features/user_management/presentation/register/register_screen.dart';
import '../../features/user_management/presentation/role/role_selection_screen.dart';
import '../../features/user_management/presentation/splash/splash_screen.dart';
import 'app_routes.dart';

/// Decides where a session may be, the job `AppNavHost` does in Kotlin.
String? redirectFor(SessionState session, String location) {
  switch (session.status) {
    case SessionStatus.restoring:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case SessionStatus.signedOut:
      return AppRoutes.publicRoutes.contains(location) ? null : AppRoutes.login;
    case SessionStatus.signedIn:
      final role = session.role;
      if (role == null) {
        final choosingFarmer = location == AppRoutes.role || location == AppRoutes.farmerOnboarding;
        return choosingFarmer ? null : AppRoutes.role;
      }
      final leavingAuth =
          location == AppRoutes.splash ||
          location == AppRoutes.role ||
          location == AppRoutes.farmerOnboarding ||
          AppRoutes.publicRoutes.contains(location);
      return leavingAuth ? AppRoutes.homeFor(role) : null;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(initialEmail: state.extra as String?),
      ),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: AppRoutes.role, builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(
        path: AppRoutes.farmerOnboarding,
        builder: (context, state) => const FarmerOnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.farmerHome, builder: (context, state) => const FarmerHomeScreen()),
      GoRoute(
        path: AppRoutes.merchantCatalog,
        builder: (context, state) => const MerchantCatalogScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
