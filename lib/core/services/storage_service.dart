import 'dart:io';
import 'package:smart_glove/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  StorageService._();

  /// Upload avatar and return public URL. Throws on failure.
  static Future<String?> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final safeExt = ['jpg', 'jpeg', 'png', 'webp'].contains(ext)
          ? ext
          : 'jpg';
      final path = '$userId/avatar.$safeExt';

      debugPrint('[StorageService] Uploading avatar → avatars/$path');

      await supabase.storage
          .from('avatars')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final url = supabase.storage.from('avatars').getPublicUrl(path);
      final result = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[StorageService] Avatar URL: $result');
      return result;
    } catch (e) {
      debugPrint('[StorageService] uploadAvatar ERROR: $e');
      rethrow; // Let caller handle + show error
    }
  }

  /// Upload medical record and return public URL. Throws on failure.
  static Future<String?> uploadMedicalRecord({
    required String userId,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final safeExt = ['jpg', 'jpeg', 'png', 'pdf'].contains(ext) ? ext : 'jpg';
      final path = '$userId/record.$safeExt';

      debugPrint('[StorageService] Uploading record → medical-records/$path');

      await supabase.storage
          .from('medical-records')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final url = supabase.storage.from('medical-records').getPublicUrl(path);
      final result = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[StorageService] Medical record URL: $result');
      return result;
    } catch (e) {
      debugPrint('[StorageService] uploadMedicalRecord ERROR: $e');
      rethrow;
    }
  }
}
