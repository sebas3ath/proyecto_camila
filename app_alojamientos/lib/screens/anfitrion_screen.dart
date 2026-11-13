import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';
import 'publicar_screen.dart';

/// Panel del anfitrión (persona o empresa): sus lugares y las solicitudes.
class AnfitrionScreen extends StatelessWidget {
  const AnfitrionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Store.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final u = s.usuario;
        if (u == null) return const Scaffold();
        final lugares = s.misLugares;
        final solicitudes = s.solicitudes;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(u.nombreVisible),
              actions: [
                IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    s.salir();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                ),
              ],
              bottom: TabBar(tabs: [
                const Tab(text: 'Mis lugares'),
                Tab(text: s.pendientes > 0 ? 'Solicitudes (${s.pendientes})' : 'Solicitudes'),
              ]),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PublicarScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Publicar lugar'),
            ),
            body: TabBarView(children: [
              _lista(
                  lugares.isEmpty,
                  'Aún no has publicado ningún lugar.\nToca "Publicar lugar" para empezar.',
                  [for (final l in lugares) _lugar(context, s, l)]),
              _lista(solicitudes.isEmpty, 'Todavía no tienes solicitudes de reserva.',
                  [for (final r in solicitudes) _solicitud(context, s, r)]),
            ]),
          ),
        );
      },
    );
  }

  Widget _lista(bool vacia, String vacio, List<Widget> hijos) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: vacia
              ? Center(child: Text(vacio, textAlign: TextAlign.center))
              : ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: hijos),
        ),
      );

  Widget _lugar(BuildContext context, Store s, Lugar l) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 84, height: 84, child: FotoLugar(l.fotos.isEmpty ? '' : l.fotos.first)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${l.ciudad} · ${l.direccion}', style: const TextStyle(fontSize: 13)),
                  Text('${cop(l.precioNoche)} / noche', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Disponible ${fecha(l.desde)} - ${fecha(l.hasta)}', style: const TextStyle(fontSize: 12)),
                ]),
              ),
            ]),
            Row(children: [
              Switch(value: l.activo, onChanged: (_) => s.alternarActivo(l.id)),
              Text(l.activo ? 'Publicado' : 'Oculto'),
              const Spacer(),
              IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => PublicarScreen(editar: l)))),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                            title: const Text('Eliminar lugar'),
                            content: const Text('Se eliminará la publicación y sus reservas.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
                              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar')),
                            ],
                          ));
                  if (ok == true) s.eliminarLugar(l.id);
                },
              ),
            ]),
          ]),
        ),
      );

  Widget _solicitud(BuildContext context, Store s, Reserva r) {
    final l = s.lugar(r.lugarId);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(l?.titulo ?? 'Lugar', style: const TextStyle(fontWeight: FontWeight.bold))),
            Etiqueta(textoEstado(r.estado), colorEstado(r.estado)),
          ]),
          const SizedBox(height: 4),
          Text('${r.nombre} · Doc. ${r.documento} · Tel. ${r.telefono}'),
          Text('${fecha(r.desde)} → ${fecha(r.hasta)} · ${r.noches} noches · ${r.huespedes} huéspedes'),
          Text('Total ${cop(r.total)} · Anticipo ${cop(r.anticipo)}'),
          if (r.estado == 'pendiente')
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(spacing: 8, children: [
                OutlinedButton(
                    onPressed: () => s.cambiarEstado(r.id, 'rechazada'), child: const Text('Rechazar')),
                FilledButton(
                  onPressed: () {
                    final err = s.cambiarEstado(r.id, 'confirmada');
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                  child: const Text('Aceptar'),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}
