class User {
  final String id;
  final String email;
  final String userName; // Viene como UniqueName en el token
  final String nombre;
  final String matriculaRfc;
  // Podrías añadir roles si los decodificas o los obtienes de otra forma

  User({
    required this.id,
    required this.email,
    required this.userName,
    required this.nombre,
    required this.matriculaRfc,
  });

  factory User.fromClaims(Map<String, dynamic> claims) {
    return User(
      id: claims['nameid'] ?? '', // ClaimTypes.NameIdentifier
      email: claims['email'] ?? '', // JwtRegisteredClaimNames.Email
      userName: claims['unique_name'] ?? '', // JwtRegisteredClaimNames.UniqueName
      nombre: claims['nombre'] ?? '',
      matriculaRfc: claims['matricula'] ?? '',
    );
  }

  // Opcional: un método para convertir a Map si necesitas guardarlo o enviarlo
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'userName': userName,
      'nombre': nombre,
      'matriculaRfc': matriculaRfc,
    };
  }
} 