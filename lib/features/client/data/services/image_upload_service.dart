import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ClientImageUploadService {
  final SupabaseClient _supabase;
  final ImagePicker _picker;

  ClientImageUploadService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client,
      _picker = ImagePicker();

  String get _userId => _supabase.auth.currentUser?.id ?? '';

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
}

/// Helper function to extract phone number from email
String extractPhoneFromEmail(String? email) {
  if (email == null || email.isEmpty) return 'غير محدد';

  final regex = RegExp(r'(client|provider)?(\d+)@');
  final match = regex.firstMatch(email);

  if (match != null && match.group(2) != null) {
    return match.group(2)!;
  }

  return email;
}
