class UpdateEnrollmentDto {
  final int idActividad;
  final int idGrupoHorario;
  final int idHorarioDetalle;
  final bool? aprobado; // El estado de aprobación puede ser null si no se envía o es opcional

  UpdateEnrollmentDto({
    required this.idActividad,
    required this.idGrupoHorario,
    required this.idHorarioDetalle,
    this.aprobado,
  });

  Map<String, dynamic> toJson() {
    return {
      'IdActividad': idActividad,
      'IdGrupoHorario': idGrupoHorario,
      'IdHorarioDetalle': idHorarioDetalle,
      if (aprobado != null) 'Aprobado': aprobado, // Incluir solo si no es null
    };
  }
} 