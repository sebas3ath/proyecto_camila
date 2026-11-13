import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'store.dart';
import 'tema.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Se abre la interfaz de inmediato; los datos se cargan en la pantalla de arranque.
  runApp(const StaylinkApp());
}

class StaylinkApp extends StatelessWidget {
  const StaylinkApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'STAYLINK',
        debugShowCheckedModeBanner: false,
        theme: temaStaylink(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es', 'CO'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Arranque(),
      );
}

/// Carga los datos y muestra el inicio. Si algo falla, muestra el error en pantalla
/// (en vez de quedarse cargando para siempre).
class Arranque extends StatefulWidget {
  const Arranque({super.key});
  @override
  State<Arranque> createState() => _ArranqueState();
}

class _ArranqueState extends State<Arranque> {
  late Future<void> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<void> _cargar() => Store.instance.init().timeout(const Duration(seconds: 20));

  void _reintentar({required bool borrar}) {
    setState(() {
      _futuro = borrar ? Store.instance.borrarDatos().then((_) => _cargar()) : _cargar();
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando STAYLINK...'),
                ]),
              ),
            );
          }
          if (snap.hasError) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      const Text('No se pudo iniciar la app',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText('${snap.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () => _reintentar(borrar: false), child: const Text('Reintentar')),
                      const SizedBox(height: 8),
                      OutlinedButton(
                          onPressed: () => _reintentar(borrar: true),
                          child: const Text('Borrar datos y reintentar')),
                    ]),
                  ),
                ),
              ),
            );
          }
          return const HomeScreen();
        },
      );
}
