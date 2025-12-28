import 'package:bloc/bloc.dart';
import 'package:noor_shams_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:noor_shams_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:noor_shams_mobile/core/utils/app_error_handler.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({required this.loginUseCase, required this.registerUseCase})
    : super(AuthInitial());

  Future<void> login(String phone, String password, String role) async {
    // Added role param
    emit(AuthLoading());

    // Normalize Arabic numbers first
    String cleanPhone = AppErrorHandler.normalizeArabicNumbers(phone);
    // Sanitize: Keep only digits
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');

    // Prefix with role to ensure unique identifier per role
    // e.g. client778870086@gmail.com
    final email = '${role.toLowerCase()}$cleanPhone@gmail.com';

    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (error) => emit(AuthError(AppErrorHandler.handleAuthError(error))),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    emit(AuthLoading());

    // Normalize Arabic numbers first
    String cleanPhone = AppErrorHandler.normalizeArabicNumbers(phone);
    // Sanitize: Keep only digits
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');

    // Use role-based prefix
    final email = '${role.toLowerCase()}$cleanPhone@gmail.com';

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    result.fold(
      (error) => emit(AuthError(AppErrorHandler.handleAuthError(error))),
      (user) => emit(Authenticated(user)),
    );
  }
}
