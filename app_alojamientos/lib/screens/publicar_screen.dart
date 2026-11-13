import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models.dart';
import '../store.dart';
import '../utils.dart';

/// Formulario para publicar (o editar) un lugar con toda la información.
class PublicarScreen extends StatefulWidget {
  final Lugar? editar;
  const PublicarScreen({super.key, this.editar});
  @override
  State<PublicarScreen> createState() => _PublicarScreenState();
}

class _PublicarScreenState extends State<PublicarScreen> {
  final s = Store.instance;
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titulo, _ciudad, _direccion, _desc, _precio, _cap, _hab, _ban, _minN, _maxN, _deposito, _reglas, _instr;
  late String _tipo, _documento, _cancel, _checkIn, _checkOut, _anticipo;
  late DateTime _desde, _hasta;
  late Set<String> _comodidades;
  late List<String> _fotos;

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    final hoy = soloFecha(DateTime.now());
    _titulo = TextEditingController(text: e?.titulo ?? '');
    _ciudad = TextEditingController(text: e?.ciudad ?? '');
    _direccion = TextEditingController(text: e?.direccion ?? '');
    _desc = TextEditingController(text: e?.descripcion ?? '');
    _precio = TextEditingController(text: e?.precioNoche.toString() ?? '');
    _cap = TextEditingController(text: (e?.capacidad ?? 2).toString());
    _hab = TextEditingController(text: (e?.habitaciones ?? 1).toString());
    _ban = TextEditingController(text: (e?.banos ?? 1).toString());
    _minN = TextEditingController(text: (e?.minNoches ?? 1).toString());
    _maxN = TextEditingController(text: (e?.maxNoches ?? 30).toString());
    _deposito = TextEditingController(text: (e?.req.deposito ?? 0).toString());
    _reglas = TextEditingController(text: e?.req.reglas ?? '');
    _instr = TextEditingController(text: e?.req.instrucciones ?? '');
    _tipo = e?.tipo ?? tiposLugar.first;
    _documento = e?.req.documento ?? documentos.first;
    _cancel = e?.req.cancelacion ?? 'Moderada';
    _checkIn = e?.req.checkIn ?? '15:00';
    _checkOut = e?.req.checkOut ?? '11:00';
    _anticipo = (e?.req.anticipoPct ?? 30).toString();
    _desde = e?.desde ?? hoy;
    _hasta = e?.hasta ?? hoy.add(const Duration(days: 90));
    _comodidades = {...?e?.comodidades};
    _fotos = [...?e?.fotos];
  }

  Future<void> _agregarFotos() async {
    try {
      final imgs = await ImagePicker().pickMultiImage(maxWidth: 1280, imageQuality: 75);
      for (final x in imgs) {
        if (_fotos.length >= 6) break;
        _fotos.add(base64Encode(await x.readAsBytes()));
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No se pudo abrir la galería. Revisa los permisos.')));
      }
    }
  }

  Future<void> _fecha(bool inicio) async {
    final hoy = soloFecha(DateTime.now());
    final r = await showDatePicker(
      context: context,
      initialDate: inicio ? _desde : _hasta,
      firstDate: inicio ? hoy.subtract(const Duration(days: 365)) : _desde,
      lastDate: hoy.add(const Duration(days: 365 * 3)),
    );
    if (r == null) return;
    setState(() {
      if (inicio) {
        _desde = r;
        if (_hasta.isBefore(_desde)) _hasta = _desde.add(const Duration(days: 30));
      } else {
        _hasta = r;
      }
    });
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _publicar() {
    if (!_form.currentState!.validate()) {
      _msg('Revisa los campos marcados.');
      return;
    }
    if (_fotos.isEmpty) {
      _msg('Agrega al menos una foto del lugar.');
      return;
    }
    final minN = int.parse(_minN.text.trim()), maxN = int.parse(_maxN.text.trim());
    if (minN > maxN) {
      _msg('El mínimo de noches no puede superar al máximo.');
      return;
    }
    if (!_hasta.isAfter(_desde)) {
      _msg('La fecha final debe ser posterior a la inicial.');
      return;
    }
    final e = widget.editar;
    s.guardarLugar(Lugar(
      id: e?.id ?? s.nuevoId(),
      anfitrionId: e?.anfitrionId ?? s.sesionId ?? '',
      titulo: _titulo.text.trim(),
      tipo: _tipo,
      ciudad: _ciudad.text.trim(),
      direccion: _direccion.text.trim(),
      descripcion: _desc.text.trim(),
      precioNoche: int.parse(_precio.text.trim()),
      capacidad: int.parse(_cap.text.trim()),
      habitaciones: int.parse(_hab.text.trim()),
      banos: int.parse(_ban.text.trim()),
      minNoches: minN,
      maxNoches: maxN,
      desde: _desde,
      hasta: _hasta,
      comodidades: comodidadesLista.where(_comodidades.contains).toList(),
      fotos: _fotos,
      activo: e?.activo ?? true,
      req: Requisitos(
        documento: _documento,
        checkIn: _checkIn,
        checkOut: _checkOut,
        cancelacion: _cancel,
        reglas: _reglas.text.trim(),
        instrucciones: _instr.text.trim(),
        anticipoPct: int.parse(_anticipo),
        deposito: int.tryParse(_deposito.text.trim()) ?? 0,
      ),
    ));
    Navigator.pop(context);
  }

  // ---------- Piezas de formulario ----------
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;
  String? _num(String? v) => (int.tryParse((v ?? '').trim()) == null || int.parse(v!.trim()) < 1) ? 'Número válido' : null;

  Widget _campo(TextEditingController c, String label,
          {String? Function(String?)? validar, TextInputType? tipo, int lineas = 1, String? ayuda}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: tipo,
          minLines: lineas,
          maxLines: lineas,
          validator: validar,
          decoration: InputDecoration(labelText: label, helperText: ayuda),
        ),
      );

  Widget _lista(String label, String valor, List<String> ops, void Function(String) cambio) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: valor,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: ops.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => setState(() => cambio(v ?? valor)),
        ),
      );

  Widget _seccion(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.editar == null ? 'Publicar lugar' : 'Editar lugar')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                _seccion('Fotos'),
                SizedBox(
                  height: 96,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    for (var i = 0; i < _fotos.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(width: 120, height: 96, child: FotoLugar(_fotos[i]))),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton.filled(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Quitar foto',
                              onPressed: () => setState(() => _fotos.removeAt(i)),
                              icon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ]),
                      ),
                    if (_fotos.length < 6)
                      OutlinedButton.icon(
                        onPressed: _agregarFotos,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Agregar'),
                      ),
                  ]),
                ),
                const SizedBox(height: 4),
                Text('${_fotos.length}/6 fotos (mínimo 1)', style: const TextStyle(fontSize: 12)),
                _seccion('Información del lugar'),
                _campo(_titulo, 'Título', validar: _req),
                _lista('Tipo de lugar', _tipo, tiposLugar, (v) => _tipo = v),
                _campo(_ciudad, 'Ciudad', validar: _req),
                _campo(_direccion, 'Dirección', validar: _req),
                _campo(_desc, 'Descripción', validar: _req, lineas: 4),
                _campo(_precio, 'Precio por noche (COP)', validar: _num, tipo: TextInputType.number),
                Row(children: [
                  Expanded(child: _campo(_cap, 'Huéspedes', validar: _num, tipo: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _campo(_hab, 'Habitaciones', validar: _num, tipo: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _campo(_ban, 'Baños', validar: _num, tipo: TextInputType.number)),
                ]),
                _seccion('Comodidades'),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  for (final c in comodidadesLista)
                    FilterChip(
                      label: Text(c),
                      selected: _comodidades.contains(c),
                      onSelected: (v) => setState(() => v ? _comodidades.add(c) : _comodidades.remove(c)),
                    ),
                ]),
                _seccion('Periodo disponible'),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(onPressed: () => _fecha(true), child: Text('Desde ${fecha(_desde)}'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: OutlinedButton(onPressed: () => _fecha(false), child: Text('Hasta ${fecha(_hasta)}'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _campo(_minN, 'Mínimo de noches', validar: _num, tipo: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _campo(_maxN, 'Máximo de noches', validar: _num, tipo: TextInputType.number)),
                ]),
                _seccion('Requisitos para acceder'),
                _lista('Documento que debe presentar el huésped', _documento, documentos, (v) => _documento = v),
                _lista('Anticipo al reservar (%)', _anticipo, anticipos, (v) => _anticipo = v),
                _campo(_deposito, 'Depósito de garantía (COP, opcional)', tipo: TextInputType.number),
                Row(children: [
                  Expanded(child: _lista('Check-in', _checkIn, horasCheckIn, (v) => _checkIn = v)),
                  const SizedBox(width: 8),
                  Expanded(child: _lista('Check-out', _checkOut, horasCheckOut, (v) => _checkOut = v)),
                ]),
                _lista('Política de cancelación', _cancel, cancelaciones, (v) => _cancel = v),
                _campo(_reglas, 'Reglas del lugar (opcional)', lineas: 3),
                _campo(_instr, 'Instrucciones de acceso', lineas: 3,
                    ayuda: 'Solo las ve el huésped cuando confirmas su reserva.'),
                const SizedBox(height: 8),
                FilledButton(
                    onPressed: _publicar, child: Text(widget.editar == null ? 'Publicar lugar' : 'Guardar cambios')),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      );
}
