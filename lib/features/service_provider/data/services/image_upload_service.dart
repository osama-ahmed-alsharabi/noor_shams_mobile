import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final SupabaseClient _supabase;
  final ImagePicker _picker;

  ImageUploadService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client,
      _picker = ImagePicker();

  String get _userId => _supabase.auth.currentUser?.id ?? '';

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
    } catch (e) {
      throw Exception('فشل في اختيار الصورة: $e');
    }
  }

  /// Upload avatar image
  Future<String?> uploadAvatar(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$_userId/avatar_$timestamp.$fileExt';

      await _supabase.storage
          .from('images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final url = _supabase.storage.from('images').getPublicUrl(fileName);
      return url;
    } catch (e) {
      throw Exception('فشل في رفع الصورة: $e');
    }
  }

  /// Upload channel cover image
  Future<String?> uploadChannelCover(XFile image, String channelId) async {
    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$_userId/channel_${channelId}_$timestamp.$fileExt';

      await _supabase.storage
          .from('images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final url = _supabase.storage.from('images').getPublicUrl(fileName);
      return url;
    } catch (e) {
      throw Exception('فشل في رفع صورة القناة: $e');
    }
  }

  /// Upload offer image
  Future<String?> uploadOfferImage(XFile image, String offerId) async {
    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$_userId/offer_${offerId}_$timestamp.$fileExt';

      await _supabase.storage
          .from('images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final url = _supabase.storage.from('images').getPublicUrl(fileName);
      return url;
    } catch (e) {
      throw Exception('فشل في رفع صورة العرض: $e');
    }
  }
}

/// Helper function to extract phone number from email
/// Example: provider778870086@gmail.com -> 778870086
String extractPhoneFromEmail(String? email) {
  if (email == null || email.isEmpty) return 'غير محدد';

  // Remove role prefix and @gmail.com suffix
  final regex = RegExp(r'(client|provider)?(\d+)@');
  final match = regex.firstMatch(email);

  if (match != null && match.group(2) != null) {
    return match.group(2)!;
  }

  return email;
}
