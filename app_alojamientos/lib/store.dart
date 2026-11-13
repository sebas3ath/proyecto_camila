import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'filtro.dart';
import 'models.dart';
import 'utils.dart';

/// Estado global de la demo. Todo se guarda en el dispositivo
/// (shared_preferences). En la app real se reemplaza por un backend.
class Store extends ChangeNotifier {
  Store._();
  static final Store instance = Store._();
  static const _k = 'staylink_v1';

  final List<Usuario> usuarios = [];
  final List<Lugar> lugares = [];
  final List<Reserva> reservas = [];
  String? sesionId;
  SharedPreferences? _prefs;
  int _n = 0;

  String nuevoId() => '${DateTime.now().microsecondsSinceEpoch}${_n++}';

  /// Carga los datos guardados. Nunca se queda esperando: si el almacenamiento
  /// del teléfono falla o tarda, la app sigue funcionando solo en memoria.
  Future<void> init() async {
    usuarios.clear();
    lugares.clear();
    reservas.clear();
    sesionId = null;
    try {
      _prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 6));
    } catch (_) {
      _prefs = null;
    }
    final raw = _prefs?.getString(_k);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        usuarios.addAll((m['usuarios'] as List).map((e) => Usuario.fromJson(e as Map<String, dynamic>)));
        lugares.addAll((m['lugares'] as List).map((e) => Lugar.fromJson(e as Map<String, dynamic>)));
        reservas.addAll((m['reservas'] as List).map((e) => Reserva.fromJson(e as Map<String, dynamic>)));
        sesionId = m['sesion'] as String?;
      } catch (_) {
        usuarios.clear();
        lugares.clear();
        reservas.clear();
        sesionId = null;
      }
    }
    if (usuarios.isEmpty) _sembrar();
  }

  /// Borra los datos guardados (para recuperar la app si quedó dañada).
  Future<void> borrarDatos() async {
    try {
      final p = _prefs ?? await SharedPreferences.getInstance().timeout(const Duration(seconds: 6));
      await p.remove(_k);
    } catch (_) {}
    usuarios.clear();
    lugares.clear();
    reservas.clear();
    sesionId = null;
  }

  void _guardar() {
    _prefs?.setString(
        _k,
        jsonEncode({
          'usuarios': usuarios.map((e) => e.toJson()).toList(),
          'lugares': lugares.map((e) => e.toJson()).toList(),
          'reservas': reservas.map((e) => e.toJson()).toList(),
          'sesion': sesionId,
        }));
  }

  void _cambio() {
    _guardar();
    notifyListeners();
  }

  // ---------- Datos de ejemplo ----------
  void _sembrar() {
    usuarios
      ..clear()
      ..addAll(const [
        Usuario(id: 'u1', nombre: 'Carlos Mejía', correo: 'anfitrion@demo.com', clave: '123456', telefono: '3001112233'),
        Usuario(
            id: 'u2',
            nombre: 'Marta Ruiz',
            correo: 'empresa@demo.com',
            clave: '123456',
            telefono: '3014445566',
            tipo: 'empresa',
            nit: '901.234.567-8',
            razonSocial: 'Hospedajes del Caribe S.A.S.'),
        Usuario(id: 'u3', nombre: 'Laura Gómez', correo: 'huesped@demo.com', clave: '123456', telefono: '3207778899'),
      ]);
    final hoy = soloFecha(DateTime.now());
    final hasta = hoy.add(const Duration(days: 365));
    String a(String n) => 'asset:assets/fotos/$n.jpg';
    Lugar l(String id, String host, String titulo, String tipo, String ciudad, String dir, String desc, int precio,
            int cap, int hab, int ban, int minN, int maxN, List<String> com, List<String> fotos, Requisitos req) =>
        Lugar(
            id: id,
            anfitrionId: host,
            titulo: titulo,
            tipo: tipo,
            ciudad: ciudad,
            direccion: dir,
            descripcion: desc,
            precioNoche: precio,
            capacidad: cap,
            habitaciones: hab,
            banos: ban,
            minNoches: minN,
            maxNoches: maxN,
            desde: hoy,
            hasta: hasta,
            comodidades: com,
            fotos: fotos,
            req: req);
    lugares
      ..clear()
      ..addAll([
        l('l1', 'u1', 'Apartamento moderno en El Prado', 'Apartamento', 'Barranquilla', 'Cra 54 # 68-120, El Prado',
            'Apartamento luminoso en un edificio con portería 24 horas, cerca de restaurantes, centros comerciales y transporte.',
            180000, 4, 2, 2, 2, 30, ['WiFi', 'Aire acondicionado', 'Cocina', 'Parqueadero', 'TV'],
            [a('edificio_1'), a('sala_1'), a('habitacion_1')],
            const Requisitos(
                documento: 'Cédula o pasaporte',
                anticipoPct: 30,
                deposito: 150000,
                cancelacion: 'Moderada',
                reglas: 'No fiestas. No fumar. Silencio después de las 10 p. m.',
                instrucciones: 'Portería: pregunta por el apartamento 704 y presenta tu documento. La llave está en la caja de seguridad, clave 4821.')),
        l('l2', 'u2', 'Casa con piscina en Puerto Colombia', 'Casa', 'Barranquilla', 'Cl 5 # 2-40, Puerto Colombia',
            'Casa amplia con piscina privada y zona de BBQ, ideal para familias o grupos. A pocos minutos de la playa.',
            420000, 8, 4, 3, 2, 14, ['WiFi', 'Piscina', 'Cocina', 'Parqueadero', 'Aire acondicionado', 'Mascotas permitidas'],
            [a('casa_1'), a('piscina_1'), a('sala_2')],
            const Requisitos(
                documento: 'Solo cédula',
                anticipoPct: 50,
                deposito: 300000,
                cancelacion: 'Estricta',
                reglas: 'Máximo 8 personas. Música hasta las 11 p. m.',
                instrucciones: 'Un administrador te recibe en la entrada. Te llamamos 1 hora antes de tu llegada.')),
        l('l3', 'u2', 'Habitación privada en el Centro Histórico', 'Habitación', 'Cartagena', 'Calle del Arsenal # 8B-31',
            'Habitación cómoda con baño privado en una casa colonial restaurada, a pasos de la ciudad amurallada.',
            120000, 2, 1, 1, 1, 10, ['WiFi', 'Aire acondicionado', 'Desayuno incluido'],
            [a('habitacion_2'), a('casa_2')],
            const Requisitos(
                documento: 'Cédula o pasaporte',
                anticipoPct: 20,
                deposito: 0,
                cancelacion: 'Flexible',
                reglas: 'Check-in con documento. No se permiten visitas.',
                instrucciones: 'Recepción en el primer piso. Pide tu llave con tu nombre.')),
        l('l4', 'u1', 'Cabaña en la sierra', 'Cabaña', 'Santa Marta', 'Vereda Minca, km 4',
            'Cabaña de madera rodeada de naturaleza, con vista a las montañas. Perfecta para descansar y desconectarte.',
            260000, 5, 2, 1, 2, 21, ['WiFi', 'Cocina', 'Parqueadero', 'Mascotas permitidas'],
            [a('cabana_1'), a('cabana_2')],
            const Requisitos(
                documento: 'Cédula o pasaporte',
                anticipoPct: 30,
                deposito: 100000,
                cancelacion: 'Moderada',
                reglas: 'No hacer fogatas fuera del área indicada.',
                instrucciones: 'Sigue la vía principal hasta el km 4. La llave está bajo la maceta azul de la entrada.')),
        l('l5', 'u1', 'Loft en Laureles', 'Loft', 'Medellín', 'Cra 76 # 39-15, Laureles',
            'Loft moderno y funcional, cerca de cafés, parques y la línea del metro. Ideal para viajes de trabajo.',
            210000, 3, 1, 1, 3, 60, ['WiFi', 'Aire acondicionado', 'Cocina', 'Lavadora', 'TV'],
            [a('edificio_2'), a('habitacion_1'), a('sala_1')],
            const Requisitos(
                documento: 'Solo pasaporte',
                anticipoPct: 100,
                deposito: 200000,
                cancelacion: 'Estricta',
                reglas: 'Estancia mínima de 3 noches.',
                instrucciones: 'Cerradura con código. Te lo enviamos el día de tu llegada.')),
        l('l6', 'u2', 'Apartaestudio cerca al aeropuerto', 'Apartamento', 'Barranquilla', 'Cl 30 # 15-60, Soledad',
            'Apartaestudio práctico y económico, a 10 minutos del aeropuerto. Perfecto para escalas y viajes cortos.',
            95000, 2, 1, 1, 1, 15, ['WiFi', 'Aire acondicionado', 'TV'],
            [a('sala_2'), a('edificio_1')],
            const Requisitos(
                documento: 'Cédula o pasaporte',
                anticipoPct: 0,
                deposito: 0,
                cancelacion: 'Flexible',
                reglas: 'No fumar.',
                instrucciones: 'Portería 24 horas. Entrega de llave con documento.')),
      ]);
    reservas
      ..clear()
      ..addAll([
        Reserva(
            id: 'r1',
            lugarId: 'l1',
            huespedId: 'u3',
            nombre: 'Laura Gómez',
            documento: '1.045.678.901',
            telefono: '3207778899',
            desde: hoy.add(const Duration(days: 10)),
            hasta: hoy.add(const Duration(days: 13)),
            creada: DateTime.now(),
            huespedes: 2,
            total: 540000,
            anticipo: 162000,
            estado: 'confirmada'),
        Reserva(
            id: 'r2',
            lugarId: 'l4',
            huespedId: 'u3',
            nombre: 'Laura Gómez',
            documento: '1.045.678.901',
            telefono: '3207778899',
            desde: hoy.add(const Duration(days: 20)),
            hasta: hoy.add(const Duration(days: 23)),
            creada: DateTime.now(),
            huespedes: 3,
            total: 780000,
            anticipo: 234000,
            estado: 'pendiente'),
      ]);
    sesionId = null;
    _guardar();
  }

  void reiniciarDemo() {
    _sembrar();
    notifyListeners();
  }

  // ---------- Cuenta ----------
  Usuario? get usuario {
    for (final u in usuarios) {
      if (u.id == sesionId) return u;
    }
    return null;
  }

  Usuario? usuarioPorId(String id) {
    for (final u in usuarios) {
      if (u.id == id) return u;
    }
    return null;
  }

  /// Devuelve un mensaje de error o null si todo salió bien.
  String? registrar({
    required String nombre,
    required String correo,
    required String clave,
    required String telefono,
    required String tipo,
    String nit = '',
    String razon = '',
  }) {
    final c = correo.trim().toLowerCase();
    if (nombre.trim().isEmpty || c.isEmpty || telefono.trim().isEmpty) return 'Completa todos los campos.';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(c)) return 'Escribe un correo válido.';
    if (clave.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
    if (tipo == 'empresa' && (nit.trim().isEmpty || razon.trim().isEmpty)) {
      return 'Para una empresa escribe la razón social y el NIT.';
    }
    if (usuarios.any((u) => u.correo == c)) return 'Ese correo ya está registrado. Inicia sesión.';
    final u = Usuario(
        id: nuevoId(),
        nombre: nombre.trim(),
        correo: c,
        clave: clave,
        telefono: telefono.trim(),
        tipo: tipo,
        nit: nit.trim(),
        razonSocial: razon.trim());
    usuarios.add(u);
    sesionId = u.id;
    _cambio();
    return null;
  }

  String? ingresar(String correo, String clave) {
    final c = correo.trim().toLowerCase();
    for (final u in usuarios) {
      if (u.correo == c && u.clave == clave) {
        sesionId = u.id;
        _cambio();
        return null;
      }
    }
    return 'Correo o contraseña incorrectos.';
  }

  void salir() {
    sesionId = null;
    _cambio();
  }

  // ---------- Búsqueda ----------
  Lugar? lugar(String id) {
    for (final l in lugares) {
      if (l.id == id) return l;
    }
    return null;
  }

  bool _vigente(Lugar l, DateTime hoy) => l.activo && !l.hasta.isBefore(hoy);

  /// Búsqueda con todos los filtros. Si hay fechas, también revisa que el lugar
  /// esté disponible esas noches y que cumpla la estadía mínima y máxima.
  List<Lugar> buscar(FiltroBusqueda f) {
    final t = f.texto.trim().toLowerCase();
    final hoy = soloFecha(DateTime.now());
    final r = lugares.where((l) {
      if (!_vigente(l, hoy)) return false;
      if (f.ciudad != null && l.ciudad != f.ciudad) return false;
      if (f.tipos.isNotEmpty && !f.tipos.contains(l.tipo)) return false;
      if (f.precioMin > FiltroBusqueda.precioBase && l.precioNoche < f.precioMin) return false;
      if (f.precioMax < FiltroBusqueda.precioTope && l.precioNoche > f.precioMax) return false;
      if (l.capacidad < f.huespedes) return false;
      if (l.habitaciones < f.habMin) return false;
      if (l.banos < f.banosMin) return false;
      for (final c in f.comodidades) {
        if (!l.comodidades.contains(c)) return false;
      }
      if (f.cancelacion != null && l.req.cancelacion != f.cancelacion) return false;
      if (f.tieneFechas) {
        final n = f.noches;
        if (n < l.minNoches || n > l.maxNoches) return false;
        if (f.desde!.isBefore(l.desde) || f.hasta!.isAfter(l.hasta)) return false;
        if (!disponible(l.id, f.desde!, f.hasta!)) return false;
      }
      if (t.isNotEmpty && !'${l.titulo} ${l.ciudad} ${l.direccion}'.toLowerCase().contains(t)) return false;
      return true;
    }).toList();
    switch (f.orden) {
      case 'Menor precio':
        r.sort((a, b) => a.precioNoche.compareTo(b.precioNoche));
        break;
      case 'Mayor precio':
        r.sort((a, b) => b.precioNoche.compareTo(a.precioNoche));
        break;
      case 'Más capacidad':
        r.sort((a, b) => b.capacidad.compareTo(a.capacidad));
        break;
    }
    return r;
  }

  /// Ciudades con lugares publicados y cuántos hay en cada una (la que más tiene, primero).
  List<MapEntry<String, int>> ciudadesConLugares() {
    final hoy = soloFecha(DateTime.now());
    final m = <String, int>{};
    for (final l in lugares) {
      if (_vigente(l, hoy)) m[l.ciudad] = (m[l.ciudad] ?? 0) + 1;
    }
    final lista = m.entries.toList();
    lista.sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
    return lista;
  }

  String fotoCiudad(String ciudad) {
    for (final l in lugares) {
      if (l.ciudad == ciudad && l.activo && l.fotos.isNotEmpty) return l.fotos.first;
    }
    return '';
  }

  String departamentoDe(String ciudad) => departamentos[ciudad] ?? '';

  // ---------- Anfitrión ----------
  List<Lugar> get misLugares => lugares.where((l) => l.anfitrionId == sesionId).toList();

  void guardarLugar(Lugar l) {
    if (sesionId == null || l.anfitrionId != sesionId) return;
    final i = lugares.indexWhere((x) => x.id == l.id);
    if (i >= 0) {
      lugares[i] = l;
    } else {
      lugares.add(l);
    }
    _cambio();
  }

  void alternarActivo(String id) {
    final i = lugares.indexWhere((x) => x.id == id && x.anfitrionId == sesionId);
    if (i < 0) return;
    lugares[i] = lugares[i].copiar(activo: !lugares[i].activo);
    _cambio();
  }

  void eliminarLugar(String id) {
    lugares.removeWhere((x) => x.id == id && x.anfitrionId == sesionId);
    reservas.removeWhere((r) => r.lugarId == id);
    _cambio();
  }

  /// Solicitudes de reserva de los lugares del anfitrión conectado.
  List<Reserva> get solicitudes {
    final ids = misLugares.map((l) => l.id).toSet();
    final l = reservas.where((r) => ids.contains(r.lugarId)).toList();
    l.sort((a, b) => b.creada.compareTo(a.creada));
    return l;
  }

  int get pendientes => solicitudes.where((r) => r.estado == 'pendiente').length;

  // ---------- Reservas ----------
  List<Reserva> get misReservas {
    final l = reservas.where((r) => r.huespedId == sesionId).toList();
    l.sort((a, b) => b.creada.compareTo(a.creada));
    return l;
  }

  /// La noche de salida (hasta) no cuenta como ocupada.
  bool disponible(String lugarId, DateTime desde, DateTime hasta, {String? excepto}) {
    for (final r in reservas) {
      if (r.lugarId == lugarId &&
          r.id != excepto &&
          r.estado == 'confirmada' &&
          desde.isBefore(r.hasta) &&
          hasta.isAfter(r.desde)) {
        return false;
      }
    }
    return true;
  }

  String? reservar({
    required Lugar lugar,
    required DateTime desde,
    required DateTime hasta,
    required int huespedes,
    required String nombre,
    required String documento,
    required String telefono,
  }) {
    final u = usuario;
    if (u == null) return 'Inicia sesión para reservar.';
    final noches = hasta.difference(desde).inDays;
    if (noches < lugar.minNoches || noches > lugar.maxNoches) {
      return 'La estancia debe ser de ${lugar.minNoches} a ${lugar.maxNoches} noches.';
    }
    if (huespedes < 1 || huespedes > lugar.capacidad) return 'Este lugar admite hasta ${lugar.capacidad} huéspedes.';
    if (desde.isBefore(lugar.desde) || hasta.isAfter(lugar.hasta)) return 'Esas fechas están fuera del periodo disponible.';
    if (!disponible(lugar.id, desde, hasta)) return 'Esas fechas ya no están disponibles.';
    final total = noches * lugar.precioNoche;
    reservas.add(Reserva(
        id: nuevoId(),
        lugarId: lugar.id,
        huespedId: u.id,
        nombre: nombre.trim(),
        documento: documento.trim(),
        telefono: telefono.trim(),
        desde: desde,
        hasta: hasta,
        creada: DateTime.now(),
        huespedes: huespedes,
        total: total,
        anticipo: (total * lugar.req.anticipoPct / 100).round()));
    _cambio();
    return null;
  }

  Reserva? _reserva(String id) {
    for (final r in reservas) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// El anfitrión acepta o rechaza; el huésped puede cancelar.
  String? cambiarEstado(String id, String estado) {
    final r = _reserva(id);
    final l = r == null ? null : lugar(r.lugarId);
    if (r == null || l == null) return 'No se encontró la reserva.';
    final esAnfitrion = l.anfitrionId == sesionId;
    final esHuesped = r.huespedId == sesionId;
    if (estado == 'cancelada' && !esHuesped && !esAnfitrion) return 'No tienes permiso.';
    if ((estado == 'confirmada' || estado == 'rechazada') && !esAnfitrion) return 'Solo el anfitrión puede hacerlo.';
    if (estado == 'confirmada' && !disponible(r.lugarId, r.desde, r.hasta, excepto: r.id)) {
      return 'Esas fechas ya están confirmadas para otra reserva.';
    }
    r.estado = estado;
    _cambio();
    return null;
  }
}
