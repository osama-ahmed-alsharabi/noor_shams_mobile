import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
import '../cubit/channel_cubit.dart';
import '../cubit/channel_state.dart';
import '../widgets/provider_background.dart';

class ChannelCreateView extends StatefulWidget {
  final String? channelId;
  final String? initialName;
  final String? initialDescription;

  const ChannelCreateView({
    super.key,
    this.channelId,
    this.initialName,
    this.initialDescription,
  });

  @override
  State<ChannelCreateView> createState() => _ChannelCreateViewState();
}

class _ChannelCreateViewState extends State<ChannelCreateView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get isEditing => widget.channelId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<ChannelCubit>();
      if (isEditing) {
        cubit.updateChannel(
          id: widget.channelId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        cubit.createChannel(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChannelCubit, ChannelState>(
      listener: (context, state) {
        if (state is ChannelOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context);
        } else if (state is ChannelError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const ProviderBackground(),
            SafeArea(
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      isEditing ? 'تعديل القناة' : 'إنشاء قناة جديدة',
                    ),
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
                      child: GlassBox(
                        opacity: 0.7,
                        blur: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'معلومات القناة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'أدخل التفاصيل الأساسية لقناتك',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'اسم القناة',
                                    hintText: 'مثال: خدمات الطاقة الشمسية',
                                    prefixIcon: const Icon(
                                      Icons.store_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'الرجاء إدخال اسم القناة';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'وصف القناة',
                                    hintText: 'وصف مختصر عن خدماتك',
                                    prefixIcon: const Icon(
                                      Icons.description_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                  ),
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 32),
                                BlocBuilder<ChannelCubit, ChannelState>(
                                  builder: (context, state) {
                                    final isLoading = state is ChannelLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : _handleSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                isEditing
                                                    ? 'حفظ التغييرات'
                                                    : 'إنشاء القناة',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }
}
