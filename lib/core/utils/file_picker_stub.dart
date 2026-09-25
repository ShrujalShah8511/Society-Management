class PickedFileData {
  final String name;
  final String dataUrl;
  final int size;

  const PickedFileData({
    required this.name,
    required this.dataUrl,
    required this.size,
  });
}

Future<PickedFileData?> pickImageFileImpl() async {
  // Stub for non-web environments (mobile/desktop fallback to text dialog or URL entry)
  return null;
}
