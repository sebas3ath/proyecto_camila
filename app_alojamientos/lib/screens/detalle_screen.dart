import 'package:flutter/material.dart';
import '../constants.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';
import 'auth_screen.dart';
import 'reservar_screen.dart';

class DetalleScreen extends StatefulWidget {
  final String lugarId;
  const DetalleScreen({super.key, required this.lugarId});
  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final s = Store.instance;
  int _pagina = 0;

  Future<void> _reservar(Lugar l) async {
    if (s.usuario == null) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => const AuthScreen(mensaje: 'Inicia sesión o crea tu cuenta para reservar')));
      if (ok != true || !mounted) return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReservarScreen(lugarId: l.id)));
  }

  Widget _titulo(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final l = s.lugar(widget.lugarId);
          if (l == null) return const Scaffold();
          final host = s.usuarioPorId(l.anfitrionId);
          final fotos = l.fotos.isEmpty ? [''] : l.fotos;
          return Scaffold(
            appBar: AppBar(title: Text(l.tipo)),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(children: [
                  Expanded(
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cop(l.precioNoche), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('por noche', style: TextStyle(fontSize: 12)),
                    ]),
                  ),
                  FilledButton(onPressed: () => _reservar(l), child: const Text('Reservar')),
                ]),
              ),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(children: [
                  SizedBox(
                    height: 260,
                    child: Stack(children: [
                      PageView(
                        onPageChanged: (i) => setState(() => _pagina = i),
                        children: [for (final f in fotos) FotoLugar(f)],
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          for (var i = 0; i < fotos.length; i++)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _pagina ? 18 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: i == _pagina ? Colors.white : Colors.white70,
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                        ]),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.place, size: 18),
                        const SizedBox(width: 4),
                        Expanded(child: Text('${l.direccion}, ${l.ciudad}')),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        Chip(avatar: const Icon(Icons.people_outline, size: 18), label: Text('${l.capacidad} huéspedes')),
                        Chip(avatar: const Icon(Icons.bed_outlined, size: 18), label: Text('${l.habitaciones} hab.')),
                        Chip(avatar: const Icon(Icons.bathtub_outlined, size: 18), label: Text('${l.banos} baños')),
                      ]),
                      _titulo('Descripción'),
                      Text(l.descripcion),
                      _titulo('Comodidades'),
                      Wrap(spacing: 8, runSpacing: 6, children: [for (final c in l.comodidades) Chip(label: Text(c))]),
                      _titulo('Disponibilidad'),
                      Text('Del ${fecha(l.desde)} al ${fecha(l.hasta)}\n'
                          'Estancia de ${l.minNoches} a ${l.maxNoches} noches'),
                      _titulo('Anfitrión'),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Icon(host?.esEmpresa == true ? Icons.business : Icons.person)),
                        title: Text(host?.nombreVisible ?? 'Anfitrión'),
                        subtitle: Text(host?.esEmpresa == true ? 'Empresa · NIT ${host!.nit}' : 'Persona'),
                      ),
                      _titulo('Proceso para acceder a este lugar'),
                      _Proceso(l),
                      _titulo('Reglas y cancelación'),
                      Text(l.req.reglas.isEmpty ? 'Sin reglas adicionales.' : l.req.reglas),
                      const SizedBox(height: 6),
                      Text('Cancelación ${l.req.cancelacion.toLowerCase()}: ${textoCancelacion[l.req.cancelacion] ?? ''}'),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        },
      );
}

/// Pasos que debe seguir el huésped, armados con las condiciones del anfitrión.
class _Proceso extends StatelessWidget {
  final Lugar l;
  const _Proceso(this.l);

  @override
  Widget build(BuildContext context) {
    final r = l.req;
    final pasos = <List<String>>[
      ['Crea tu cuenta o inicia sesión', 'Necesitas una cuenta para enviar tu solicitud.'],
      ['Elige fechas y huéspedes', 'Del ${fecha(l.desde)} al ${fecha(l.hasta)}. Estancia de ${l.minNoches} a ${l.maxNoches} noches, hasta ${l.capacidad} huéspedes.'],
      ['Registra tus datos', 'Nombre, teléfono y documento: ${r.documento.toLowerCase()}.'],
      [
        'Paga el anticipo',
        (r.anticipoPct == 0 ? 'Este lugar no pide anticipo.' : 'Anticipo del ${r.anticipoPct}% del valor total.') +
            (r.deposito > 0 ? ' Depósito de garantía reembolsable de ${cop(r.deposito)}.' : '') +
            ' (En este demo el pago es simulado).'
      ],
      ['Espera la confirmación del anfitrión', 'La verás en "Mis reservas" cuando la acepte.'],
      ['Recibe las instrucciones de acceso', 'Check-in desde las ${r.checkIn} y check-out hasta las ${r.checkOut}. Las instrucciones se muestran al confirmar.'],
    ];
    final color = Theme.of(context).colorScheme.primary;
    return Column(children: [
      for (var i = 0; i < pasos.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                radius: 14,
                backgroundColor: color,
                child: Text('${i + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 13))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pasos[i][0], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(pasos[i][1], style: const TextStyle(fontSize: 13)),
              ]),
            ),
          ]),
        ),
    ]);
  }
}
