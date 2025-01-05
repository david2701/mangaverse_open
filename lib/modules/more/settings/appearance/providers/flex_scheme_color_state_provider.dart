import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/theme_mode_state_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'flex_scheme_color_state_provider.g.dart';

@riverpod
class FlexSchemeColorState extends _$FlexSchemeColorState {
  @override
  FlexSchemeColor build() {
    final settings = isar.settings.getSync(227)!;
    final flexSchemeColorIndex = settings.flexSchemeColorIndex!;
    
    // Si el índice está fuera de rango, resetear a 0 (Blood Moon theme)
    if (flexSchemeColorIndex >= ThemeAA.schemes.length) {
      isar.writeTxnSync(() => 
        isar.settings.putSync(settings..flexSchemeColorIndex = 0)
      );
      return ref.read(themeModeStateProvider)
          ? ThemeAA.schemes[0].dark
          : ThemeAA.schemes[0].light;
    }

    return ref.read(themeModeStateProvider)
        ? ThemeAA.schemes[flexSchemeColorIndex].dark
        : ThemeAA.schemes[flexSchemeColorIndex].light;
  }

  void setTheme(FlexSchemeColor color, int index) {
    final settings = isar.settings.getSync(227);
    state = color;
    isar.writeTxnSync(
        () => isar.settings.putSync(settings!..flexSchemeColorIndex = index));
  }
}

class ThemeAA {
  static List<FlexSchemeData> schemes = <FlexSchemeData>[
    // Tema principal rojo con negro
    const FlexSchemeData(
      name: 'Blood Moon',
      description: 'Elegant dark red theme',
      light: FlexSchemeColor(
        primary: Color(0xFFD32F2F),
        primaryContainer: Color(0xFFFFCDD2),
        secondary: Color(0xFF212121),
        secondaryContainer: Color(0xFF616161),
        tertiary: Color(0xFF880E4F),
        tertiaryContainer: Color(0xFFFF80AB),
        appBarColor: Color(0xFF1A1A1A),
        error: Color(0xFFB71C1C),
        errorContainer: Color(0xFFFFEBEE),
      ),
      dark: FlexSchemeColor(
        primary: Color(0xFFFF5252),
        primaryContainer: Color(0xFFB71C1C),
        secondary: Color(0xFF424242),
        secondaryContainer: Color(0xFF212121),
        tertiary: Color(0xFFFF80AB),
        tertiaryContainer: Color(0xFF880E4F),
        appBarColor: Color(0xFF0A0A0A),
        error: Color(0xFFFF1744),
        errorContainer: Color(0xFFB71C1C),
      ),
    ),
    // Tema azul profundo
    const FlexSchemeData(
      name: 'Deep Ocean',
      description: 'Calm blue theme',
      light: FlexSchemeColor(
        primary: Color(0xFF1976D2),
        primaryContainer: Color(0xFFBBDEFB),
        secondary: Color(0xFF455A64),
        secondaryContainer: Color(0xFFCFD8DC),
        tertiary: Color(0xFF0277BD),
        tertiaryContainer: Color(0xFFB3E5FC),
        appBarColor: Color(0xFF1565C0),
        error: Color(0xFFD32F2F),
        errorContainer: Color(0xFFFFEBEE),
      ),
      dark: FlexSchemeColor(
        primary: Color(0xFF42A5F5),
        primaryContainer: Color(0xFF1565C0),
        secondary: Color(0xFF78909C),
        secondaryContainer: Color(0xFF455A64),
        tertiary: Color(0xFF4FC3F7),
        tertiaryContainer: Color(0xFF0277BD),
        appBarColor: Color(0xFF0D47A1),
        error: Color(0xFFEF5350),
        errorContainer: Color(0xFFB71C1C),
      ),
    ),
    // Tema verde esmeralda
    const FlexSchemeData(
      name: 'Emerald Forest',
      description: 'Serene green theme',
      light: FlexSchemeColor(
        primary: Color(0xFF2E7D32),
        primaryContainer: Color(0xFFC8E6C9),
        secondary: Color(0xFF37474F),
        secondaryContainer: Color(0xFFCFD8DC),
        tertiary: Color(0xFF00695C),
        tertiaryContainer: Color(0xFFB2DFDB),
        appBarColor: Color(0xFF1B5E20),
        error: Color(0xFFC62828),
        errorContainer: Color(0xFFFFCDD2),
      ),
      dark: FlexSchemeColor(
        primary: Color(0xFF66BB6A),
        primaryContainer: Color(0xFF2E7D32),
        secondary: Color(0xFF546E7A),
        secondaryContainer: Color(0xFF37474F),
        tertiary: Color(0xFF4DB6AC),
        tertiaryContainer: Color(0xFF00695C),
        appBarColor: Color(0xFF1B5E20),
        error: Color(0xFFEF5350),
        errorContainer: Color(0xFFB71C1C),
      ),
    ),
    // Tema morado místico
    const FlexSchemeData(
      name: 'Mystic Purple',
      description: 'Elegant purple theme',
      light: FlexSchemeColor(
        primary: Color(0xFF6A1B9A),
        primaryContainer: Color(0xFFE1BEE7),
        secondary: Color(0xFF303030),
        secondaryContainer: Color(0xFF9E9E9E),
        tertiary: Color(0xFF4A148C),
        tertiaryContainer: Color(0xFFD1C4E9),
        appBarColor: Color(0xFF4A148C),
        error: Color(0xFFC62828),
        errorContainer: Color(0xFFFFCDD2),
      ),
      dark: FlexSchemeColor(
        primary: Color(0xFFAB47BC),
        primaryContainer: Color(0xFF6A1B9A),
        secondary: Color(0xFF424242),
        secondaryContainer: Color(0xFF303030),
        tertiary: Color(0xFF9C27B0),
        tertiaryContainer: Color(0xFF4A148C),
        appBarColor: Color(0xFF4A148C),
        error: Color(0xFFE57373),
        errorContainer: Color(0xFFB71C1C),
      ),
    ),
    // Tema gris sombra
    const FlexSchemeData(
      name: 'Shadow Gray',
      description: 'Minimalist gray theme',
      light: FlexSchemeColor(
        primary: Color(0xFF424242),
        primaryContainer: Color(0xFFE0E0E0),
        secondary: Color(0xFF616161),
        secondaryContainer: Color(0xFFEEEEEE),
        tertiary: Color(0xFF757575),
        tertiaryContainer: Color(0xFFF5F5F5),
        appBarColor: Color(0xFF212121),
        error: Color(0xFFD32F2F),
        errorContainer: Color(0xFFFFEBEE),
      ),
      dark: FlexSchemeColor(
        primary: Color(0xFF757575),
        primaryContainer: Color(0xFF424242),
        secondary: Color(0xFF9E9E9E),
        secondaryContainer: Color(0xFF616161),
        tertiary: Color(0xFFBDBDBD),
        tertiaryContainer: Color(0xFF757575),
        appBarColor: Color(0xFF212121),
        error: Color(0xFFE57373),
        errorContainer: Color(0xFFB71C1C),
      ),
    ),
  ];
}
