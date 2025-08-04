class InscripcionRequestDto {
  final int idActividad;
  final int idGrupoHorario;
  final int idHorarioDetalle;

  InscripcionRequestDto({
    required this.idActividad,
    required this.idGrupoHorario,
    required this.idHorarioDetalle,
  });

  Map<String, dynamic> toJson() {
    return {
      'IdActividad': idActividad,
      'IdGrupoHorario': idGrupoHorario,
      'IdHorarioDetalle': idHorarioDetalle,
    };
  }
} 