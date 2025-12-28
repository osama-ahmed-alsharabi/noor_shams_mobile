import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/role_selector.dart';
import 'package:noor_shams_mobile/features/auth/presentation/widgets/primary_button.dart';
import 'package:noor_shams_mobile/core/utils/app_error_handler.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

// Breaking long lines to fit strict limits and ensuring implementation is concise
class _RegisterFormState extends State<RegisterForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _role = 'client';
  bool _showPass = false;
  bool _showConfirm = false;

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        name: _name.text,
        phone: _phone.text,
        password: _pass.text,
        role: _role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _name,
            hintText: 'الاسم الكامل',
            validator: (v) => AppErrorHandler.validateName(v).isEmpty
                ? null
                : AppErrorHandler.validateName(v),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirm,
            hintText: 'تأكيد كلمة المرور',
            obscureText: !_showConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirm ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primaryBlue,
              ),
              onPressed: () => setState(() => _showConfirm = !_showConfirm),
            ),
            validator: (v) =>
                v != _pass.text ? 'كلمة المرور غير متطابقة' : null,
          ),
          const SizedBox(height: 24),
          RoleSelector(
            selectedRole: _role,
            onRoleSelected: (r) => setState(() => _role = r),
          ),
          const SizedBox(height: 30),
          PrimaryButton(text: 'تسجيل', onPressed: _register, isLoading: false),
        ],
      ),
    );
  }
}
