import '../../features/user_management/domain/user.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const role = '/role';
  static const farmerOnboarding = '/farmer/onboarding';
  static const farmerHome = '/farmer';
  static const merchantCatalog = '/merchant';

  static const publicRoutes = {login, register};

  static String homeFor(UserRole role) => switch (role) {
    UserRole.farmer => farmerHome,
    UserRole.merchant => merchantCatalog,
  };
}
