import 'package:mobile/models/activity_view_model.dart';
import 'package:mobile/models/datos_inscripcion.dart';
import 'package:mobile/models/grupo_horario_vista.dart';

class ActivityWithDetails {
  // Campos base de la actividad (similares a ActivityViewModel)
  final int idActividad;
  final String nombreActividad;
  final String? nombreCategoria;
  final String? nombreEncargado;
  final String? instalacion;
  final String? estado;
  final int creditos;
  final String? fechaInicio; // Formato YYYY-MM-DD
  final String? fechaFinal;  // Formato YYYY-MM-DD
  final String? datosExtra;
  final String? descripcion;
  final String? imagenUrl; // Corresponde a 'imagen' en el JSON de detalle

  // Datos específicos de la inscripción del usuario (si existe)
  final DatosInscripcion? datosInscripcion; // Mapea el objeto 'datos'

  // Lista de grupos y horarios disponibles para la actividad
  final List<GrupoHorarioVista> gruposHorarioVista;

  // Campo adicional para saber si el usuario está inscrito (derivado de datosInscripcion o de ActivityViewModel original)
  // Este podría ser redundante si ActivityViewModel ya lo tiene y se pasa, o si se deriva de datosInscripcion.
  // Por ahora, lo mantenemos para la pantalla de detalles.
  final bool estaInscritoGeneral; // Indica si el usuario está inscrito en CUALQUIER horario de esta actividad

  ActivityWithDetails({
    required this.idActividad,
    required this.nombreActividad,
    this.nombreCategoria,
    this.nombreEncargado,
    this.instalacion,
    this.estado,
    required this.creditos,
    this.fechaInicio,
    this.fechaFinal,
    this.datosExtra,
    this.descripcion,
    this.imagenUrl,
    this.datosInscripcion,
    required this.gruposHorarioVista,
    this.estaInscritoGeneral = false, // Por defecto no inscrito, se actualizará al parsear
  });

  factory ActivityWithDetails.fromJson(Map<String, dynamic> json) {
    var gruposList = json['gruposHorarioVista'] as List? ?? [];
    List<GrupoHorarioVista> gruposVista = gruposList
        .map((i) => GrupoHorarioVista.fromJson(i as Map<String, dynamic>))
        .toList();

    DatosInscripcion? datosInscripcionActual;
    if (json['datos'] != null && json['datos'] is Map<String, dynamic>) {
      // Verificar que 'datos' no sea una lista vacía o un objeto malformado
      // Un objeto vacío {} resultaría en un error si no se maneja con cuidado.
      // Tu ejemplo tiene datos: null o datos: {objeto}. Si es null, no se parsea.
      if ((json['datos'] as Map<String, dynamic>).isNotEmpty) {
          datosInscripcionActual = DatosInscripcion.fromJson(json['datos'] as Map<String, dynamic>);
      }      
    }

    return ActivityWithDetails(
      idActividad: json['idActividad'] as int? ?? 0,
      nombreActividad: json['nombreActividad'] as String? ?? 'Nombre no disponible',
      nombreCategoria: json['nombreCategoria'] as String?,
      nombreEncargado: json['nombreEncargado'] as String?,
      instalacion: json['instalacion'] as String?,
      estado: json['estado'] as String?,
      creditos: json['creditos'] as int? ?? 0,
      fechaInicio: json['fechaInicio'] as String?,
      fechaFinal: json['fechaFinal'] as String?,
      datosExtra: json['datosExtra'] as String?,
      descripcion: json['descripcion'] as String?,
      imagenUrl: json['imagen'] as String?, // 'imagen' en el JSON de detalle
      datosInscripcion: datosInscripcionActual,
      gruposHorarioVista: gruposVista,
      estaInscritoGeneral: datosInscripcionActual != null && datosInscripcionActual.inscripcionId != null,
    );
  }

  // Helper para convertir a ActivityViewModel si es necesario (ej. para reutilizar widgets)
  ActivityViewModel toActivityViewModel() {
    return ActivityViewModel(
      id: idActividad,
      nombre: nombreActividad,
      descripcion: descripcion,
      encargado: nombreEncargado,
      categoria: nombreCategoria,
      estado: estado,
      creditos: creditos,
      estaInscrito: estaInscritoGeneral, // Usar el estado general de inscripción
      urlImg: imagenUrl,
    );
  }
} 