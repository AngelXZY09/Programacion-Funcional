import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile/models/activities_response.dart';
import 'package:mobile/models/history_response.dart';
import 'package:mobile/models/activity_with_details.dart';
import 'package:mobile/models/inscripcion_request_dto.dart';
import 'package:mobile/models/update_enrollment_dto.dart';
import 'package:mobile/services/auth_service.dart';
// Es posible que necesitemos AuthService para la URL base o el token,
// pero por ahora, el token se pasará directamente al método.
// import 'package:mobile/services/auth_service.dart';

http.Client createHttpClient() {
  final client = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true; // acepta todo
  return IOClient(client);
}
class ActivityService {
  // La URL base se podría obtener de AuthService o definirse aquí si es diferente.
  // Por coherencia, usemos la misma que en AuthService.
  static const String _baseUrl = 'https://10.0.2.2:5001';
  final http.Client _httpClient = createHttpClient();
  final AuthService _authService;

  ActivityService({required AuthService authService}) : _authService = authService;

  Future<ActivitiesResponse> getActivities({
    required String token,
    bool excluirInscritas = false,
  }) async {
    var httpClient = createHttpClient();
    final queryParameters = {
      'excluirInscritas': excluirInscritas.toString(),
    };
    final uri = Uri.parse('$_baseUrl/User/Actividades').replace(queryParameters: queryParameters);

    print('ActivityService: Fetching activities from $uri');

    try {
      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Incluir el token de autenticación
        },
      );

      print('ActivityService (getActivities): Response status: ${response.statusCode}');
      // print('ActivityService (getActivities): Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ActivitiesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        print('ActivityService (getActivities): Unauthorized access. Forcing logout.');
        await _authService.forceLogout();
        throw Exception('Acceso no autorizado (${response.statusCode}). Sesión cerrada.');
      } else {
        print('ActivityService (getActivities): Error - ${response.statusCode}: ${response.body}');
        throw Exception('Error al cargar actividades (${response.statusCode})');
      }
    } catch (e) {
      print('ActivityService (getActivities): Exception: $e');
      if (e.toString().contains('Acceso no autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión o al procesar la respuesta de actividades: ${e.toString()}');
    }
  }

  Future<HistoryResponse> getHistory({required String token}) async {
    final uri = Uri.parse('$_baseUrl/User/Historial');
    print('ActivityService: Fetching history from $uri');
    var httpClient = createHttpClient();
    try {
      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ActivityService (getHistory): Response status: ${response.statusCode}');
      // print('ActivityService (getHistory): Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return HistoryResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        print('ActivityService (getHistory): Unauthorized access. Forcing logout.');
        await _authService.forceLogout();
        throw Exception('Acceso no autorizado al historial (${response.statusCode}). Sesión cerrada.');
      } else if (response.statusCode == 404) { // El API devuelve 404 si no hay historial
        print('ActivityService (getHistory): No history found (404). Returning empty response.');
        // Devolver una respuesta de historial vacía en lugar de lanzar una excepción por 404
        return HistoryResponse(totalCreditos: 0, periodos: []);
      } else {
        print('ActivityService (getHistory): Error - ${response.statusCode}: ${response.body}');
        throw Exception('Error al cargar el historial (${response.statusCode})');
      }
    } catch (e) {
      print('ActivityService (getHistory): Exception: $e');
      if (e.toString().contains('Acceso no autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión o al procesar la respuesta del historial: ${e.toString()}');
    }
  }

  Future<ActivityWithDetails> getActivityDetails({
    required String token,
    required int activityId,
  }) async {
    final uri = Uri.parse('$_baseUrl/Actividad/$activityId/activiadInformacion');
    print('ActivityService: Fetching details for activity $activityId from $uri');

    try {
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('ActivityService (getActivityDetails): Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return ActivityWithDetails.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        print('ActivityService (getActivityDetails): Unauthorized access. Forcing logout.');
        await _authService.forceLogout();
        throw Exception('Acceso no autorizado a detalles (${response.statusCode}). Sesión cerrada.');
      } else {
        print('ActivityService (getActivityDetails): Error - ${response.statusCode}: ${response.body}');
        throw Exception('Error al cargar detalles de la actividad (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('ActivityService (getActivityDetails): Exception: $e');
      if (e.toString().contains('Acceso no autorizado')) {
        rethrow;
      }
      throw Exception('Error de conexión o al procesar detalles: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> enrollToActivity({
    required String token,
    required InscripcionRequestDto inscripcionDto,
  }) async {
    final uri = Uri.parse('$_baseUrl/Actividad/inscripcion');
    print('ActivityService: Enrolling to activity ${inscripcionDto.idActividad} at $uri with body: ${json.encode(inscripcionDto.toJson())}');

    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(inscripcionDto.toJson()),
      );
      print('ActivityService (enrollToActivity): Response status: ${response.statusCode}');
      final responseBody = json.decode(response.body);

      if (response.statusCode == 401) {
        print('ActivityService (enrollToActivity): Unauthorized access. Forcing logout.');
        await _authService.forceLogout();
        return {
          'success': false,
          'message': 'Acceso no autorizado. Sesión cerrada.',
          'apiStatusCode': response.statusCode
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': responseBody['succes'] ?? true,
          'message': responseBody['message'] ?? 'Inscripción procesada.',
          'apiStatusCode': responseBody['statusCode']
        };
      } else {
        return {
          'success': responseBody['succes'] ?? false,
          'message': responseBody['message'] ?? 'Error en la inscripción (${response.statusCode})',
          'apiStatusCode': responseBody['statusCode'] ?? response.statusCode
        };
      }
    } catch (e) {
      print('ActivityService (enrollToActivity): Exception: $e');
      return {
        'success': false,
        'message': 'Error de conexión o al procesar inscripción: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateEnrollment({
    required String token,
    required int inscripcionId,
    required UpdateEnrollmentDto updateDto,
  }) async {
    final uri = Uri.parse('$_baseUrl/Actividad/$inscripcionId/actualizar');
    print('ActivityService: Updating enrollment $inscripcionId at $uri with body: ${json.encode(updateDto.toJson())}');

    try {
      final response = await _httpClient.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateDto.toJson()),
      );
      print('ActivityService (updateEnrollment): Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('ActivityService (updateEnrollment): Unauthorized access. Forcing logout.');
        await _authService.forceLogout();
        return {
          'success': false,
          'message': 'Acceso no autorizado. Sesión cerrada.',
        };
      }

      if (response.statusCode == 204) { // No Content, éxito
        return {
          'success': true,
          'message': 'Inscripción actualizada correctamente.',
        };
      } else {
        String errorMessage = 'Error al actualizar la inscripción (${response.statusCode})';
        try {
          // Solo intentar decodificar si el cuerpo no está vacío, lo cual es común para errores 400/500
          if (response.body.isNotEmpty) {
            final responseBody = json.decode(response.body);
            errorMessage = responseBody['message'] ?? errorMessage;
          } else {
             print('ActivityService (updateEnrollment): Error response body is empty.');
          }
        } catch (e) {
          print('ActivityService (updateEnrollment): Could not decode error body: $e. Body: ${response.body}');
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('ActivityService (updateEnrollment): Exception: $e');
      return {
        'success': false,
        'message': 'Error de conexión o al procesar la actualización: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteEnrollment({
    required String token,
    required int inscripcionId,
  }) async {
    final uri = Uri.parse('$_baseUrl/Actividad/$inscripcionId/eliminar');
    print('ActivityService: Deleting enrollment $inscripcionId at $uri');

    try {
      final response = await _httpClient.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('ActivityService (deleteEnrollment): Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('ActivityService (deleteEnrollment): Unauthorized access. Forcing logout.');
        await _authService.forceLogout();
        return {
          'success': false,
          'message': 'Acceso no autorizado. Sesión cerrada.',
        };
      }
      
      if (response.statusCode == 204) { // No Content, éxito
        return {
          'success': true,
          'message': 'Inscripción eliminada correctamente.',
        };
      } else {
        String errorMessage = 'Error al eliminar la inscripción (${response.statusCode})';
        try {
           if (response.body.isNotEmpty) {
            final responseBody = json.decode(response.body);
            errorMessage = responseBody['message'] ?? errorMessage;
          } else {
            print('ActivityService (deleteEnrollment): Error response body is empty.');
          }
        } catch (e) {
          print('ActivityService (deleteEnrollment): Could not decode error body: $e. Body: ${response.body}');
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('ActivityService (deleteEnrollment): Exception: $e');
      return {
        'success': false,
        'message': 'Error de conexión o al procesar la eliminación: ${e.toString()}',
      };
    }
  }
} 