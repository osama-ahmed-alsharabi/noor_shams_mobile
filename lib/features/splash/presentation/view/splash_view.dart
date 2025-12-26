import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/splash_cubit.dart';
import '../view_model/splash_state.dart';
import 'widgets/splash_body.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit()..startSplash(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            // Navigate to Next Screen (Auth or Home)
            // For now, we'll just print or show a snackbar/placeholder navigation
            // In a real app: Navigator.pushReplacementNamed(context, Routes.loginRoute);
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(
            //     builder: (context) => const Scaffold(
            //       body: Center(child: Text('Home Screen Placeholder')),
            //     ),
            //   ),
            // );
          }
        },
        child: const Scaffold(body: SplashBody()),
      ),
    );
  }
}
