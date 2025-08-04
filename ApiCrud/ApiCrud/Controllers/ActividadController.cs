using System.ComponentModel;
using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using ApiCrud.DTOs;
using ApiCrud.Entitys;
using ApiCrud.services;
using AutoMapper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiCrud.Controllers
{
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ApiController]
    [Route("[controller]")]
    public class ActividadController : ControllerBase
    {
        private readonly AppDbContext context;
        private readonly IMapper mapper;
        private readonly ActividadService _actividadService;
        private readonly IInscripcionService _inscripcionService;
        public ActividadController(AppDbContext context, IMapper mapper, ActividadService actividadService , IInscripcionService inscripcionService)
        {
            this.context = context;
            this.mapper = mapper;
            _actividadService = actividadService;
            _inscripcionService = inscripcionService;
        }

        [HttpGet("{idActividad:int}/activiadInformacion")]
        public async Task<ActionResult<ActividadView>> Get(int idActividad)
        {
            Console.WriteLine("Inicio (Controlador)");
            var idEstudiante = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            Console.WriteLine("ID ESTUDIANTE: " + idEstudiante);

            // Validaciones del estudiante (podrían ir en el servicio, pero a veces se dejan aquí
            // si son validaciones pre-obtención de datos)
            var estudianteExiste = await context.Users.AnyAsync(e => e.Id == idEstudiante); // Acceder al contexto a través del servicio
            if (!estudianteExiste)
            {
                return NotFound(JsonSerializer.Serialize(new MessageManagerError
                {
                    succes = false,
                    message = $"No se encontró ningún estudiante con ID {idEstudiante}.",
                    codeError = 404
                }));
            }

            // Llamada al servicio para obtener la vista de la actividad
            var actividadViewModel = await _actividadService.GetActividadViewAsync(idActividad, idEstudiante);

            if (actividadViewModel == null)
            {
                return NotFound(JsonSerializer.Serialize(new MessageManagerError
                {
                    succes = false,
                    message = "Actividad no encontrada.",
                    codeError = 1
                }));
            }

            return Ok(actividadViewModel);
        }



        [HttpPost("inscripcion")]
        public async Task<IActionResult> Inscribir(Inscripcion request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // 1. Obtener el ID del estudiante del JWT
            // Es crucial saber qué "claim type" usas para el ID del estudiante.
            // Los comunes son ClaimTypes.NameIdentifier (para el Subject/Sub) o un claim personalizado.
            var idEstudiante = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(idEstudiante))
            {
                // Esto no debería pasar si [Authorize] funciona correctamente y el token tiene el claim.
                return Unauthorized(new { message = "No se pudo obtener el ID del estudiante del token." });
            }
            var estudianteExiste = await context.Users.AnyAsync(e => e.Id == idEstudiante); // Acceder al contexto a través del servicio
            if (!estudianteExiste)
            {
                return NotFound(JsonSerializer.Serialize(new MessageManagerError
                {
                    succes = false,
                    message = $"No se encontró ningún estudiante con ID {idEstudiante}.",
                    codeError = 404
                }));
            }

            // 2. Llamar al servicio con el ID del estudiante extraído del JWT
            var statusCode = await _inscripcionService.InscribirEstudiante(
                idEstudiante, // Este es el ID del estudiante de tipo string
                request.IdActividad,
                request.IdGrupoHorario,
                request.IdHorarioDetalle
            );

            // Mapear el código de estado del SP a respuestas HTTP adecuadas
            switch (statusCode)
            {
                case 0:
                    return Ok(new { succes=true, message = "Inscripción exitosa.", statusCode = 0 });
                case 1:
                    return NotFound(new {succes=false, message = "La actividad especificada no existe.", statusCode = 1 });
                case 2:
                    return BadRequest(new { succes = false, message = "La actividad no está disponible para inscripción.", statusCode = 2 });
                case 3:
                    return Conflict(new { succes = false, message = "El estudiante ya está inscrito en esta combinación de actividad, grupo y horario.", statusCode = 3 });
                case 4:
                    return StatusCode(403, new { succes = false, message = "Límite de créditos superado para esta categoría de actividad.", statusCode = 4 });
                case 5:
                    return StatusCode(500, new { succes = false, message = "Error de configuración: No se encontró el límite de créditos global.", statusCode = 5 });

                case 6:
                    return Conflict(new { succes = false, message = "No se puede inscribirse a la actividad, debido a que sobrepasa la cantidad máxima de creditos totales", statusCode = 6 });
                default:
                    return StatusCode(500, new { succes = false, message = $"Error desconocido durante la inscripción. Código: {statusCode}", statusCode = statusCode });
            }
        }


        [HttpPut("{idInscripcion:int}/actualizar")]
        public async Task<ActionResult> ActualizarInscripcion(int idInscripcion, [FromBody] actualizarDTO dto)
        {
            // 1. Obtener el ID del estudiante del JWT
            var idEstudiante = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(idEstudiante))
            {
                return Unauthorized(new MessageManagerError { succes = false, message = "ID de estudiante no encontrado en el token.", codeError = 6 });
            }

            // 2. Validar el DTO de entrada
            if (!ModelState.IsValid)
            {
                return BadRequest(new MessageManagerError
                {
                    succes = false,
                    message = "Ocurrió un error con los datos, por favor verifique el contenido.",
                    codeError = 5
                });
            }

            // 3. Buscar la inscripción existente por ID de inscripción y ID de estudiante
            var inscripcionExistente = await context.EstudianteXactividades
                .FirstOrDefaultAsync(e => e.Id == idInscripcion && e.IdEstudiante == idEstudiante);

            if (inscripcionExistente == null)
            {
                return NotFound(new MessageManagerError
                {
                    succes = false,
                    message = "No se encontró el registro de inscripción para el estudiante y ID proporcionados.",
                    codeError = 7
                });
            }

            // 4. Validar que la IdActividad en el DTO coincida con la del registro existente
            // El usuario indicó que IdActividad en el DTO es para identificación, no para cambio.
            if (inscripcionExistente.ActividadId != dto.IdActividad)
            {
                return BadRequest(new MessageManagerError
                {
                    succes = false,
                    message = "La IdActividad en el cuerpo de la solicitud no coincide con la actividad de la inscripción existente.",
                    codeError = 8 // Nuevo código de error para esta validación
                });
            }

            // 5. Opcional: Verificar si el nuevo IdGrupoHorario y IdHorarioDetalle son válidos
            // Esto implicaría verificar si la combinación existe en HorarioDetalles
            // y si está asociada a la misma ActividadId.
            // Si necesitas esta validación, descomenta y adapta el siguiente bloque:
            
            var horarioValido = await context.HorarioDetalles
                .AnyAsync(hd => hd.Id == dto.IdHorarioDetalle && hd.GrupoHorarioId == dto.IdGrupoHorario);
                // Puedes añadir una condición para verificar que este horario pertenece a la actividad:
                // && context.ActividadGrupoHorario.Any(agh => agh.ActividadId == dto.IdActividad && agh.GrupoHorarioId == dto.IdGrupoHorario)
                // (Asumiendo que tienes una tabla de unión o relación entre Actividad y GrupoHorario)

            if (!horarioValido)
            {
                return BadRequest(new MessageManagerError
                {
                    succes = false,
                    message = "La combinación de GrupoHorario y HorarioDetalle no es válida o no existe.",
                    codeError = 9 // Nuevo código de error
                });
            }

            // 6. Actualizar las propiedades del registro existente
            // No mapeamos directamente todo el DTO para evitar sobrescribir Id, IdEstudiante, FechaInscripcion, etc.
            inscripcionExistente.IdGrupoHorario = dto.IdGrupoHorario;
            inscripcionExistente.IdHorarioDetalle = dto.IdHorarioDetalle;
            inscripcionExistente.Aprobado = dto.Aprobado; // Actualiza el estado de aprobación

            try
            {
                context.Update(inscripcionExistente); // Marca la entidad como modificada
                await context.SaveChangesAsync(); // Guarda los cambios en la base de datos
                return NoContent(); // 204 No Content es una respuesta estándar para PUT exitoso sin cuerpo
            }
            catch (Exception ex)
            {
                return StatusCode(500, new MessageManagerError
                {
                    succes = false,
                    message = $"Ocurrió un error al actualizar la inscripción: {ex.Message}",
                    codeError = 10
                });
            }
        }

        /// <summary>
        /// Elimina un registro de inscripción de un estudiante.
        /// El ID del estudiante se obtiene del JWT.
        /// </summary>
        /// <param name="idInscripcion">El ID del registro de inscripción a eliminar.</param>
        /// <returns>Estado HTTP 204 No Content si la eliminación es exitosa, o un error.</returns>
        [HttpDelete("{idInscripcion:int}/eliminar")]
        public async Task<ActionResult> EliminarInscripcion(int idInscripcion)
        {
            // 1. Obtener el ID del estudiante del JWT
            var idEstudiante = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(idEstudiante))
            {
                return Unauthorized(new MessageManagerError { succes = false, message = "ID de estudiante no encontrado en el token.", codeError = 6 });
            }

            try
            {
                // 2. Buscar y eliminar el registro
                // Usamos ExecuteDeleteAsync para una eliminación más eficiente si no necesitas cargar la entidad completa.
                // Asegúrate de que el paquete Microsoft.EntityFrameworkCore.Relational esté instalado para ExecuteDeleteAsync.
                var filasEliminadas = await context.EstudianteXactividades
                    .Where(e => e.Id == idInscripcion && e.IdEstudiante == idEstudiante)
                    .ExecuteDeleteAsync();

                if (filasEliminadas == 0)
                {
                    return NotFound(new MessageManagerError
                    {
                        succes = false,
                        message = "No se encontró el registro de inscripción para el estudiante y ID proporcionados.",
                        codeError = 7
                    });
                }

                return NoContent(); // 204 No Content para eliminación exitosa
            }
            catch (Exception ex)
            {
                return StatusCode(500, new MessageManagerError
                {
                    succes = false,
                    message = $"Ocurrió un error al eliminar el registro: {ex.Message}",
                    codeError = 11
                });
            }
        }

    }
}
