import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashZooming extends SplashState {}

class SplashCompleted extends SplashState {}

/// User is authenticated, navigate to appropriate screen
class SplashAuthenticated extends SplashState {
  final String role;

  const SplashAuthenticated(this.role);

  @override
  List<Object?> get props => [role];
}
