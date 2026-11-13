import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';

class MisReservasScreen extends StatelessWidget {
  const MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Store.instance;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final lista = s.misReservas;
        return Scaffold(
          appBar: AppBar(title: const Text('Mis reservas')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: lista.isEmpty
                  ? const Center(child: Text('Aún no tienes reservas.'))
                  : ListView(padding: const EdgeInsets.all(16), children: [for (final r in lista) _tarjeta(context, s, r)]),
            ),
          ),
        );
      },
    );
  }

  Widget _tarjeta(BuildContext context, Store s, Reserva r) {
    final l = s.lugar(r.lugarId);
    if (l == null) return const SizedBox();
    final activa = r.estado == 'pendiente' || r.estado == 'confirmada';
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 120, child: FotoLugar(l.fotos.isEmpty ? '' : l.fotos.first)),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(l.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Etiqueta(textoEstado(r.estado), colorEstado(r.estado)),
            ]),
            const SizedBox(height: 4),
            Text('${l.direccion}, ${l.ciudad}'),
            Text('${fecha(r.desde)} → ${fecha(r.hasta)} · ${r.noches} noches · ${r.huespedes} huéspedes'),
            Text('Total ${cop(r.total)} · Anticipo ${cop(r.anticipo)}'),
            if (r.estado == 'confirmada') ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Instrucciones de acceso', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Check-in desde las ${l.req.checkIn} · Check-out hasta las ${l.req.checkOut}'),
                  const SizedBox(height: 4),
                  Text(l.req.instrucciones.isEmpty ? 'El anfitrión te contactará con los detalles.' : l.req.instrucciones),
                ]),
              ),
            ],
            if (r.estado == 'pendiente')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Las instrucciones de acceso aparecerán cuando el anfitrión confirme.',
                    style: TextStyle(fontSize: 12)),
              ),
            if (activa)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                              title: const Text('Cancelar reserva'),
                              content: Text(
                                  'Política ${l.req.cancelacion.toLowerCase()}. ¿Quieres cancelar esta reserva?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
                                FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sí, cancelar')),
                              ],
                            ));
                    if (ok == true) s.cambiarEstado(r.id, 'cancelada');
                  },
                  child: const Text('Cancelar reserva'),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}
