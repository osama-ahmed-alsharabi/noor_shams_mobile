import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/provider_background.dart';

class ProfileEditView extends StatefulWidget {
  final String initialName;
  final String? avatarUrl;

  const ProfileEditView({super.key, required this.initialName, this.avatarUrl});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile(
        name: _nameController.text.trim(),
      );
    }
  }

  void _handlePickImage() {
    context.read<ProfileCubit>().pickAndUploadAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;
        String? currentAvatarUrl = widget.avatarUrl;

        // Get updated avatar from state if available
        if (state is ProfileLoaded) {
          currentAvatarUrl = state.profile.avatarUrl;
        }

        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            body: Stack(
              children: [
                const ProviderBackground(),
                SafeArea(
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text('تعديل الملف الشخصي'),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        centerTitle: true,
                        titleTextStyle: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        iconTheme: const IconThemeData(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Avatar Section - Clickable to change photo
                              GestureDetector(
                                onTap: _handlePickImage,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryBlue.withOpacity(
                                              0.2,
                                            ),
                                            AppColors.primaryOrange.withOpacity(
                                              0.1,
                                            ),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child:
                                          currentAvatarUrl != null &&
                                              currentAvatarUrl.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                currentAvatarUrl,
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: AppColors
                                                          .primaryBlue
                                                          .withOpacity(0.5),
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              size: 60,
                                              color: AppColors.primaryBlue
                                                  .withOpacity(0.5),
                                            ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اضغط لتغيير الصورة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary.withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Form Section
                              GlassBox(
                                opacity: 0.7,
                                blur: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'المعلومات الشخصية',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          controller: _nameController,
                                          decoration: InputDecoration(
                                            labelText: 'الاسم الكامل',
                                            prefixIcon: const Icon(
                                              Icons.person_outline,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'الرجاء إدخال الاسم';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: _handleSubmit,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryBlue,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              'حفظ التغييرات',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
