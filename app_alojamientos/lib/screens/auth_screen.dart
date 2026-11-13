import 'package:flutter/material.dart';
import '../store.dart';

/// Inicio de sesión y registro. Al terminar con éxito cierra con `true`.
class AuthScreen extends StatelessWidget {
  final String mensaje;
  const AuthScreen({super.key, this.mensaje = 'Inicia sesión para continuar'});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Tu cuenta'),
            bottom: const TabBar(tabs: [Tab(text: 'Ingresar'), Tab(text: 'Crear cuenta')]),
          ),
          body: TabBarView(children: [_Ingreso(mensaje), const _Registro()]),
        ),
      );
}

Widget _centrado(List<Widget> hijos) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(padding: const EdgeInsets.all(20), children: hijos),
      ),
    );

class _Ingreso extends StatefulWidget {
  final String mensaje;
  const _Ingreso(this.mensaje);
  @override
  State<_Ingreso> createState() => _IngresoState();
}

class _IngresoState extends State<_Ingreso> {
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  String? _err;
  bool _ver = false;

  void _entrar() {
    final err = Store.instance.ingresar(_correo.text, _clave.text);
    if (err != null) {
      setState(() => _err = err);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => _centrado([
        Text(widget.mensaje, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        TextField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo')),
        const SizedBox(height: 12),
        TextField(
          controller: _clave,
          obscureText: !_ver,
          onSubmitted: (_) => _entrar(),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            errorText: _err,
            suffixIcon: IconButton(
                tooltip: _ver ? 'Ocultar contraseña' : 'Mostrar contraseña',
                icon: Icon(_ver ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _ver = !_ver)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _entrar, child: const Text('Ingresar')),
        const SizedBox(height: 20),
        const Text('Cuentas de prueba (contraseña 123456):\n'
            '• huesped@demo.com\n• anfitrion@demo.com\n• empresa@demo.com',
            style: TextStyle(fontSize: 12)),
      ]);
}

class _Registro extends StatefulWidget {
  const _Registro();
  @override
  State<_Registro> createState() => _RegistroState();
}

class _RegistroState extends State<_Registro> {
  final _nombre = TextEditingController(),
      _correo = TextEditingController(),
      _tel = TextEditingController(),
      _clave = TextEditingController(),
      _razon = TextEditingController(),
      _nit = TextEditingController();
  String _tipo = 'persona';
  String? _err;

  void _crear() {
    final err = Store.instance.registrar(
        nombre: _nombre.text,
        correo: _correo.text,
        clave: _clave.text,
        telefono: _tel.text,
        tipo: _tipo,
        nit: _nit.text,
        razon: _razon.text);
    if (err != null) {
      setState(() => _err = err);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => _centrado([
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'persona', label: Text('Persona'), icon: Icon(Icons.person)),
            ButtonSegment(value: 'empresa', label: Text('Empresa'), icon: Icon(Icons.business)),
          ],
          selected: {_tipo},
          onSelectionChanged: (s) => setState(() => _tipo = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
            controller: _nombre,
            decoration: InputDecoration(labelText: _tipo == 'empresa' ? 'Nombre del representante' : 'Nombre completo')),
        if (_tipo == 'empresa') ...[
          const SizedBox(height: 12),
          TextField(controller: _razon, decoration: const InputDecoration(labelText: 'Razón social')),
          const SizedBox(height: 12),
          TextField(controller: _nit, decoration: const InputDecoration(labelText: 'NIT')),
        ],
        const SizedBox(height: 12),
        TextField(
            controller: _correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo electrónico')),
        const SizedBox(height: 12),
        TextField(
            controller: _tel, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono')),
        const SizedBox(height: 12),
        TextField(
            controller: _clave,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña (mínimo 6 caracteres)')),
        if (_err != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_err!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _crear, child: const Text('Crear cuenta')),
      ]);
}
