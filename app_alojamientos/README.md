# STAYLINK (demo) · alojamientos por temporada

Busca, reserva y publica lugares. Datos locales (sin servidor). Esta versión trae el **rediseño**:
colores coral/durazno con acentos menta y lavanda sobre fondo crema, y un **filtro de búsqueda avanzado**.

## Cómo usar este zip con tu proyecto actual
Copia estos elementos encima de tu proyecto (carpeta que contiene `pubspec.yaml`), **sin tocar tu `android/` ni `ios/`**:

```powershell
# desde la carpeta de este zip ya extraído, hacia tu proyecto:
Copy-Item lib, assets, pubspec.yaml, analysis_options.yaml -Destination C:\ruta\a\tu\proyecto -Recurse -Force
cd C:\ruta\a\tu\proyecto
flutter pub get
flutter run
```
Si tu proyecto no tiene `android/` completa (errores `mipmap/ic_launcher` o `LaunchTheme not found`),
ejecuta `.\preparar.ps1`: borra y regenera `android/` e `ios/` con tu versión de Flutter y verifica `res/`.

## Qué cambió
- `lib/tema.dart` (nuevo): paleta y tema Material 3 de toda la app.
- `lib/filtro.dart` (nuevo): objeto con todos los criterios de búsqueda.
- `lib/widgets.dart` (nuevo): chips, campos, contador y botón degradado reutilizables.
- `lib/screens/home_screen.dart`: inicio con buscador (ciudad, fechas, huéspedes), ciudades populares y barra inferior.
- `lib/screens/explorar_screen.dart`: resultados con tarjetas nuevas, chips de tipo, orden y favoritos (en memoria).
- `lib/screens/filtros_sheet.dart` (nuevo): hoja de filtros avanzados.
- `lib/screens/ciudad_screen.dart` (nuevo): selector de ciudad con número de lugares.
- `lib/store.dart`: `buscar(FiltroBusqueda)`, `ciudadesConLugares()`, `fotoCiudad()`.
- `lib/main.dart`: usa el nuevo tema (solo claro). Los demás archivos no cambiaron; heredan el tema.

## Filtros disponibles
Nombre/barrio, ciudad, fechas (solo muestra lugares libres esas noches y que acepten esa cantidad
de noches), huéspedes (capacidad), tipo de lugar (varios), rango de precio, habitaciones, baños,
comodidades (deben tenerlas todas), cancelación y orden (relevancia, menor/mayor precio, más capacidad).
El botón muestra en vivo cuántos lugares hay. Si hay pocos resultados, abajo aparecen opciones de otras ciudades.

## Cuentas de prueba (contraseña 123456)
anfitrion@demo.com · empresa@demo.com · huesped@demo.com

## Diferencias con la imagen de la propuesta
- No incluye "Usar mi ubicación" (necesita un paquete y permisos de GPS).
- La barra inferior (Explorar, Reservas, Publicar, Perfil) está solo en el inicio; Reservas, Publicar y Perfil abren sus pantallas.
- Los filtros usan los datos que ya existen; no hay calificaciones ni reseñas.

## Pendiente
Comparar con Booking/Airbnb: ninguna ofrece API pública abierta (solo para socios aprobados).
