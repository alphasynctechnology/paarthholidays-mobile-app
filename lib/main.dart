import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import 'package:paarth_holidays/screens/splash/splash_screen.dart';
import 'package:paarth_holidays/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Paarth Holidays',
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      builder: (context, child) {
        return UpgradeAlert(
          upgrader: Upgrader(
            countryCode: 'IN',
            durationUntilAlertAgain: const Duration(days: 1),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
