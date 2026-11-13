import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';
import 'mis_reservas_screen.dart';

/// Registro del huésped para acceder al lugar: fechas, datos y resumen.
class ReservarScreen extends StatefulWidget {
  final String lugarId;
  const ReservarScreen({super.key, required this.lugarId});
  @override
  State<ReservarScreen> createState() => _ReservarScreenState();
}

class _ReservarScreenState extends State<ReservarScreen> {
  final s = Store.instance;
  DateTimeRange? _rango;
  int _huespedes = 1;
  late final TextEditingController _nombre, _doc, _tel;
  bool _acepto = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    final u = s.usuario;
    _nombre = TextEditingController(text: u?.nombre ?? '');
    _tel = TextEditingController(text: u?.telefono ?? '');
    _doc = TextEditingController();
  }

  Future<void> _elegirFechas(Lugar l) async {
    final hoy = soloFecha(DateTime.now());
    final primer = hoy.isAfter(l.desde) ? hoy : l.desde;
    if (!l.hasta.isAfter(primer)) {
      setState(() => _err = 'Este lugar ya no tiene fechas disponibles.');
      return;
    }
    final r = await showDateRangePicker(
      context: context,
      firstDate: primer,
      lastDate: l.hasta,
      initialDateRange: _rango,
      helpText: 'Elige llegada y salida',
      saveText: 'Listo',
    );
    if (r != null) setState(() {
      _rango = r;
      _err = null;
    });
  }

  Future<void> _enviar(Lugar l) async {
    final r = _rango;
    if (r == null) return;
    if (_nombre.text.trim().isEmpty || _doc.text.trim().isEmpty || _tel.text.trim().isEmpty) {
      setState(() => _err = 'Completa tu nombre, documento y teléfono.');
      return;
    }
    final err = s.reservar(
        lugar: l,
        desde: r.start,
        hasta: r.end,
        huespedes: _huespedes,
        nombre: _nombre.text,
        documento: _doc.text,
        telefono: _tel.text);
    if (err != null) {
      setState(() => _err = err);
      return;
    }
    await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('Solicitud enviada'),
              content: const Text('El anfitrión revisará tu solicitud. Cuando la confirme verás las instrucciones de acceso en "Mis reservas".'),
              actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Ver mis reservas'))],
            ));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MisReservasScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l = s.lugar(widget.lugarId);
    if (l == null) return const Scaffold();
    final noches = _rango?.duration.inDays ?? 0;
    final total = noches * l.precioNoche;
    final anticipo = (total * l.req.anticipoPct / 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text(l.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${l.direccion}, ${l.ciudad}'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _elegirFechas(l),
              icon: const Icon(Icons.calendar_month),
              label: Text(_rango == null
                  ? 'Elegir fechas de llegada y salida'
                  : '${fecha(_rango!.start)} → ${fecha(_rango!.end)} ($noches noches)'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Expanded(child: Text('Huéspedes')),
              IconButton(
                  tooltip: 'Menos',
                  onPressed: _huespedes > 1 ? () => setState(() => _huespedes--) : null,
                  icon: const Icon(Icons.remove_circle_outline)),
              Text('$_huespedes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                  tooltip: 'Más',
                  onPressed: _huespedes < l.capacidad ? () => setState(() => _huespedes++) : null,
                  icon: const Icon(Icons.add_circle_outline)),
            ]),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Tus datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _nombre, decoration: const InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 12),
            TextField(
                controller: _doc,
                decoration: InputDecoration(labelText: 'Documento (${l.req.documento.toLowerCase()})')),
            const SizedBox(height: 12),
            TextField(
                controller: _tel, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono')),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Resumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _fila('${cop(l.precioNoche)} x $noches noches', cop(total)),
                  _fila('Anticipo a pagar (${l.req.anticipoPct}%)', cop(anticipo)),
                  if (l.req.deposito > 0) _fila('Depósito de garantía (reembolsable)', cop(l.req.deposito)),
                  const Divider(),
                  _fila('Total de la estadía', cop(total), fuerte: true),
                  const SizedBox(height: 6),
                  const Text('El pago es simulado en este demo.', style: TextStyle(fontSize: 12)),
                ]),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _acepto,
              onChanged: (v) => setState(() => _acepto = v ?? false),
              title: Text(
                  'Acepto las reglas del lugar y la cancelación ${l.req.cancelacion.toLowerCase()}.',
                  style: const TextStyle(fontSize: 13)),
            ),
            if (_err != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_err!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            FilledButton(
              onPressed: (_rango != null && _acepto) ? () => _enviar(l) : null,
              child: const Text('Enviar solicitud de reserva'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _fila(String a, String b, {bool fuerte = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(a, style: TextStyle(fontWeight: fuerte ? FontWeight.bold : null))),
          const SizedBox(width: 8),
          Text(b, style: TextStyle(fontWeight: fuerte ? FontWeight.bold : null)),
        ]),
      );
}
