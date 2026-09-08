import 'dart:typed_data';

abstract class FileStorageService {
  Future<String> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  });

  Future<void> deleteFile(String fileUrl);
}

class MockFileStorageService implements FileStorageService {
  final Map<String, Uint8List> _storedFiles = {};

  @override
  Future<String> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    // Simulating file upload latency
    await Future.delayed(const Duration(milliseconds: 300));
    final fileId = 'file_${DateTime.now().millisecondsSinceEpoch}_$fileName';
    _storedFiles[fileId] = bytes;
    return 'https://storage.society-management.local/uploads/$fileId';
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storedFiles.remove(fileUrl);
  }
}
