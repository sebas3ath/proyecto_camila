import 'utils.dart';

/// Todos los criterios de búsqueda en un solo objeto.
class FiltroBusqueda {
  static const int precioBase = 50000;
  static const int precioTope = 500000;

  String texto;
  String? ciudad; // null = todas
  DateTime? desde;
  DateTime? hasta;
  int huespedes;
  Set<String> tipos;
  int precioMin;
  int precioMax;
  int habMin; // 0 = cualquiera
  int banosMin; // 0 = cualquiera
  Set<String> comodidades;
  String? cancelacion; // null = cualquiera
  String orden;

  FiltroBusqueda({
    this.texto = '',
    this.ciudad,
    this.desde,
    this.hasta,
    this.huespedes = 1,
    Set<String>? tipos,
    this.precioMin = precioBase,
    this.precioMax = precioTope,
    this.habMin = 0,
    this.banosMin = 0,
    Set<String>? comodidades,
    this.cancelacion,
    this.orden = 'Relevancia',
  })  : tipos = tipos ?? <String>{},
        comodidades = comodidades ?? <String>{};

  FiltroBusqueda copia() => FiltroBusqueda(
        texto: texto,
        ciudad: ciudad,
        desde: desde,
        hasta: hasta,
        huespedes: huespedes,
        tipos: Set<String>.from(tipos),
        precioMin: precioMin,
        precioMax: precioMax,
        habMin: habMin,
        banosMin: banosMin,
        comodidades: Set<String>.from(comodidades),
        cancelacion: cancelacion,
        orden: orden,
      );

  bool get tieneFechas => desde != null && hasta != null;
  int get noches => tieneFechas ? hasta!.difference(desde!).inDays : 0;
  bool get precioActivo => precioMin > precioBase || precioMax < precioTope;

  /// Cuántos filtros están activos (se muestra en la insignia del botón).
  int get activos {
    var n = 0;
    if (ciudad != null) n++;
    if (tieneFechas) n++;
    if (huespedes > 1) n++;
    if (tipos.isNotEmpty) n++;
    if (precioActivo) n++;
    if (habMin > 0) n++;
    if (banosMin > 0) n++;
    if (comodidades.isNotEmpty) n++;
    if (cancelacion != null) n++;
    return n;
  }

  String get textoFechas =>
      tieneFechas ? '${fechaCorta(desde!)} – ${fechaCorta(hasta!)}' : 'Cualquier fecha';

  String get textoHuespedes => huespedes == 1 ? '1 huésped' : '$huespedes huéspedes';

  String get titulo {
    if (ciudad != null) return ciudad!;
    if (texto.trim().isNotEmpty) return texto.trim();
    return 'Todas las ciudades';
  }

  String get resumen => '$textoFechas · $textoHuespedes';

  /// Mismo filtro pero sin limitar la ciudad (para sugerir otras opciones).
  FiltroBusqueda get sinCiudad {
    final c = copia();
    c.ciudad = null;
    return c;
  }

  void limpiar() {
    texto = '';
    ciudad = null;
    desde = null;
    hasta = null;
    huespedes = 1;
    tipos.clear();
    precioMin = precioBase;
    precioMax = precioTope;
    habMin = 0;
    banosMin = 0;
    comodidades.clear();
    cancelacion = null;
    orden = 'Relevancia';
  }
}
