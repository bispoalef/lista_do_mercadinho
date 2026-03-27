import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT DO ADMOB ---
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/theme/theme_provider.dart';
import 'features/compras/providers/lista_produtos.dart';
import 'features/compras/view/pages/dashboard_page.dart';
import 'features/compras/view/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ListaDeProdutos()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MercadoFácil',

            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFFE6A26C),
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFFF6DFC3),
                foregroundColor: Color(0xFF5C7B6D),
              ),
              cardTheme: const CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF8CA99A),
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF1A2B2B),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Color(0xFF2F4F4F),
                foregroundColor: Colors.white,
              ),
              cardTheme: const CardThemeData(
                color: Color(0xFF243A3A),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),

            themeMode: themeProvider.themeMode,
            initialRoute: 'dashboard',
            routes: {
              'dashboard': (context) => const DashboardPage(),
              'home': (context) => const HomePage(),
            },
          );
        },
      ),
    );
  }
}
