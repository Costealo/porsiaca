import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Costealo Colors
  static const Color verdePrincipal = Color(0xFF4CAF50);
  static const Color verdeSuave = Color(0xFF81C784);
  static const Color verdePastel = Color(0xFFC8E6C9);
  static const Color verdeOscuro = Color(0xFF2E7D32);
  
  static const Color rosaCostealo = Color(0xFFF7A8B8);
  static const Color rosaSuave = Color(0xFFFBD0D9);
  static const Color rosaPastel = Color(0xFFFFE6EC);
  static const Color rosaProfundo = Color(0xFFE0647B);
  
  static const Color lilaPrincipal = Color(0xFFA78BFA);
  static const Color lilaPastel = Color(0xFFDAD0FF);
  static const Color lilaLavanda = Color(0xFFEDE9FE);
  
  static const Color blanco = Colors.white;
  static const Color negro = Color(0xFF1F2937);
  static const Color grisClaro = Color(0xFFF3F4F6);
  static const Color grisMedio = Color(0xFF9CA3AF);
  static const Color grisOscuro = Color(0xFF4B5563);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: verdePrincipal,
      scaffoldBackgroundColor: grisClaro,
      
      colorScheme: const ColorScheme.light(
        primary: verdePrincipal,
        secondary: rosaCostealo,
        tertiary: lilaPrincipal,
        surface: blanco,
        error: rosaProfundo,
      ),
      
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: negro,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: negro,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: negro,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: negro,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: grisOscuro,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grisClaro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grisClaro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lilaPrincipal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verdePrincipal,
          foregroundColor: blanco,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: blanco,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
