import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import '../cubit/channel_cubit.dart';
import '../cubit/channel_state.dart';
import '../widgets/provider_background.dart';

class ChannelCreateView extends StatefulWidget {
  final String? channelId;
  final String? initialName;
  final String? initialDescription;
  final String? initialCoverImageUrl;

  const ChannelCreateView({
    super.key,
    this.channelId,
    this.initialName,
    this.initialDescription,
    this.initialCoverImageUrl,
  });

  @override
  State<ChannelCreateView> createState() => _ChannelCreateViewState();
}

class _ChannelCreateViewState extends State<ChannelCreateView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  XFile? _selectedImage;
  String? _existingImageUrl;

  bool get isEditing => widget.channelId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _existingImageUrl = widget.initialCoverImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await context.read<ChannelCubit>().pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _existingImageUrl = null;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ChannelCubit>();
    String? imageUrl = _existingImageUrl;

    // Upload image if selected
    if (_selectedImage != null) {
      final channelId =
          widget.channelId ?? DateTime.now().millisecondsSinceEpoch.toString();
      imageUrl = await cubit.uploadCoverImage(_selectedImage!, channelId);
    }

    if (isEditing) {
      cubit.updateChannel(
        id: widget.channelId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImageUrl: imageUrl,
      );
    } else {
      cubit.createChannel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImageUrl: imageUrl,
      );
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
      child: BlocBuilder<ChannelCubit, ChannelState>(
        builder: (context, state) {
          final isLoading = state is ChannelLoading;

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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Cover Image
                                  _buildImagePicker(),
                                  const SizedBox(height: 24),
                                  // Form Fields
                                  GlassBox(
                                    opacity: 0.7,
                                    blur: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _nameController,
                                            decoration: InputDecoration(
                                              labelText: 'اسم القناة *',
                                              prefixIcon: const Icon(
                                                Icons.store_outlined,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white
                                                  .withOpacity(0.5),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'الرجاء إدخال اسم القناة';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _descriptionController,
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                              labelText: 'وصف القناة',
                                              alignLabelWithHint: true,
                                              prefixIcon: const Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 60,
                                                ),
                                                child: Icon(
                                                  Icons.description_outlined,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton.icon(
                                              onPressed: _handleSubmit,
                                              icon: Icon(
                                                isEditing
                                                    ? Icons.save
                                                    : Icons.add,
                                              ),
                                              label: Text(
                                                isEditing
                                                    ? 'حفظ التغييرات'
                                                    : 'إنشاء القناة',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryBlue,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue.withOpacity(0.1),
              AppColors.primaryOrange.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(File(_selectedImage!.path)),
                  fit: BoxFit.cover,
                )
              : _existingImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_existingImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage == null && _existingImageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'إضافة صورة الغلاف',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اضغط لاختيار صورة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
