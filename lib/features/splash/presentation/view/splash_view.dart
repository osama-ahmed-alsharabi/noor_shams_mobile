import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/pages/login_view.dart';
import '../../../service_provider/presentation/views/service_provider_layout.dart';
import '../../../client/presentation/views/client_layout.dart';
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else if (state is SplashAuthenticated) {
            // User is already logged in, navigate based on role
            if (state.role == 'provider') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ServiceProviderLayout(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ClientLayout()),
              );
            }
          }
        },
        child: const Scaffold(body: SplashBody()),
      ),
    );
  }
}
