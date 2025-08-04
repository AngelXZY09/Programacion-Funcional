using System.Collections;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using ApiCrud.Entitys;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ApiCrud.Controllers
{   
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ApiController]
    [Route("User")]
    public class ListaActvidadesController : ControllerBase
    {
        private readonly AppDbContext context;

        public ListaActvidadesController(AppDbContext context)
        {
            this.context = context;
        }

        [HttpGet("Actividades")]
        public async Task<ActionResult<object>> GetActividades([FromQuery] bool excluirInscritas = false) // Retorna un objeto anónimo
        {
            try
            {
                Console.WriteLine("Inicio de GetActividades");
                var idEstudiante = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                Console.WriteLine("ID ESTUDIANTE: " + (idEstudiante ?? "NULO"));

                if (string.IsNullOrEmpty(idEstudiante))
                {
                    return Unauthorized(new MessageManagerError { succes = false, message = "ID de estudiante no encontrado en el token.", codeError = 6 });
                }

                var estudianteExiste = await context.Users
                    .AnyAsync(e => e.Id == idEstudiante);
                if (!estudianteExiste)
                {
                    return NotFound($"No se encontró ningún estudiante con ID {idEstudiante}.");
                }

                // --- 1. Obtener el Periodo Activo ---
                // Usamos DateOnly.FromDateTime para comparar solo la fecha, como indicaste.
                var fechaActualDateOnly = DateOnly.FromDateTime(DateTime.Now);

                var periodoActivo = await context.Periodos
                    .FirstOrDefaultAsync(p => fechaActualDateOnly >= p.FechaHoraInicio && fechaActualDateOnly <= p.FechaHoraFin);

                if (periodoActivo == null)
                {
                    // Si no hay un periodo activo, se devuelve una lista vacía de actividades y 0 créditos.
                    Console.WriteLine("No se encontró un período activo para la fecha actual.");
                    return Ok(new
                    {
                        totalCreditos = 0,
                        actividades = new List<ActividadViewModel>()
                    });
                }

                // --- 2. Obtener las Actividades IDs asociadas a ese Periodo ---
                var actividadesIdsEnPeriodo = await context.ActividadxPeriodos
                    .Where(ap => ap.PeriodoId == periodoActivo.Id)
                    .Select(ap => ap.ActividadId)
                    .ToListAsync();

                if (!actividadesIdsEnPeriodo.Any())
                {
                    // Si no hay actividades asociadas a este periodo, se devuelve una lista vacía y 0 créditos.
                    Console.WriteLine($"No se encontraron actividades asociadas al período activo (ID: {periodoActivo.Id}).");
                    return Ok(new
                    {
                        totalCreditos = 0,
                        actividades = new List<ActividadViewModel>()
                    });
                }

                // --- 3. Calcular Total de Créditos Aprobados ---
                // Esta consulta no carga entidades completas, por lo que no debería causar ciclos.
                var totalCreditos = await context.EstudianteXactividades
                    .Where(ea => ea.IdEstudiante == idEstudiante &&
                                 ea.idGrupoHorarioNavigation.Actividad.Estado == "Finalizada" &&
                                 ea.Aprobado == true)
                    .SumAsync(ea => ea.idGrupoHorarioNavigation.Actividad.Creditos);


                // --- 4. Obtener y Proyectar Actividades directamente a ActividadViewModel ---
                // ESTO ES CLAVE PARA EVITAR EL CICLO DE SERIALIZACIÓN.
                // Se realiza la proyección a ActividadViewModel *antes* de ToListAsync().
                // Las propiedades de navegación se acceden directamente para obtener los valores simples.
                var actividadesQuery = context.Actividad
                .Where(a => a.Estado != "Inicio")
                .Where(a => actividadesIdsEnPeriodo.Contains(a.Id));

                // Condición opcional según el parámetro
                if (excluirInscritas)
                {
                    actividadesQuery = actividadesQuery
                        .Where(a => !(a.EstudianteXactividades.Any(ea => ea.IdEstudiante == idEstudiante) && a.Estado == "Finalizada"));

                }

                var actividades = await actividadesQuery
                    .Select(a => new ActividadViewModel
                    {
                        Id = a.Id,
                        Nombre = a.NombreActividad,
                        Descripcion = a.Descripcion,
                        Encargado = a.IdEncargadoNavigation != null ? a.IdEncargadoNavigation.Nombre : null,
                        Categoria = a.IdCategoriaNavigation != null ? a.IdCategoriaNavigation.NombreCategoria : null,
                        estado = a.Estado,
                        Creditos = a.Creditos,
                        estaInscrito = a.EstudianteXactividades.Any(ea => ea.IdEstudiante == idEstudiante),
                        urlImg = a.ImagenUrl,
                    })
                    .ToListAsync();

                // Retornar objeto compuesto con totalCreditos y la lista de ActividadViewModel
                Console.WriteLine("Actividades obtenidas y proyectadas exitosamente.");
                return Ok(new
                {
                    totalCreditos,
                    actividades
                });
            }
            catch (Exception ex)
            {
                // Loguear la excepción para depuración
                Console.WriteLine($"Error al obtener actividades: {ex.Message}");
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                return StatusCode(500, $"Ocurrió un error al obtener las actividades: {ex.Message}");
            }
        }

        [HttpGet("Historial")]
        public async Task<ActionResult<object>> GetHistorial()
        {
            try
            {
                Console.WriteLine("Inicio");
                var idEstudiante = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                Console.WriteLine("ID ESTUDIANTE: " + idEstudiante);
                var estudianteExiste = await context.Users
                    .AnyAsync(e => e.Id == idEstudiante);
                if (!estudianteExiste)
                {
                    return NotFound($"No se encontró ningún estudiante con ID {idEstudiante}.");
                }

                // Total de créditos aprobados para actividades finalizadas
                var totalCreditos = await context.EstudianteXactividades
                    .Where(ea => ea.IdEstudiante == idEstudiante &&               
                                 ea.idGrupoHorarioNavigation.Actividad.Estado == "Finalizada" &&
                                 ea.Aprobado == true)
                    .SumAsync(ea => ea.idGrupoHorarioNavigation.Actividad.Creditos);

                Console.WriteLine("Hola"+totalCreditos);
                var actividades = await context.Actividad
                .Include(a => a.IdEncargadoNavigation)
                .Include(a => a.IdCategoriaNavigation)
                .Include(a => a.ActividadXPeriodos)
                    .ThenInclude(ap => ap.Periodo)
                .Include(a => a.EstudianteXactividades)
                .Where(a => a.EstudianteXactividades.Any(ea => ea.IdEstudiante == idEstudiante))
                .SelectMany(a => a.ActividadXPeriodos.Select(ap => new
                {
                    Periodo = ap.Periodo.EtiquetaPeriodo,
                    Actividad = new ActividadViewModel
                    {
                        Id = a.Id,
                        Nombre = a.NombreActividad,
                        Descripcion = a.Descripcion,
                        Encargado = a.IdEncargadoNavigation.Nombre,
                        Categoria = a.IdCategoriaNavigation.NombreCategoria,
                        estado = a.Estado,
                        Creditos = a.Creditos,
                        estaInscrito = true,
                        urlImg = a.ImagenUrl
                    }
                }))
                .ToListAsync();

                // Agrupar por período
                var actividadesPorPeriodo = actividades
                    .GroupBy(a => a.Periodo)
                    .ToDictionary(
                        g => g.Key,
                        g => g.Select(x => x.Actividad).ToList()
                    );


                if (actividades == null || actividadesPorPeriodo.Count == 0)
                {
                    return NotFound("El estudiante no tiene historial de actividades.");
                }

                var actividadesFormateadas = actividadesPorPeriodo
                .Select(kv => new
                {
                    periodo = kv.Key,
                    actividades = kv.Value
                })
                .ToList();

                return Ok(new
                {
                    totalCreditos,
                    periodos = actividadesFormateadas
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Ocurrió un error al obtener el historial: {ex.Message}");
            }
        }







    }
}
