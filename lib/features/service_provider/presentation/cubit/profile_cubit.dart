import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/provider_profile_model.dart';
import '../../data/services/image_upload_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SupabaseClient _supabase;
  final ImageUploadService _imageService;

  ProfileCubit({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client,
      _imageService = ImageUploadService(supabase: supabase),
      super(ProfileInitial());

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> loadProfile() async {
    if (_userId == null) {
      emit(const ProfileError('لم يتم تسجيل الدخول'));
      return;
    }

    emit(ProfileLoading());
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', _userId!)
          .single();

      final profile = ProviderProfileModel.fromJson(response);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError('فشل في تحميل الملف الشخصي: $e'));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_userId == null) {
      emit(const ProfileError('لم يتم تسجيل الدخول'));
      return;
    }

    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileLoading());
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await _supabase.from('users').update(updateData).eq('id', _userId!);

      // Fetch updated profile data
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', _userId!)
          .single();

      final updatedProfile = ProviderProfileModel.fromJson(response);

      // First emit success, then emit loaded state with new data
      emit(const ProfileUpdateSuccess('تم تحديث الملف الشخصي بنجاح'));

      // Use Future.delayed to allow UI to process success state first
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError('فشل في تحديث الملف الشخصي: $e'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(currentState.profile));
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    try {
      final image = await _imageService.pickImageFromGallery();
      if (image == null) return;

      emit(ProfileLoading());
      final avatarUrl = await _imageService.uploadAvatar(image);

      if (avatarUrl != null) {
        // Update avatar in database
        await _supabase
            .from('users')
            .update({'avatar_url': avatarUrl})
            .eq('id', _userId!);

        // Fetch updated profile
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', _userId!)
            .single();

        final updatedProfile = ProviderProfileModel.fromJson(response);
        emit(ProfileLoaded(updatedProfile));
      } else {
        emit(ProfileLoaded(currentState.profile));
      }
    } catch (e) {
      emit(ProfileError('فشل في تحميل الصورة: $e'));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileLoaded(currentState.profile));
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError('فشل في تسجيل الخروج: $e'));
    }
  }
}
