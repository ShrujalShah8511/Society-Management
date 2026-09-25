import 'browser_branding_stub.dart'
    if (dart.library.html) 'browser_branding_web.dart';

class BrowserBrandingService {
  const BrowserBrandingService._();

  static void updateBranding({
    required String title,
    String? logoUrl,
  }) {
    updateBrowserBrandingImpl(
      title: title,
      logoUrl: logoUrl,
    );
  }
}
