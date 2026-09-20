import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Royal Emerald & Electric Mint Brand Colors
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryHover = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFFECFDF5); // Mint 50
  static const Color primaryDark = Color(0xFF064E3B); // Deep Emerald
  static const Color primaryGlow = Color(0x4D10B981); // Emerald Glow
  static const Color mintNeon = Color(0xFF00F5A0); // Electric Mint

  // Cyber Cyan Secondary Accent
  static const Color secondary = Color(0xFF06B6D4); // Cyan 500
  static const Color secondaryHover = Color(0xFF0891B2); // Cyan 600
  static const Color secondaryLight = Color(0xFFECFEFF); // Cyan 50
  static const Color secondaryDark = Color(0xFF0E7490); // Cyan 700
  static const Color secondaryGlow = Color(0x3306B6D4);

  // Champagne Gold & Amber Luxury Accents
  static const Color gold = Color(0xFFF59E0B); // Amber 500
  static const Color goldLight = Color(0xFFFEF3C7); // Amber 100
  static const Color goldDark = Color(0xFFB45309); // Amber 700
  static const Color goldGlow = Color(0x33F59E0B);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successDark = Color(0xFF047857);
  static const Color successGlow = Color(0x3310B981);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningGlow = Color(0x33F59E0B);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorGlow = Color(0x33EF4444);

  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFFECFEFF);
  static const Color infoDark = Color(0xFF0E7490);

  // Neutral Scales (Slate & Platinum)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF080C14); // True Obsidian

  // Light Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightSubtle = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderLightFocused = Color(0xFFA7F3D0);

  // Dark Luxury Surfaces (Obsidian & Midnight Sapphire)
  static const Color backgroundDark = Color(0xFF080C14);
  static const Color surfaceDark = Color(0xFF0D1525);
  static const Color surfaceDarkCard = Color(0xFF131D31);
  static const Color surfaceDarkHigher = Color(0xFF1C2A44);
  static const Color borderDark = Color(0xFF1E2E4A);
  static const Color borderDarkSubtle = Color(0xFF2B3D5B);

  // Glassmorphism tokens
  static const Color glassFillLight = Color(0xCCFFFFFF);
  static const Color glassBorderLight = Color(0x66FFFFFF);
  static const Color glassFillDark = Color(0xB3131D31);
  static const Color glassBorderDark = Color(0x3300F5A0);

  // Common Constants
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}

class AppGradients {
  AppGradients._();

  // Royal Emerald Luxury (Electric Mint to Deep Emerald)
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF00F5A0), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Emerald Mint Solid
  static const LinearGradient emeraldMint = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Aurora Midnight Hero Gradient
  static const LinearGradient hero = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF0C2731), Color(0xFF080C14)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyber Cyan Accent
  static const LinearGradient accentCyan = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Champagne Gold & Amber Luxury
  static const LinearGradient accentAmber = LinearGradient(
    colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Purple / Violet Gradient
  static const LinearGradient accentPurple = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Obsidian Luxury Card Gradient
  static const LinearGradient cardDark = LinearGradient(
    colors: [Color(0xFF152238), Color(0xFF0D1627)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Porcelain Card Gradient
  static const LinearGradient cardLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glowing Glass Border
  static const LinearGradient glassBorder = LinearGradient(
    colors: [Color(0x6600F5A0), Color(0x2606B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ambient Mesh Glow Orbs
  static const RadialGradient ambientEmerald = RadialGradient(
    colors: [Color(0x3300F5A0), Colors.transparent],
    radius: 0.8,
  );

  static const RadialGradient ambientCyan = RadialGradient(
    colors: [Color(0x2606B6D4), Colors.transparent],
    radius: 0.8,
  );
}
