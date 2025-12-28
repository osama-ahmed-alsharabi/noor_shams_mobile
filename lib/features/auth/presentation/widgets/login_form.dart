import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/role_selector.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/primary_button.dart';
import 'package:noor_shams_mobile/core/utils/app_error_handler.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _role = 'client';
  bool _showPass = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(_phone.text, _pass.text, _role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _phone,
            hintText: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
            validator: (v) => AppErrorHandler.validatePhone(v).isEmpty
                ? null
                : AppErrorHandler.validatePhone(v),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _pass,
            hintText: 'كلمة المرور',
            obscureText: !_showPass,
            suffixIcon: IconButton(
              icon: Icon(
                _showPass ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primaryBlue,
              ),
              onPressed: () => setState(() => _showPass = !_showPass),
            ),
            validator: (v) => AppErrorHandler.validatePassword(v).isEmpty
                ? null
                : AppErrorHandler.validatePassword(v),
          ),
          const SizedBox(height: 24),
          RoleSelector(
            selectedRole: _role,
            onRoleSelected: (r) => setState(() => _role = r),
          ),
          const SizedBox(height: 30),
          PrimaryButton(text: 'دخول', onPressed: _login, isLoading: false),
        ],
      ),
    );
  }
}
