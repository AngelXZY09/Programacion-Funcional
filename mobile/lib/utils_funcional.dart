// utils_funcional.dart

import 'dart:convert';
import 'package:fpdart/fpdart.dart';

// # toggleExcludeEnrolledOrFinished convertido a función libre funcional
bool toggleExcludeEnrolledOrFinishedFunc(bool current) => !current;

// # descripcionAmigable convertido a función libre funcional
String descripcionAmigableFunc(String? textoAgrupado, String? displayName) {
  return textoAgrupado ?? displayName ?? 'Horario no especificado';
}

// # Lógica funcional pura para procesar la respuesta del login usando TaskEither
// Devuelve Left(error) en caso de fallo, o Right(token) en caso de éxito.
// Esta versión utiliza una composición de funciones (pipeline) para evitar if/else.
TaskEither<String, String> processLoginResponseFunc(int statusCode, String responseBody) {
  return TaskEither<String, String>.fromPredicate(
    responseBody,
    (_) => statusCode == 200,
    (body) {
      try {
        final errorData = json.decode(body);
        if (errorData is Map) {
          return errorData['message'] ?? errorData['title'] ?? 'Error de servidor';
        }
        return 'Error de servidor con respuesta inesperada';
      } catch (e) {
        return body.isNotEmpty ? body : 'Error de comunicación con el servidor';
      }
    },
  ).flatMap((body) {
    // El resultado de este flatMap debe ser un Mapa, no un String.
    return TaskEither<String, Map<String, dynamic>>.tryCatch(
      () async => json.decode(body) as Map<String, dynamic>,
      (e, stackTrace) => 'Formato de respuesta inválido',
    );
  }).flatMap((decodedJson) {
    // Ahora 'decodedJson' es un Map, por lo que podemos acceder al token.
    final token = decodedJson['token'];
    if (token != null && token is String) {
      return TaskEither.right(token);
    }
    return TaskEither.left('Token no encontrado o inválido en la respuesta');
  });
}

// # Función funcional para procesar respuestas de registro usando TaskEither
// Maneja diferentes tipos de errores de registro (IdentityError, ModelState, etc.)
TaskEither<String, String> processRegisterResponseFunc(int statusCode, String responseBody) {
  return TaskEither<String, String>.fromPredicate(
    responseBody,
    (_) => statusCode == 200 || statusCode == 201,
    (body) {
      try {
        final errorData = json.decode(body);
        // Si la respuesta es una lista de errores (IdentityError)
        if (errorData is List) {
          return errorData.map((e) => e['description']).join('\n');
        } else if (errorData is Map && errorData.containsKey('errors')) {
          // Para errores de ModelState
          return errorData['errors'].entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('\n');
        } else if (errorData['message'] != null) {
          return errorData['message'];
        } else {
          return 'Error de registro (${statusCode})';
        }
      } catch (e) {
        return body.isNotEmpty ? body : 'Error de comunicación con el servidor';
      }
    },
  ).flatMap((body) {
    // En caso de éxito, extraer el mensaje de confirmación
    return TaskEither<String, Map<String, dynamic>>.tryCatch(
      () async => json.decode(body) as Map<String, dynamic>,
      (e, stackTrace) => 'Formato de respuesta inválido',
    );
  }).flatMap((decodedJson) {
    // Extraer mensaje de éxito
    final message = decodedJson['message'] ?? 'Usuario registrado exitosamente';
    return TaskEither.right(message);
  });
}

// # Función funcional para validar campos de formulario usando Either
// Devuelve Left(errorMessage) si la validación falla, Right(value) si es válido
Either<String, String> validateRequiredFieldFunc(String? value, String fieldName) {
  return Either.fromPredicate(
    value ?? '',
    (val) => val.isNotEmpty,
    (_) => 'Ingresa tu $fieldName',
  );
}

// # Función funcional para validar email usando Either
Either<String, String> validateEmailFunc(String? email) {
  return validateRequiredFieldFunc(email, 'correo electrónico')
    .flatMap((email) => Either.fromPredicate(
      email,
      (e) => e.contains('@') && e.contains('.'),
      (_) => 'Ingresa un correo válido',
    ));
}

// # Función funcional para validar contraseña usando Either
Either<String, String> validatePasswordFunc(String? password, {int minLength = 6}) {
  return validateRequiredFieldFunc(password, 'contraseña')
    .flatMap((pwd) => Either.fromPredicate(
      pwd,
      (p) => p.length >= minLength,
      (_) => 'La contraseña debe tener al menos $minLength caracteres',
    ));
}

// # Función funcional para validar confirmación de contraseña usando Either
Either<String, String> validatePasswordConfirmationFunc(String? confirmation, String password) {
  return validateRequiredFieldFunc(confirmation, 'confirmación de contraseña')
    .flatMap((conf) => Either.fromPredicate(
      conf,
      (c) => c == password,
      (_) => 'Las contraseñas no coinciden',
    ));
}
