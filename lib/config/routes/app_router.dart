import 'package:arqamy/features/settingscreen/ui/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:arqamy/config/routes/routes.dart';
import 'package:arqamy/features/customerscreen/ui/pages/customer_screen.dart';
import 'package:arqamy/features/drawer/ui/side_nav.dart';
import 'package:arqamy/features/orderscreen/ui/pages/order_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    // final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.orderScreen:
        return MaterialPageRoute(
          builder: (_) => const Orderscreen(),
        );
      case Routes.sideNav:
        return MaterialPageRoute(
          builder: (_) => const SideNav(),
        );
      case Routes.customerScreen:
        return MaterialPageRoute(
          builder: (_) => const CustomerScreen(),
        );      
        // case Routes.inventoryScreen:
        // return MaterialPageRoute(
        //   builder: (_) => const InventoryScreen(),
        // );
      case Routes.settingsScreen:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      // case Routes.shareApp:
      //   return MaterialPageRoute(
      //     builder: (_) => const ShareAppScreen(),
      //   );
      default:
        return MaterialPageRoute(
          builder: (_) => const Orderscreen(),
        );
    }
  }
}
