class Usuario {
  final String id, nombre, correo, clave, telefono;
  final String tipo; // 'persona' | 'empresa'
  final String nit, razonSocial;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.clave,
    required this.telefono,
    this.tipo = 'persona',
    this.nit = '',
    this.razonSocial = '',
  });

  bool get esEmpresa => tipo == 'empresa';
  String get nombreVisible => esEmpresa && razonSocial.isNotEmpty ? razonSocial : nombre;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        'clave': clave,
        'telefono': telefono,
        'tipo': tipo,
        'nit': nit,
        'razon': razonSocial,
      };

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'],
        nombre: j['nombre'],
        correo: j['correo'],
        clave: j['clave'],
        telefono: j['telefono'] ?? '',
        tipo: j['tipo'] ?? 'persona',
        nit: j['nit'] ?? '',
        razonSocial: j['razon'] ?? '',
      );
}

/// Condiciones que define el anfitrión para poder acceder al lugar.
class Requisitos {
  final String documento, checkIn, checkOut, cancelacion, reglas, instrucciones;
  final int anticipoPct, deposito;

  const Requisitos({
    this.documento = 'Cédula o pasaporte',
    this.checkIn = '15:00',
    this.checkOut = '11:00',
    this.cancelacion = 'Moderada',
    this.reglas = '',
    this.instrucciones = '',
    this.anticipoPct = 30,
    this.deposito = 0,
  });

  Map<String, dynamic> toJson() => {
        'documento': documento,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'cancelacion': cancelacion,
        'reglas': reglas,
        'instrucciones': instrucciones,
        'anticipoPct': anticipoPct,
        'deposito': deposito,
      };

  factory Requisitos.fromJson(Map<String, dynamic> j) => Requisitos(
        documento: j['documento'] ?? 'Cédula o pasaporte',
        checkIn: j['checkIn'] ?? '15:00',
        checkOut: j['checkOut'] ?? '11:00',
        cancelacion: j['cancelacion'] ?? 'Moderada',
        reglas: j['reglas'] ?? '',
        instrucciones: j['instrucciones'] ?? '',
        anticipoPct: j['anticipoPct'] ?? 30,
        deposito: j['deposito'] ?? 0,
      );
}

class Lugar {
  final String id, anfitrionId;
  final String titulo, tipo, ciudad, direccion, descripcion;
  final int precioNoche, capacidad, habitaciones, banos, minNoches, maxNoches;
  final DateTime desde, hasta; // periodo en el que el lugar está disponible
  final List<String> comodidades;
  final List<String> fotos; // 'asset:ruta' o imagen en base64
  final Requisitos req;
  final bool activo;

  const Lugar({
    required this.id,
    required this.anfitrionId,
    required this.titulo,
    required this.tipo,
    required this.ciudad,
    required this.direccion,
    required this.descripcion,
    required this.precioNoche,
    required this.capacidad,
    required this.habitaciones,
    required this.banos,
    required this.minNoches,
    required this.maxNoches,
    required this.desde,
    required this.hasta,
    required this.comodidades,
    required this.fotos,
    required this.req,
    this.activo = true,
  });

  Lugar copiar({bool? activo}) => Lugar(
        id: id,
        anfitrionId: anfitrionId,
        titulo: titulo,
        tipo: tipo,
        ciudad: ciudad,
        direccion: direccion,
        descripcion: descripcion,
        precioNoche: precioNoche,
        capacidad: capacidad,
        habitaciones: habitaciones,
        banos: banos,
        minNoches: minNoches,
        maxNoches: maxNoches,
        desde: desde,
        hasta: hasta,
        comodidades: comodidades,
        fotos: fotos,
        req: req,
        activo: activo ?? this.activo,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'anfitrionId': anfitrionId,
        'titulo': titulo,
        'tipo': tipo,
        'ciudad': ciudad,
        'direccion': direccion,
        'descripcion': descripcion,
        'precio': precioNoche,
        'capacidad': capacidad,
        'habitaciones': habitaciones,
        'banos': banos,
        'minNoches': minNoches,
        'maxNoches': maxNoches,
        'desde': desde.toIso8601String(),
        'hasta': hasta.toIso8601String(),
        'comodidades': comodidades,
        'fotos': fotos,
        'req': req.toJson(),
        'activo': activo,
      };

  factory Lugar.fromJson(Map<String, dynamic> j) => Lugar(
        id: j['id'],
        anfitrionId: j['anfitrionId'],
        titulo: j['titulo'],
        tipo: j['tipo'],
        ciudad: j['ciudad'],
        direccion: j['direccion'],
        descripcion: j['descripcion'],
        precioNoche: j['precio'],
        capacidad: j['capacidad'],
        habitaciones: j['habitaciones'],
        banos: j['banos'],
        minNoches: j['minNoches'],
        maxNoches: j['maxNoches'],
        desde: DateTime.parse(j['desde']),
        hasta: DateTime.parse(j['hasta']),
        comodidades: List<String>.from(j['comodidades'] as List),
        fotos: List<String>.from(j['fotos'] as List),
        req: Requisitos.fromJson(j['req'] as Map<String, dynamic>),
        activo: j['activo'] != false,
      );
}

/// estado: 'pendiente' | 'confirmada' | 'rechazada' | 'cancelada'
class Reserva {
  final String id, lugarId, huespedId, nombre, documento, telefono;
  final DateTime desde, hasta, creada;
  final int huespedes, total, anticipo;
  String estado;

  Reserva({
    required this.id,
    required this.lugarId,
    required this.huespedId,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.desde,
    required this.hasta,
    required this.creada,
    required this.huespedes,
    required this.total,
    required this.anticipo,
    this.estado = 'pendiente',
  });

  int get noches => hasta.difference(desde).inDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lugarId': lugarId,
        'huespedId': huespedId,
        'nombre': nombre,
        'documento': documento,
        'telefono': telefono,
        'desde': desde.toIso8601String(),
        'hasta': hasta.toIso8601String(),
        'creada': creada.toIso8601String(),
        'huespedes': huespedes,
        'total': total,
        'anticipo': anticipo,
        'estado': estado,
      };

  factory Reserva.fromJson(Map<String, dynamic> j) => Reserva(
        id: j['id'],
        lugarId: j['lugarId'],
        huespedId: j['huespedId'],
        nombre: j['nombre'],
        documento: j['documento'],
        telefono: j['telefono'],
        desde: DateTime.parse(j['desde']),
        hasta: DateTime.parse(j['hasta']),
        creada: DateTime.parse(j['creada']),
        huespedes: j['huespedes'],
        total: j['total'],
        anticipo: j['anticipo'],
        estado: j['estado'],
      );
}
