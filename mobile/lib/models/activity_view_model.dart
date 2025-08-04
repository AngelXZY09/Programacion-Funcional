class ActivityViewModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? encargado;
  final String? categoria;
  final String? estado;
  final int creditos;
  final bool estaInscrito;
  final String? urlImg;

  ActivityViewModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.encargado,
    this.categoria,
    this.estado,
    required this.creditos,
    required this.estaInscrito,
    this.urlImg,
  });

  factory ActivityViewModel.fromJson(Map<String, dynamic> json) {
    return ActivityViewModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? 'Nombre no disponible',
      descripcion: json['descripcion'] as String?,
      encargado: json['encargado'] as String?,
      categoria: json['categoria'] as String?,
      estado: json['estado'] as String?,
      creditos: json['creditos'] as int? ?? 0,
      estaInscrito: json['estaInscrito'] as bool? ?? false,
      urlImg: json['urlImg'] as String?,
    );
  }

  // Opcional: toJson si necesitas enviar este objeto a la API en algún momento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'encargado': encargado,
      'categoria': categoria,
      'estado': estado,
      'creditos': creditos,
      'estaInscrito': estaInscrito,
      'urlImg': urlImg,
    };
  }
} 