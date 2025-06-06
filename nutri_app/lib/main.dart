import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutri_app/auth_guard.dart';
import 'package:nutri_app/pages/atendimentos/atendimento_home.dart';
import 'package:nutri_app/pages/relatorios/relatorios.dart';
import 'package:nutri_app/pages/usuarios/usuarios.dart';
import 'package:package_info_plus/package_info_plus.dart';
import './firebase/firebase_options.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'package:nutri_app/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final version = await PackageInfo.fromPlatform().then((p) => p.version);
  debugPrint('App version: $version');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.setLanguageCode("pt-BR");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutri App',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5F5F5)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/usuario': (context) => const AuthGuard(child: UsuarioPage()),
        '/relatorio': (context) => const AuthGuard(child: RelatoriosPage()),
        '/home': (context) => AuthGuard(
              child: FutureBuilder<String?>(
                future: PreferencesService.getUserType(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return HomePage(
                    tipoUsuario: snapshot.data ?? 'Professor',
                  );
                },
              ),
            ),
        '/atendimento': (context) => AuthGuard(child: AtendimentoPage())
      },
    );
  }
}
