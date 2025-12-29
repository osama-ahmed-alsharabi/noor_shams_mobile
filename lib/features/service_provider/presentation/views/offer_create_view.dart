import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_shams_mobile/core/utils/app_colors.dart';
import 'package:noor_shams_mobile/core/utils/glass_box.dart';
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

  const OfferCreateView({
    super.key,
    required this.channelId,
    this.offerId,
    this.initialTitle,
    this.initialDescription,
    this.initialPrice,
    this.initialDurationDays,
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

  bool get isEditing => widget.offerId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _priceController = TextEditingController(
      text: widget.initialPrice?.toStringAsFixed(0),
    );
    _durationController = TextEditingController(
      text: widget.initialDurationDays?.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<OfferCubit>();
      final price = double.parse(_priceController.text.trim());
      final duration = _durationController.text.trim().isNotEmpty
          ? int.parse(_durationController.text.trim())
          : null;

      if (isEditing) {
        cubit.updateOffer(
          id: widget.offerId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          durationDays: duration,
        );
      } else {
        cubit.createOffer(
          channelId: widget.channelId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          durationDays: duration,
        );
      }
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
      child: Scaffold(
        body: Stack(
          children: [
            const ProviderBackground(),
            SafeArea(
              child: Column(
                children: [
                  AppBar(
                    title: Text(isEditing ? 'تعديل العرض' : 'إضافة عرض جديد'),
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
                                  'تفاصيل العرض',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    labelText: 'عنوان العرض',
                                    hintText: 'مثال: تركيب منظومة شمسية 5 كيلو',
                                    prefixIcon: const Icon(Icons.title),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.5),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'الرجاء إدخال عنوان العرض';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'وصف العرض',
                                    hintText: 'وصف تفصيلي للخدمة المقدمة',
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
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'السعر (ر.ي)',
                                          prefixIcon: const Icon(
                                            Icons.attach_money,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'مطلوب';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'قيمة غير صالحة';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _durationController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'المدة (بالأيام)',
                                          prefixIcon: const Icon(
                                            Icons.schedule,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                BlocBuilder<OfferCubit, OfferState>(
                                  builder: (context, state) {
                                    final isLoading = state is OfferLoading;
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
                                                    : 'إضافة العرض',
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
