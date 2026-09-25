// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

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
  final completer = Completer<PickedFileData?>();
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/png,image/jpeg,image/webp,image/svg+xml'
    ..multiple = false;

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.onLoadEnd.listen((event) {
        final result = reader.result as String?;
        if (result != null) {
          completer.complete(PickedFileData(
            name: file.name,
            dataUrl: result,
            size: file.size,
          ));
        } else {
          completer.complete(null);
        }
      });
      reader.onError.listen((event) {
        completer.complete(null);
      });
      reader.readAsDataUrl(file);
    } else {
      completer.complete(null);
    }
  });

  uploadInput.click();
  return completer.future;
}
