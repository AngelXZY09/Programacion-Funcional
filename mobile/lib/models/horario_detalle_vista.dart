class HorarioDetalleVista {
  final int id;
  final int grupoHorarioId;
  final String? horaInicio; // Formato HH:mm
  final String? horaFin;   // Formato HH:mm
  final String? fecha;     // Formato YYYY-MM-DD, puede ser null
  final String? diaSemanaNombre; // Ej. "Lunes", puede ser null

  HorarioDetalleVista({
    required this.id,
    required this.grupoHorarioId,
    this.horaInicio,
    this.horaFin,
    this.fecha,
    this.diaSemanaNombre,
  });

  factory HorarioDetalleVista.fromJson(Map<String, dynamic> json) {
    return HorarioDetalleVista(
      id: json['id'] as int? ?? 0,
      grupoHorarioId: json['grupoHorarioId'] as int? ?? 0,
      horaInicio: json['horaInicio'] as String?,
      horaFin: json['horaFin'] as String?,
      fecha: json['fecha'] as String?,
      diaSemanaNombre: json['diaSemanaNombre'] as String?,
    );
  }

  // Método para obtener una descripción legible del horario
  String get descripcion {
    if (fecha != null && horaInicio != null && horaFin != null) {
      return '$fecha de $horaInicio a $horaFin';
    }
    if (diaSemanaNombre != null && horaInicio != null && horaFin != null) {
      return '$diaSemanaNombre de $horaInicio a $horaFin';
    }
    return 'Horario no especificado';
  }
} 