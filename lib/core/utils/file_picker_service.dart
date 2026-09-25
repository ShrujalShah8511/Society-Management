import 'file_picker_stub.dart'
    if (dart.library.html) 'file_picker_web.dart';

export 'file_picker_stub.dart'
    if (dart.library.html) 'file_picker_web.dart';

class FilePickerService {
  const FilePickerService._();

  static Future<PickedFileData?> pickImage() => pickImageFileImpl();
}
