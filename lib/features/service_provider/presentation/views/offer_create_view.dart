import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
import 'package:noor_shams_mobile/core/widgets/loading_overlay.dart';
import '../cubit/offer_cubit.dart';
import '../cubit/offer_state.dart';
import '../widgets/provider_background.dart';

class OfferCreateView extends StatefulWidget {
  final String channelId;
  final String? offerId;
  final String? initialTitle;
  final String? initialDescription;
  final double? initialPrice;
  final int? initialDurationDays;
  final String? initialImageUrl;

  const OfferCreateView({
    super.key,
    required this.channelId,
    this.offerId,
    this.initialTitle,
    this.initialDescription,
    this.initialPrice,
    this.initialDurationDays,
    this.initialImageUrl,
  });

  @override
  State<OfferCreateView> createState() => _OfferCreateViewState();
}

class _OfferCreateViewState extends State<OfferCreateView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  XFile? _selectedImage;
  String? _existingImageUrl;

  bool get isEditing => widget.offerId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.initialDurationDays?.toString() ?? '',
    );
    _existingImageUrl = widget.initialImageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await context.read<OfferCubit>().pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _existingImageUrl = null;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<OfferCubit>();
    String? imageUrl = _existingImageUrl;

    // Upload image if selected
    if (_selectedImage != null) {
      final offerId =
          widget.offerId ?? DateTime.now().millisecondsSinceEpoch.toString();
      imageUrl = await cubit.uploadOfferImage(_selectedImage!, offerId);
    }

    final price = double.tryParse(_priceController.text) ?? 0;
    final duration = int.tryParse(_durationController.text);

    if (isEditing) {
      cubit.updateOffer(
        id: widget.offerId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        durationDays: duration,
        imageUrl: imageUrl,
      );
    } else {
      cubit.createOffer(
        channelId: widget.channelId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        durationDays: duration,
        imageUrl: imageUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfferCubit, OfferState>(
      listener: (context, state) {
        if (state is OfferOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.pop(context);
        } else if (state is OfferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<OfferCubit, OfferState>(
        builder: (context, state) {
          final isLoading = state is OfferLoading;

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
                            isEditing ? 'تعديل العرض' : 'إضافة عرض جديد',
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
                                  // Offer Image
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
                                            controller: _titleController,
                                            decoration: InputDecoration(
                                              labelText: 'عنوان العرض *',
                                              prefixIcon: const Icon(
                                                Icons.title_outlined,
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
                                                return 'الرجاء إدخال عنوان العرض';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _descriptionController,
                                            maxLines: 3,
                                            decoration: InputDecoration(
                                              labelText: 'وصف العرض',
                                              alignLabelWithHint: true,
                                              prefixIcon: const Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 40,
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
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _priceController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'السعر *',
                                                    prefixIcon: const Icon(
                                                      Icons.attach_money,
                                                    ),
                                                    suffixText: 'ر.ي',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white
                                                        .withOpacity(0.5),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'أدخل السعر';
                                                    }
                                                    if (double.tryParse(
                                                          value,
                                                        ) ==
                                                        null) {
                                                      return 'رقم غير صالح';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _durationController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                    labelText: 'المدة (أيام)',
                                                    prefixIcon: const Icon(
                                                      Icons.schedule,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.white
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                                    : 'إضافة العرض',
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
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryOrange.withOpacity(0.1),
              AppColors.primaryBlue.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryOrange.withOpacity(0.3),
            width: 2,
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'إضافة صورة للعرض',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اختياري',
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
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
