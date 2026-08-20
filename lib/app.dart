import 'package:flutter/material.dart';

import 'presentation/controllers/nesti_controller.dart';
import 'presentation/screens/companion_home.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/theme/nesti_theme.dart';

class NestiApp extends StatelessWidget {
  const NestiApp({super.key, required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '栖伴 Nesti',
      debugShowCheckedModeBanner: false,
      theme: buildNestiTheme(),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isReady) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!controller.preferences.onboardingCompleted) {
            return OnboardingScreen(controller: controller);
          }
          return CompanionHome(controller: controller);
        },
      ),
    );
  }
}
