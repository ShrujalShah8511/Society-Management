import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_client_manager.dart';
import 'file_storage_service.dart';

/// Production File Storage Service implementation backed by Supabase Storage
class SupabaseFileStorageService implements FileStorageService {
  final String bucketName;
  final FileStorageService _fallbackMock = MockFileStorageService();

  SupabaseFileStorageService({this.bucketName = 'society-assets'});

  @override
  Future<String> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final client = SupabaseClientManager.client;
    if (client == null) {
      if (kDebugMode) debugPrint('[SupabaseFileStorageService] Supabase not initialized, falling back to mock storage.');
      return _fallbackMock.uploadFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      );
    }

    try {
      final sanitizedName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      final path = 'uploads/$sanitizedName';

      await client.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: true,
        ),
      );

      final publicUrl = client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseFileStorageService] Upload error: $e');
      return _fallbackMock.uploadFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      );
    }
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    final client = SupabaseClientManager.client;
    if (client == null) {
      return _fallbackMock.deleteFile(fileUrl);
    }

    try {
      final uri = Uri.parse(fileUrl);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        final path = segments.sublist(bucketIndex + 1).join('/');
        await client.storage.from(bucketName).remove([path]);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[SupabaseFileStorageService] Delete error: $e');
    }
  }
}
