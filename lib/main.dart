import 'package:flutter/material.dart';
import 'package:noor_shams_mobile/core/theme/light_theme.dart';
import 'features/splash/presentation/view/splash_view.dart';

void main() {
  runApp(const NoorAlShamsApp());
}

class NoorAlShamsApp extends StatelessWidget {
  const NoorAlShamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: light(),
      home: const SplashView(),
    );
  }
}
