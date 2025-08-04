class RegisterDto {
  final String email;
  final String password;
  final String matricula; // Matricula o RFC
  final String nombre;
  final String role;

  RegisterDto({
    required this.email,
    required this.password,
    required this.matricula,
    required this.nombre,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'Password': password,
      'Matricula': matricula,
      'Nombre': nombre,
      'role': role,
    };
  }
} 