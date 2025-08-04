class DatosInscripcion {
  final int? inscripcionId;
  final int? idHorario; // Este parece ser el IdGrupoHorario de la inscripción actual
  final String? fechaDeInscripcion; // Formato YYYY-MM-DD
  final bool? aprobado;
  final int? idHorarioDetalle; // IdHorarioDetalle específico de la inscripción actual

  DatosInscripcion({
    this.inscripcionId,
    this.idHorario,
    this.fechaDeInscripcion,
    this.aprobado,
    this.idHorarioDetalle,
  });

  factory DatosInscripcion.fromJson(Map<String, dynamic> json) {
    return DatosInscripcion(
      inscripcionId: json['inscripcionId'] as int?,
      idHorario: json['idHorario'] as int?,
      fechaDeInscripcion: json['fechaDeInscripcion'] as String?,
      aprobado: json['aprobado'] as bool?,
      idHorarioDetalle: json['idHorarioDetalle'] as int?,
    );
  }
} 