const tiposLugar = ['Apartamento', 'Casa', 'Habitación', 'Cabaña', 'Loft'];
const comodidadesLista = [
  'WiFi',
  'Aire acondicionado',
  'Cocina',
  'Parqueadero',
  'Piscina',
  'TV',
  'Lavadora',
  'Mascotas permitidas',
  'Desayuno incluido',
];
const documentos = ['Cédula o pasaporte', 'Solo cédula', 'Solo pasaporte'];
const cancelaciones = ['Flexible', 'Moderada', 'Estricta'];
const horasCheckIn = ['12:00', '13:00', '14:00', '15:00', '16:00', '18:00'];
const horasCheckOut = ['10:00', '11:00', '12:00', '13:00'];
const anticipos = ['0', '20', '30', '50', '100'];

const Map<String, String> textoCancelacion = {
  'Flexible': 'Cancelación gratis hasta 24 horas antes de la llegada.',
  'Moderada': 'Cancelación gratis hasta 5 días antes de la llegada.',
  'Estricta': 'El anticipo no es reembolsable.',
};

const ordenes = ['Relevancia', 'Menor precio', 'Mayor precio', 'Más capacidad'];

const Map<String, String> departamentos = {
  'Barranquilla': 'Atlántico',
  'Cartagena': 'Bolívar',
  'Santa Marta': 'Magdalena',
  'Medellín': 'Antioquia',
  'Bogotá': 'Cundinamarca',
  'Cali': 'Valle del Cauca',
};
