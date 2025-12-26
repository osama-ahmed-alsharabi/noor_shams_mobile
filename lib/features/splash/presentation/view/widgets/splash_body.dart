import 'package:flutter/material.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/assets_manager.dart';

class SplashBody extends StatelessWidget {
  const SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        // Optional: Gradient if desired
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [AppColors.white, AppColors.scaffoldBackground],
        // ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(AssetsManager.logo),
          const SizedBox(height: 40),
          // Loading Indicator
          const CircularProgressIndicator(color: AppColors.primaryOrange),
          const SizedBox(height: 20),
          // Welcome Text (Optional)
          const Text(
            'نور الشمس شمسيlsda;Jبت شسيمبت شسكميب تشسبمن شتسيبمنشكستميبتشمسيبت',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
