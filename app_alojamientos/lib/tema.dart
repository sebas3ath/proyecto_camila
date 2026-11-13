import 'package:flutter/material.dart';

// Paleta STAYLINK: coral y durazno (principales), menta y lavanda (acentos), fondo crema.
const Color coral = Color(0xFFFF705A);
const Color coralClaro = Color(0xFFFF8C64);
const Color durazno = Color(0xFFFFB08C);
const Color crema = Color(0xFFFFF8F3);
const Color tinta = Color(0xFF2B2D42);
const Color gris = Color(0xFF7D7D91);
const Color menta = Color(0xFF54C8BE);
const Color mentaClaro = Color(0xFFD7F7F2);
const Color mentaOscuro = Color(0xFF146E68);
const Color lavanda = Color(0xFFBEACFF);
const Color lavandaClaro = Color(0xFFECE6FF);
const Color chipFondo = Color(0xFFFFECE4);
const Color campoFondo = Color(0xFFFFF4EE);
const Color linea = Color(0xFFF0E2DA);

const LinearGradient degradeCoral = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [coral, durazno],
);

List<BoxShadow> get sombraSuave => [
      BoxShadow(
          color: const Color(0xFF783C28).withAlpha(30),
          blurRadius: 18,
          offset: const Offset(0, 6)),
    ];

ThemeData temaStaylink() {
  final cs = ColorScheme.fromSeed(seedColor: coral, brightness: Brightness.light).copyWith(
    primary: coral,
    onPrimary: Colors.white,
    secondary: menta,
    tertiary: lavanda,
    surface: crema,
    onSurface: tinta,
    surfaceContainerLow: Colors.white,
  );
  const radio = BorderRadius.all(Radius.circular(16));
  const bordeLinea = OutlineInputBorder(borderRadius: radio, borderSide: BorderSide(color: linea));
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: crema,
    appBarTheme: const AppBarTheme(
      backgroundColor: crema,
      foregroundColor: tinta,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(color: tinta, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      border: bordeLinea,
      enabledBorder: bordeLinea,
      focusedBorder:
          OutlineInputBorder(borderRadius: radio, borderSide: BorderSide(color: coral, width: 1.6)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: coral,
        side: const BorderSide(color: coral, width: 1.4),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: coral)),
    chipTheme: ChipThemeData(
      backgroundColor: chipFondo,
      selectedColor: const Color(0xFFFFD3C4),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(color: tinta),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xFFFFE1D6),
      surfaceTintColor: Colors.transparent,
    ),
    sliderTheme: const SliderThemeData(activeTrackColor: coral, thumbColor: coral),
  );
}
