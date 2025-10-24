import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/lista_anuncios_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primaryColor: const Color(0xFFFFE600),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFFFFE600), 
        secondary: const Color(0xFF3483FA),
        surface: const Color(0xFFF5F5F5),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 1.0,
        backgroundColor: Color(0xFFFFE600),
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Color(0xFF3483FA),
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'Mercado Livre',
      theme: theme,
      home: const ListaAnunciosScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
