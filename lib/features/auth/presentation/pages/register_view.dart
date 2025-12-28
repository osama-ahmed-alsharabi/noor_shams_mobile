import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/custom_text_field.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/primary_button.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import 'package:noor_shams_mobile/core/utils/app_error_handler.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/role_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'client';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
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
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: const AuthHeader(),
                            ),
                            const SizedBox(height: 30),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: GlassBox(
                                opacity: 0.6,
                                blur: 15,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'إنشاء حساب جديد',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'أنضم إلينا لتبدأ رحلتك',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        CustomTextField(
                                          controller: _nameController,
                                          hintText: 'الاسم الكامل',
                                          validator: (value) {
                                            final error =
                                                AppErrorHandler.validateName(
                                                  value,
                                                );
                                            return error.isEmpty ? null : error;
                                          },
                                        ),
                                        const SizedBox(height: 16),
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
                                        const SizedBox(height: 16),
                                        CustomTextField(
                                          controller:
                                              _confirmPasswordController,
                                          hintText: 'تأكيد كلمة المرور',
                                          obscureText:
                                              !_isConfirmPasswordVisible,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isConfirmPasswordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: AppColors.primaryBlue,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isConfirmPasswordVisible =
                                                    !_isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            if (value !=
                                                _passwordController.text) {
                                              return 'كلمة المرور غير متطابقة';
                                            }
                                            return null;
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
                                                  title: 'أهلاً بك',
                                                  message:
                                                      'تم إنشاء الحساب بنجاح',
                                                  contentType:
                                                      ContentType.success,
                                                ),
                                              );
                                              ScaffoldMessenger.of(context)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(snackBar);

                                              Navigator.pop(context);
                                            } else if (state is AuthError) {
                                              final snackBar = SnackBar(
                                                elevation: 0,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Colors.transparent,
                                                content: AwesomeSnackbarContent(
                                                  title: 'عذراً',
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
                                              text: 'تسجيل',
                                              onPressed: _onRegister,
                                              isLoading:
                                                  false, // Loading handled by overlay
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
                          ],
                        ),
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
