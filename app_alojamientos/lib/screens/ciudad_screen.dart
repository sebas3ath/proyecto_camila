import 'package:flutter/material.dart';
import '../store.dart';
import '../tema.dart';
import '../utils.dart';

/// Elige la ciudad. Devuelve el nombre elegido, o '' para "Todas las ciudades".
class CiudadScreen extends StatefulWidget {
  final String? actual;
  const CiudadScreen({super.key, this.actual});
  @override
  State<CiudadScreen> createState() => _CiudadScreenState();
}

class _CiudadScreenState extends State<CiudadScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Store.instance;
    final q = _q.text.trim().toLowerCase();
    final lista = s.ciudadesConLugares().where((e) => q.isEmpty || e.key.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('¿A dónde vas?')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            TextField(
              controller: _q,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  hintText: 'Buscar ciudad',
                  prefixIcon: Icon(Icons.place_outlined, color: coral),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(99)))),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                backgroundColor: const Color(0xFFFFE1D6),
                label: const Text('Todas las ciudades',
                    style: TextStyle(color: coral, fontWeight: FontWeight.w700)),
                onPressed: () => Navigator.pop(context, ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Text('Destinos con lugares disponibles',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            if (lista.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No hay lugares publicados en esa ciudad todavía.'))),
            for (final e in lista) _fila(s, e.key, e.value),
          ]),
        ),
      ),
    );
  }

  Widget _fila(Store s, String ciudad, int n) {
    final sel = widget.actual == ciudad;
    final dep = s.departamentoDe(ciudad);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sel ? coral : Colors.transparent, width: 1.6),
        boxShadow: sombraSuave,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(width: 56, height: 56, child: FotoLugar(s.fotoCiudad(ciudad))),
        ),
        title: Text(ciudad, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        subtitle: Text(dep.isEmpty ? 'Colombia' : '$dep · Colombia'),
        trailing: Etiqueta(n == 1 ? '1 lugar' : '$n lugares', sel ? coral : mentaOscuro),
        onTap: () => Navigator.pop(context, ciudad),
      ),
    );
  }
}
