import 'package:flutter/material.dart';
import 'tema.dart';

/// Chip redondo de selección (coral cuando está activo).
class ChipOpcion extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;
  const ChipOpcion({super.key, required this.texto, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: activo ? coral : chipFondo,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(texto,
                style: TextStyle(
                    color: activo ? Colors.white : tinta,
                    fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13)),
          ),
        ),
      );
}

/// Fila de chips con desplazamiento horizontal.
class FilaChips extends StatelessWidget {
  final List<Widget> chips;
  const FilaChips(this.chips, {super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final c in chips) Padding(padding: const EdgeInsets.only(right: 8), child: c),
        ]),
      );
}

/// Casilla tocable con ícono, etiqueta pequeña y valor (ciudad, fechas, huéspedes).
class CampoBusqueda extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final bool vacio;
  final VoidCallback onTap;
  const CampoBusqueda({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.onTap,
    this.vacio = false,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: campoFondo,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(children: [
              Icon(icono, color: coral, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(etiqueta.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: gris, letterSpacing: 0.4)),
                  const SizedBox(height: 1),
                  Text(valor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: vacio ? gris : tinta)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

/// Botón − número + (huéspedes).
class StepperCantidad extends StatelessWidget {
  final int valor;
  final int minimo;
  final int maximo;
  final ValueChanged<int> onChanged;
  const StepperCantidad(
      {super.key, required this.valor, required this.onChanged, this.minimo = 1, this.maximo = 20});

  @override
  Widget build(BuildContext context) {
    Widget boton(IconData i, bool activo, VoidCallback f, bool relleno) => InkWell(
          customBorder: const CircleBorder(),
          onTap: activo ? f : null,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !activo ? chipFondo.withAlpha(120) : (relleno ? coral : chipFondo)),
            child: Icon(i, size: 20, color: relleno && activo ? Colors.white : coral),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      boton(Icons.remove, valor > minimo, () => onChanged(valor - 1), false),
      SizedBox(
          width: 40,
          child: Text('$valor',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      boton(Icons.add, valor < maximo, () => onChanged(valor + 1), true),
    ]);
  }
}

class TituloSeccion extends StatelessWidget {
  final String texto;
  final String? derecha;
  const TituloSeccion(this.texto, {super.key, this.derecha});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Row(children: [
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: tinta))),
          if (derecha != null)
            Text(derecha!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: coral)),
        ]),
      );
}

/// Botón principal con degradé coral.
class BotonDegradado extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback onPressed;
  const BotonDegradado({super.key, required this.texto, required this.onPressed, this.icono});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [coral, coralClaro]),
            borderRadius: BorderRadius.circular(99),
            boxShadow: [BoxShadow(color: coral.withAlpha(70), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: onPressed,
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (icono != null) ...[Icon(icono, color: Colors.white, size: 20), const SizedBox(width: 8)],
                Text(texto,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      );
}
