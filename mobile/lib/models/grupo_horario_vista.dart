import 'package:mobile/models/horario_detalle_vista.dart';
import 'package:mobile/models/tipo_de_horario.dart';
import '../utils_funcional.dart';

// Modelo para los objetos dentro de la lista diasConHoras
class DiaConHoras {
  final String diaSemana;
  final List<String> horas; // Lista de strings como "07:00 a 09:00"

  DiaConHoras({required this.diaSemana, required this.horas});

  factory DiaConHoras.fromJson(Map<String, dynamic> json) {
    return DiaConHoras(
      diaSemana: json['diaSemana'] as String? ?? '',
      horas: List<String>.from(json['horas'] as List? ?? []),
    );
  }
}

class GrupoHorarioVista {
  final int grupoHorarioId;
  final TipoDeHorario tipoDeHorario;
  final int? cupoMaximo;
  final String? fechaUnica; // Puede ser null
  // fechasConHoras no está en el ejemplo proporcionado, pero se mantiene por si acaso
  final List<dynamic>? fechasConHoras; // Tipo exacto desconocido, puede ser List<Map<String, String>>
  final List<DiaConHoras> diasConHoras;
  final List<String> horasResumen; // Lista de strings como "07:00 a 09:00"
  final String? textoAgrupado; // Ej. "Todos los Lunes, Miércoles y Viernes"
  final List<HorarioDetalleVista> detalles;

  GrupoHorarioVista({
    required this.grupoHorarioId,
    required this.tipoDeHorario,
    this.cupoMaximo,
    this.fechaUnica,
    this.fechasConHoras,
    required this.diasConHoras,
    required this.horasResumen,
    this.textoAgrupado,
    required this.detalles,
  });

  factory GrupoHorarioVista.fromJson(Map<String, dynamic> json) {
    var detallesList = json['detalles'] as List? ?? [];
    List<HorarioDetalleVista> detallesVista = detallesList
        .map((i) => HorarioDetalleVista.fromJson(i as Map<String, dynamic>))
        .toList();
    
    var diasConHorasListJson = json['diasConHoras'] as List? ?? [];
    List<DiaConHoras> diasConHorasList = diasConHorasListJson
        .map((i) => DiaConHoras.fromJson(i as Map<String, dynamic>))
        .toList();

    return GrupoHorarioVista(
      grupoHorarioId: json['grupoHorarioId'] as int? ?? 0,
      tipoDeHorario: TipoDeHorario.fromString(json['tipoDeHorario'] as String?),
      cupoMaximo: json['cupoMaximo'] as int?,
      fechaUnica: json['fechaUnica'] as String?,
      fechasConHoras: json['fechasConHoras'] as List<dynamic>?,
      diasConHoras: diasConHorasList,
      horasResumen: List<String>.from(json['horasResumen'] as List? ?? []),
      textoAgrupado: json['textoAgrupado'] as String?,
      detalles: detallesVista,
    );
  }

  // # descripcionAmigable ha sido convertido a función libre funcional (ver utils_funcional.dart)
  String get descripcionAmigable => descripcionAmigableFunc(textoAgrupado, tipoDeHorario.displayName);
} 