import 'package:fight_blight_bmore/constants/app_theme.dart';
import 'package:fight_blight_bmore/constants/strings.dart';
import 'package:fight_blight_bmore/di/service_locator.dart';
import 'package:fight_blight_bmore/provider/location_provider.dart';
import 'package:fight_blight_bmore/screens/home/home.dart';
import 'package:fight_blight_bmore/services/navigation_service.dart';
import 'package:fight_blight_bmore/screens/splash/splash.dart';
import 'package:fight_blight_bmore/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // Create your store as a final variable in a base Widget. This works better
  // with Hot Reload than creating it directly in the `build` function.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<LocationProvider>(create: (_) => LocationProvider()),
      ],
      child: Observer(
        name: 'global-observer',
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: Strings.appName,
            theme: AppTheme.light().buildThemeData(),
            routes: Routes.routes,
            home: SplashScreen(),
            navigatorKey: getIt<NavigationService>().navigatorKey,
          );
        },
      ),
    );
  }
}
