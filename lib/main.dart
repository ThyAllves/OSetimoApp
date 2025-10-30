import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:osetimo_app/pages/biblia.dart';
import 'package:osetimo_app/pages/info.dart';
import 'package:osetimo_app/pages/notas.dart';
import 'package:osetimo_app/pages/pesquisaPage.dart';
import 'package:osetimo_app/pages/sermoes.dart';
import 'theme/app_theme.dart';
import 'pages/welcome.dart';
import 'pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OSetimoApp());
}

class OSetimoApp extends StatelessWidget {
  const OSetimoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O Sétimo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.osetimoTheme,
      home: const WelcomePage(),
      routes: {
        '/home': (_) => const HomePage(),
        '/biblia': (_) => const BibliaPage(),
        '/sermoes': (_) => const SermoesPage(),
        '/pesquisa': (_) => const PesquisaPage(),
        '/notas': (_) => const NotasPage(),
        '/info': (_) => const InfoPage(),
      },
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en'),
      ],
      locale: const Locale('pt'),
    );
  }
}
