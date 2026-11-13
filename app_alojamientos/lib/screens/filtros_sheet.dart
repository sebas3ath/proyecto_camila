import 'package:flutter/material.dart';
import '../constants.dart';
import '../filtro.dart';
import '../store.dart';
import '../tema.dart';
import '../utils.dart';
import '../widgets.dart';

/// Abre la hoja de filtros. Devuelve el filtro nuevo, o null si se cerró sin aplicar.
Future<FiltroBusqueda?> mostrarFiltros(BuildContext context, FiltroBusqueda actual) {
  return showModalBottomSheet<FiltroBusqueda>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => FiltrosSheet(inicial: actual),
  );
}

/// Pide un rango de fechas. Devuelve null si se cancela.
Future<DateTimeRange?> elegirFechas(BuildContext context, FiltroBusqueda f) async {
  final hoy = soloFecha(DateTime.now());
  final r = await showDateRangePicker(
    context: context,
    firstDate: hoy,
    lastDate: hoy.add(const Duration(days: 365)),
    initialDateRange: f.tieneFechas ? DateTimeRange(start: f.desde!, end: f.hasta!) : null,
    helpText: 'Elige llegada y salida',
    saveText: 'Listo',
  );
  if (r == null) return null;
  if (r.end.difference(r.start).inDays < 1) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Elige al menos 1 noche.')));
    }
    return null;
  }
  return r;
}

class FiltrosSheet extends StatefulWidget {
  final FiltroBusqueda inicial;
  const FiltrosSheet({super.key, required this.inicial});
  @override
  State<FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<FiltrosSheet> {
  late FiltroBusqueda f;
  late final TextEditingController _texto;
  final s = Store.instance;

  @override
  void initState() {
    super.initState();
    f = widget.inicial.copia();
    _texto = TextEditingController(text: f.texto);
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _fechas() async {
    final r = await elegirFechas(context, f);
    if (r != null) setState(() {
      f.desde = r.start;
      f.hasta = r.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = s.buscar(f).length;
    final ciudades = s.ciudadesConLugares();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: Column(children: [
        const SizedBox(height: 10),
        Container(
            width: 44, height: 5, decoration: BoxDecoration(color: linea, borderRadius: BorderRadius.circular(3))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(children: [
            const Expanded(child: Text('Filtros', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
            TextButton(
              onPressed: () => setState(() {
                f.limpiar();
                _texto.clear();
              }),
              child: const Text('Limpiar todo', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), children: [
            const TituloSeccion('Nombre o barrio'),
            TextField(
              controller: _texto,
              onChanged: (v) => setState(() => f.texto = v),
              decoration: const InputDecoration(
                  hintText: 'Ej: Laureles, El Prado, piscina...', prefixIcon: Icon(Icons.search, color: coral)),
            ),
            const TituloSeccion('Ciudad'),
            FilaChips([
              ChipOpcion(texto: 'Todas', activo: f.ciudad == null, onTap: () => setState(() => f.ciudad = null)),
              for (final e in ciudades)
                ChipOpcion(
                    texto: e.key, activo: f.ciudad == e.key, onTap: () => setState(() => f.ciudad = e.key)),
            ]),
            const TituloSeccion('Fechas'),
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
            if (f.tieneFechas)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: () => setState(() {
                          f.desde = null;
                          f.hasta = null;
                        }),
                    child: Text('${f.noches} ${f.noches == 1 ? 'noche' : 'noches'} · Quitar fechas')),
              ),
            const TituloSeccion('Huéspedes'),
            Row(children: [
              const Expanded(child: Text('Personas que viajan')),
              StepperCantidad(valor: f.huespedes, onChanged: (v) => setState(() => f.huespedes = v)),
            ]),
            const TituloSeccion('Tipo de lugar'),
            FilaChips([
              for (final t in tiposLugar)
                ChipOpcion(
                    texto: t,
                    activo: f.tipos.contains(t),
                    onTap: () => setState(() => f.tipos.contains(t) ? f.tipos.remove(t) : f.tipos.add(t))),
            ]),
            TituloSeccion('Precio por noche',
                derecha: f.precioActivo ? '${cop(f.precioMin)} – ${f.precioMax >= FiltroBusqueda.precioTope ? 'sin límite' : cop(f.precioMax)}' : 'Cualquiera'),
            RangeSlider(
              values: RangeValues(f.precioMin.toDouble(), f.precioMax.toDouble()),
              min: FiltroBusqueda.precioBase.toDouble(),
              max: FiltroBusqueda.precioTope.toDouble(),
              divisions: 9,
              activeColor: coral,
              inactiveColor: chipFondo,
              labels: RangeLabels(cop(f.precioMin), cop(f.precioMax)),
              onChanged: (v) => setState(() {
                f.precioMin = v.start.round();
                f.precioMax = v.end.round();
              }),
            ),
            const TituloSeccion('Habitaciones'),
            FilaChips([
              for (final h in [0, 1, 2, 3, 4])
                ChipOpcion(
                    texto: h == 0 ? 'Todas' : '$h+', activo: f.habMin == h, onTap: () => setState(() => f.habMin = h)),
            ]),
            const TituloSeccion('Baños'),
            FilaChips([
              for (final b in [0, 1, 2, 3])
                ChipOpcion(
                    texto: b == 0 ? 'Todos' : '$b+', activo: f.banosMin == b, onTap: () => setState(() => f.banosMin = b)),
            ]),
            const TituloSeccion('Comodidades'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final c in comodidadesLista)
                ChipOpcion(
                    texto: c,
                    activo: f.comodidades.contains(c),
                    onTap: () => setState(() => f.comodidades.contains(c) ? f.comodidades.remove(c) : f.comodidades.add(c))),
            ]),
            const TituloSeccion('Cancelación'),
            FilaChips([
              ChipOpcion(texto: 'Cualquiera', activo: f.cancelacion == null, onTap: () => setState(() => f.cancelacion = null)),
              for (final c in cancelaciones)
                ChipOpcion(texto: c, activo: f.cancelacion == c, onTap: () => setState(() => f.cancelacion = c)),
            ]),
            const TituloSeccion('Ordenar por'),
            FilaChips([
              for (final o in ordenes)
                ChipOpcion(texto: o, activo: f.orden == o, onTap: () => setState(() => f.orden = o)),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: linea))),
          child: BotonDegradado(
            texto: n == 0 ? 'Sin resultados con estos filtros' : (n == 1 ? 'Mostrar 1 lugar' : 'Mostrar $n lugares'),
            onPressed: () => Navigator.pop(context, f),
          ),
        ),
      ]),
    );
  }
}
