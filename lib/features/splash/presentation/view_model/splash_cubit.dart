import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void startSplash() async {
    emit(SplashLoading());
    await Future.delayed(const Duration(seconds: 3));
    emit(SplashZooming());
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if user is already logged in
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      // User is logged in, get their role from database
      try {
        final userData = await supabase
            .from('users')
            .select('role')
            .eq('id', currentUser.id)
            .maybeSingle();

        if (userData != null) {
          emit(SplashAuthenticated(userData['role'] as String));
          return;
        }
      } catch (e) {
        // If error, fall back to login screen
      }
    }

    emit(SplashCompleted());
  }
}
