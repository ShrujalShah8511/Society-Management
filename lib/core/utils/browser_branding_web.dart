// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void updateBrowserBrandingImpl({
  required String title,
  String? logoUrl,
}) {
  try {
    // 1. Update Document Title
    html.document.title = title;

    // 2. Locate or create Favicon <link> tags
    var favicon = html.document.getElementById('app-favicon') as html.LinkElement?;
    if (favicon == null) {
      favicon = html.document.querySelector("link[rel*='icon']") as html.LinkElement?;
      if (favicon == null) {
        favicon = html.LinkElement()
          ..id = 'app-favicon'
          ..rel = 'icon'
          ..type = 'image/png';
        html.document.head?.append(favicon);
      }
    }

    var appleIcon = html.document.getElementById('app-apple-icon') as html.LinkElement?;
    if (appleIcon == null) {
      appleIcon = html.document.querySelector("link[rel='apple-touch-icon']") as html.LinkElement?;
      if (appleIcon == null) {
        appleIcon = html.LinkElement()
          ..id = 'app-apple-icon'
          ..rel = 'apple-touch-icon';
        html.document.head?.append(appleIcon);
      }
    }

    // Determine target icon URL
    String targetHref;
    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      targetHref = logoUrl.trim();
    } else {
      targetHref = 'favicon.png';
    }

    favicon.href = targetHref;
    appleIcon.href = targetHref;
  } catch (_) {
    // Graceful fallback if DOM is not accessible in context
  }
}
