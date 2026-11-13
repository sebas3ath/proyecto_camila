import 'package:flutter/material.dart';
import '../constants.dart';
import '../filtro.dart';
import '../models.dart';
import '../store.dart';
import '../tema.dart';
import '../utils.dart';
import '../widgets.dart';
import 'detalle_screen.dart';
import 'filtros_sheet.dart';

/// Resultados de búsqueda con filtros avanzados, orden y sugerencias de otras ciudades.
class ExplorarScreen extends StatefulWidget {
  final FiltroBusqueda? filtro;
  const ExplorarScreen({super.key, this.filtro});
  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final s = Store.instance;
  late FiltroBusqueda f;
  final Set<String> _favoritos = {};

  @override
  void initState() {
    super.initState();
    f = widget.filtro?.copia() ?? FiltroBusqueda();
  }

  Future<void> _abrirFiltros() async {
    final r = await mostrarFiltros(context, f);
    if (r != null) setState(() => f = r);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          final lista = s.buscar(f);
          final ids = lista.map((l) => l.id).toSet();
          final otros = f.ciudad == null
              ? <Lugar>[]
              : s.buscar(f.sinCiudad).where((l) => !ids.contains(l.id)).take(3).toList();
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(padding: const EdgeInsets.fromLTRB(14, 8, 14, 24), children: [
                    _barra(),
                    const SizedBox(height: 12),
                    FilaChips([
                      ChipOpcion(
                          texto: 'Todos', activo: f.tipos.isEmpty, onTap: () => setState(() => f.tipos.clear())),
                      for (final t in tiposLugar)
                        ChipOpcion(
                            texto: t,
                            activo: f.tipos.length == 1 && f.tipos.contains(t),
                            onTap: () => setState(() {
                                  f.tipos
                                    ..clear()
                                    ..add(t);
                                })),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                          child: Text(
                              lista.length == 1 ? '1 lugar encontrado' : '${lista.length} lugares encontrados',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                      PopupMenuButton<String>(
                        tooltip: 'Ordenar',
                        onSelected: (v) => setState(() => f.orden = v),
                        itemBuilder: (_) => [
                          for (final o in ordenes)
                            CheckedPopupMenuItem(value: o, checked: f.orden == o, child: Text(o)),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text('${f.orden} ▾',
                              style: const TextStyle(color: coral, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    if (lista.isEmpty) _vacio(),
                    for (final l in lista) _tarjeta(l),
                    if (otros.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Text('También te puede interesar en otras ciudades',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      for (final l in otros) _compacta(l),
                    ],
                  ]),
                ),
              ),
            ),
          );
        },
      );

  Widget _barra() => Row(children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            elevation: 3,
            shadowColor: const Color(0x33783C28),
            child: InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: _abrirFiltros,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(children: [
                  const Icon(Icons.place, color: coral, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      Text(f.resumen,
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: gris)),
                    ]),
                  ),
                  Badge(
                    isLabelVisible: f.activos > 0,
                    label: Text('${f.activos}'),
                    backgroundColor: menta,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: coral, shape: BoxShape.circle),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]);

  Widget _vacio() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          const Icon(Icons.search_off_rounded, size: 56, color: durazno),
          const SizedBox(height: 10),
          const Text('No encontramos lugares con esos filtros.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Prueba con otras fechas, menos filtros o una ciudad distinta.',
              textAlign: TextAlign.center, style: TextStyle(color: gris)),
          const SizedBox(height: 14),
          OutlinedButton(
              onPressed: () => setState(() => f.limpiar()), child: const Text('Limpiar filtros')),
        ]),
      );

  void _abrir(Lugar l) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleScreen(lugarId: l.id)));

  Widget _tarjeta(Lugar l) {
    final fav = _favoritos.contains(l.id);
    final etiquetas = <String>[
      '${l.capacidad} huésp.',
      '${l.habitaciones} hab.',
      '${l.banos} ${l.banos == 1 ? 'baño' : 'baños'}',
      ...l.comodidades.take(2),
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: sombraSuave),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrir(l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(fit: StackFit.expand, children: [
              FotoLugar(l.fotos.isEmpty ? '' : l.fotos.first),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: mentaClaro, borderRadius: BorderRadius.circular(99)),
                  child: Text(f.tieneFechas ? 'Disponible esas fechas' : 'Cancelación ${l.req.cancelacion.toLowerCase()}',
                      style: const TextStyle(color: mentaOscuro, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => fav ? _favoritos.remove(l.id) : _favoritos.add(l.id)),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(fav ? Icons.favorite : Icons.favorite_border, color: coral, size: 20),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                  child: Text('${cop(l.precioNoche)} / noche',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.place_outlined, size: 15, color: gris),
                const SizedBox(width: 4),
                Expanded(child: Text('${l.ciudad} · ${l.direccion}', style: const TextStyle(color: gris, fontSize: 12.5))),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final t in etiquetas)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: chipFondo, borderRadius: BorderRadius.circular(99)),
                    child: Text(t, style: const TextStyle(fontSize: 11.5)),
                  ),
              ]),
              if (f.tieneFechas) ...[
                const SizedBox(height: 10),
                Text('${f.noches} ${f.noches == 1 ? 'noche' : 'noches'}: ${cop(l.precioNoche * f.noches)} en total',
                    style: const TextStyle(color: coral, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _compacta(Lugar l) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: sombraSuave),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 60, height: 60, child: FotoLugar(l.fotos.isEmpty ? '' : l.fotos.first)),
          ),
          title: Text(l.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${l.ciudad} · ${cop(l.precioNoche)} / noche'),
          trailing: const Icon(Icons.chevron_right_rounded, color: coral),
          onTap: () => _abrir(l),
        ),
      );
}
