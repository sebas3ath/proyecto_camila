import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 1234567 -> "$ 1.234.567"
String cop(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '\$ $b';
}

String fecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

/// Muestra una foto del lugar: ilustración de la app ('asset:...') o imagen
/// subida por el anfitrión (base64). Llena el espacio que le dé el padre.
class FotoLugar extends StatelessWidget {
  final String foto;
  const FotoLugar(this.foto, {super.key});

  static final Map<String, Uint8List> _cache = {};

  Widget _vacio() => Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      );

  @override
  Widget build(BuildContext context) {
    if (foto.isEmpty) return _vacio();
    if (foto.startsWith('asset:')) {
      return Image.asset(foto.substring(6),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _vacio());
    }
    try {
      final bytes = _cache.putIfAbsent(foto, () => base64Decode(foto));
      return Image.memory(bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _vacio());
    } catch (_) {
      return _vacio();
    }
  }
}

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  const Etiqueta(this.texto, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
            color: color.withAlpha(35), borderRadius: BorderRadius.circular(99)),
        child: Text(texto,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      );
}

Color colorEstado(String e) {
  switch (e) {
    case 'confirmada':
      return Colors.green.shade700;
    case 'pendiente':
      return Colors.orange.shade800;
    default:
      return Colors.red.shade700;
  }
}

String textoEstado(String e) {
  switch (e) {
    case 'confirmada':
      return 'Confirmada';
    case 'pendiente':
      return 'Pendiente de confirmación';
    case 'rechazada':
      return 'Rechazada';
    default:
      return 'Cancelada';
  }
}

const _mesesCortos = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
String fechaCorta(DateTime d) => '${d.day} ${_mesesCortos[d.month - 1]}';
