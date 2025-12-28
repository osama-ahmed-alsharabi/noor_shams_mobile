import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
import 'package:noor_shams_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:noor_shams_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:noor_shams_mobile/features/auth/presentation/pages/register_view.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/primary_button.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import 'package:noor_shams_mobile/core/utils/app_error_handler.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_row.dart';
import '../widgets/role_selector.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'client';
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return PopScope(
              canPop: state is! AuthLoading,
              child: LoadingOverlay(
                isLoading: state is AuthLoading,
                child: Stack(
                  children: [
                    const AuthBackground(),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: const AuthHeader(),
                            ),
                            const SizedBox(height: 40),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: GlassBox(
                                opacity: 0.7,
                                blur: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تسجيل الدخول',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'مرحباً بعودتك!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textSecondary
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        CustomTextField(
                                          controller: _phoneController,
                                          hintText: 'رقم الهاتف',
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            final error =
                                                AppErrorHandler.validatePhone(
                                                  value,
                                                );
                                            return error.isEmpty ? null : error;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller: _passwordController,
                                          hintText: 'كلمة المرور',
                                          obscureText: !_isPasswordVisible,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: AppColors.primaryBlue,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            final error =
                                                AppErrorHandler.validatePassword(
                                                  value,
                                                );
                                            return error.isEmpty ? null : error;
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        RoleSelector(
                                          selectedRole: _selectedRole,
                                          onRoleSelected: (role) {
                                            setState(() {
                                              _selectedRole = role;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 30),
                                        BlocConsumer<AuthCubit, AuthState>(
                                          listener: (context, state) {
                                            if (state is Authenticated) {
                                              final snackBar = SnackBar(
                                                elevation: 0,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Colors.transparent,
                                                content: AwesomeSnackbarContent(
                                                  title: 'مرحباً!',
                                                  message:
                                                      'تم تسجيل الدخول بنجاح: ${state.user.name}',
                                                  contentType:
                                                      ContentType.success,
                                                ),
                                              );
                                              ScaffoldMessenger.of(context)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(snackBar);
                                            } else if (state is AuthError) {
                                              final snackBar = SnackBar(
                                                elevation: 0,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Colors.transparent,
                                                content: AwesomeSnackbarContent(
                                                  title: 'خطأ',
                                                  message: state.message,
                                                  contentType:
                                                      ContentType.failure,
                                                ),
                                              );
                                              ScaffoldMessenger.of(context)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(snackBar);
                                            }
                                          },
                                          builder: (context, state) {
                                            return PrimaryButton(
                                              text: 'دخول',
                                              onPressed: _onLogin,
                                              isLoading: false,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: AuthSwitchRow(
                                text: 'ليس لديك حساب؟ ',
                                actionText: 'سجل الان',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
