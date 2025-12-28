import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import 'package:noor_shams_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:noor_shams_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'auth_background.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return PopScope(
            canPop: state is! AuthLoading,
            child: LoadingOverlay(
              isLoading: state is AuthLoading,
              child: Stack(
                children: [
                  const AuthBackground(),
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
