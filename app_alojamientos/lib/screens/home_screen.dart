import 'package:flutter/material.dart';
import '../filtro.dart';
import '../store.dart';
import '../tema.dart';
import '../utils.dart';
import '../widgets.dart';
import 'anfitrion_screen.dart';
import 'auth_screen.dart';
import 'ciudad_screen.dart';
import 'explorar_screen.dart';
import 'filtros_sheet.dart';
import 'mis_reservas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final s = Store.instance;
  final FiltroBusqueda f = FiltroBusqueda(huespedes: 2);

  /// Si no hay sesión, pide iniciar. Devuelve true si ya hay sesión.
  Future<bool> _requiereSesion(String mensaje) async {
    if (s.usuario != null) return true;
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => AuthScreen(mensaje: mensaje)));
    return ok == true && mounted;
  }

  Future<void> _ciudad() async {
    final r = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (_) => CiudadScreen(actual: f.ciudad)));
    if (r != null) setState(() => f.ciudad = r.isEmpty ? null : r);
  }

  Future<void> _fechas() async {
    final r = await elegirFechas(context, f);
    if (r != null) setState(() {
      f.desde = r.start;
      f.hasta = r.end;
    });
  }

  void _huespedes() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Expanded(child: Text('Huéspedes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              StepperCantidad(
                  valor: f.huespedes,
                  onChanged: (v) {
                    setSheet(() => f.huespedes = v);
                    setState(() {});
                  }),
            ]),
            const SizedBox(height: 20),
            BotonDegradado(texto: 'Listo', onPressed: () => Navigator.pop(context)),
          ]),
        ),
      ),
    );
  }

  void _buscar([String? ciudad]) {
    final filtro = f.copia();
    if (ciudad != null) filtro.ciudad = ciudad;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ExplorarScreen(filtro: filtro)));
  }

  Future<void> _publicar() async {
    if (!await _requiereSesion('Inicia sesión para publicar tu lugar')) return;
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AnfitrionScreen()));
  }

  Future<void> _reservas() async {
    if (!await _requiereSesion('Inicia sesión para ver tus reservas')) return;
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MisReservasScreen()));
  }

  Future<void> _perfil() async {
    final u = s.usuario;
    if (u == null) {
      await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
              radius: 30,
              backgroundColor: coral,
              child: Text(u.nombreVisible.isEmpty ? '?' : u.nombreVisible[0].toUpperCase(),
                  style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w800))),
          const SizedBox(height: 10),
          Text(u.nombreVisible, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(u.correo, style: const TextStyle(color: gris)),
          const SizedBox(height: 18),
          OutlinedButton.icon(
              onPressed: () {
                s.salir();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final u = s.usuario;
          final ciudades = s.ciudadesConLugares();
          return Scaffold(
            backgroundColor: crema,
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (i) {
                if (i == 1) _reservas();
                if (i == 2) _publicar();
                if (i == 3) _perfil();
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Explorar'),
                NavigationDestination(icon: Icon(Icons.event_available_outlined), label: 'Reservas'),
                NavigationDestination(icon: Icon(Icons.add_home_work_outlined), label: 'Publicar'),
                NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Perfil'),
              ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Stack(children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 360,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [coral, durazno]),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                        ),
                      ),
                    ),
                    Positioned(
                        right: -40,
                        top: -30,
                        child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle))),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.home_rounded, color: coral)),
                            const SizedBox(width: 10),
                            const Expanded(
                                child: Text('STAYLINK',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
                            InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _perfil,
                              child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: u == null
                                      ? const Icon(Icons.person_outline, color: coral, size: 20)
                                      : Text(u.nombreVisible.isEmpty ? '?' : u.nombreVisible[0].toUpperCase(),
                                          style: const TextStyle(color: coral, fontWeight: FontWeight.w800))),
                            ),
                          ]),
                          const SizedBox(height: 26),
                          const Text('Encuentra tu lugar\npara quedarte',
                              style: TextStyle(color: Colors.white, fontSize: 30, height: 1.12, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          const Text('Alojamientos por temporada, sin intermediarios.',
                              style: TextStyle(color: Color(0xFFFFF4EE), fontSize: 13)),
                          const SizedBox(height: 22),
                          _tarjetaBusqueda(),
                          const SizedBox(height: 26),
                          const Text('Ciudades populares',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: ciudades.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (_, i) => _ciudadCard(ciudades[i].key, ciudades[i].value),
                            ),
                          ),
                          const SizedBox(height: 22),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50), backgroundColor: Colors.white),
                            icon: const Icon(Icons.add_home_work_outlined),
                            label: const Text('Quiero publicar mi lugar'),
                            onPressed: _publicar,
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      );

  Widget _tarjetaBusqueda() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: sombraSuave),
        child: Column(children: [
          CampoBusqueda(
              icono: Icons.place_outlined,
              etiqueta: 'Ciudad',
              valor: f.ciudad ?? '¿A dónde vas?',
              vacio: f.ciudad == null,
              onTap: _ciudad),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: CampoBusqueda(
                    icono: Icons.event_outlined,
                    etiqueta: 'Llegada',
                    valor: f.tieneFechas ? fechaCorta(f.desde!) : 'Elegir',
                    vacio: !f.tieneFechas,
                    onTap: _fechas)),
            const SizedBox(width: 10),
            Expanded(
                child: CampoBusqueda(
                    icono: Icons.event_outlined,
                    etiqueta: 'Salida',
                    valor: f.tieneFechas ? fechaCorta(f.hasta!) : 'Elegir',
                    vacio: !f.tieneFechas,
                    onTap: _fechas)),
          ]),
          const SizedBox(height: 10),
          CampoBusqueda(
              icono: Icons.person_outline_rounded,
              etiqueta: 'Huéspedes',
              valor: f.textoHuespedes,
              onTap: _huespedes),
          const SizedBox(height: 14),
          BotonDegradado(texto: 'Buscar alojamientos', icono: Icons.search_rounded, onPressed: () => _buscar()),
        ]),
      );

  Widget _ciudadCard(String ciudad, int n) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _buscar(ciudad),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 112,
            child: Stack(fit: StackFit.expand, children: [
              FotoLugar(s.fotoCiudad(ciudad)),
              const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.center, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xB0281428)])),
              ),
              Positioned(
                left: 10,
                right: 8,
                bottom: 10,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(ciudad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  Text(n == 1 ? '1 lugar' : '$n lugares', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ),
            ]),
          ),
        ),
      );
}
