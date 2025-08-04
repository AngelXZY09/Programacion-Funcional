using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using ApiCrud.Entitys; // Asegúrate de que el namespace sea correcto
using Microsoft.EntityFrameworkCore; // Para usar .Include, .Where, etc.

namespace ApiCrud.services
{
    public class ActividadService
    {
        private readonly AppDbContext _context; // Inyecta el DbContext

        public ActividadService(AppDbContext context)
        {
            _context = context;
        }

        // Método principal que devuelve la vista de la actividad
        // Este método es "casi" puro, ya que su única "impureza" es la interacción con la base de datos
        // a través de _context. Sin embargo, la lógica de transformación interna es funcional.
        public async Task<ActividadView?> GetActividadViewAsync(int idActividad, string? idEstudiante)
        {
            var actividad = await _context.Actividad
                .Include(a => a.IdCategoriaNavigation)
                .Include(a => a.IdEncargadoNavigation)
                .Include(a => a.GruposHorario)
                    .ThenInclude(gh => gh.HorariosDetalle)
                .Include(a => a.EstudianteXactividades)
                .Where(a => a.Id == idActividad)
                .FirstOrDefaultAsync();

            if (actividad == null)
            {
                return null;
            }

            var actividadViewModel = new ActividadView
            {
                IdActividad = actividad.Id,
                NombreActividad = actividad.NombreActividad,
                NombreCategoria = actividad.IdCategoriaNavigation?.NombreCategoria,
                NombreEncargado = actividad.IdEncargadoNavigation?.Nombre,
                Instalacion = actividad.Instalacion,
                Estado = actividad.Estado,
                Creditos = actividad.Creditos,
                FechaInicio = actividad.FechaHoraInicio,
                FechaFinal = actividad.FechaHoraFin,
                DatosExtra = actividad.DatosExtra,
                Descripcion = actividad.Descripcion,
                Imagen = actividad.ImagenUrl,
                Datos = actividad.EstudianteXactividades
                    .Where(exa => exa.IdEstudiante == idEstudiante)
                    .Select(exa => new Inscrito
                    {
                        InscripcionId = exa.Id,
                        IdHorario = exa.IdGrupoHorario,
                        fechaDeInscripcion = exa.FechaInscripcion.ToString("yyyy-MM-dd"),
                        aprobado = exa.Aprobado,
                        idHorarioDetalle=exa.IdHorarioDetalle
                    })
                    .FirstOrDefault()
            };

            actividadViewModel.GruposHorarioVista = actividad.GruposHorario
                .Select(grupo => MapGrupoHorarioToView(grupo)) // Ya no necesitamos idEstudiante aquí, solo el grupo
                .ToList();

            return actividadViewModel;
        }

        private GrupoHorarioView MapGrupoHorarioToView(GrupoHorario grupo)
        {
            var detalles = grupo.HorariosDetalle.ToList();

            var grupoVista = new GrupoHorarioView
            {
                GrupoHorarioId = grupo.Id,
                TipoDeHorario = grupo.TipoDeHorario,
                CupoMaximo = grupo.CupoMaximo,
                // Los detalles individuales (HorarioDetalleInfo) siempre son útiles para referenciar el ID original
                Detalles = detalles
                    .Select(h => new HorarioDetalleInfo
                    {
                        Id = h.Id,
                        GrupoHorarioId = h.GrupoHorarioId,
                        HoraInicio = $"{h.HoraInicio:hh\\:mm}",
                        HoraFin = $"{h.HoraFin:hh\\:mm}",
                        Fecha = h.Fecha?.ToString("yyyy-MM-dd"),
                        DiaSemanaNombre = !string.IsNullOrEmpty(h.DiaSemana) ? GetNombreDiaSemana(h.DiaSemana) : null
                    })
                    .ToList(),
                // Resumen de todas las horas (puedes decidir si mantenerlo o no)
                HorasResumen = detalles
                    .Select(h => $"{h.HoraInicio:hh\\:mm} a {h.HoraFin:hh\\:mm}")
                    .Distinct()
                    .ToList()
            };

            if (grupo.TipoDeHorario == "PorFecha" || grupo.TipoDeHorario == "Unico")
            {
                var fechasDetalleConHoras = detalles
                    .Where(h => h.Fecha.HasValue)
                    .GroupBy(h => h.Fecha!.Value.Date) // Agrupa por la fecha (solo el día, mes, año)
                    .OrderBy(g => g.Key) // Ordena por fecha
                    .Select(g => new FechaConHoras
                    {
                        Fecha = g.Key.ToString("yyyy-MM-dd"),
                        Horas = g.Select(h => $"{h.HoraInicio:hh\\:mm} a {h.HoraFin:hh\\:mm}").OrderBy(s => s).ToList() // Horas para esa fecha
                    })
                    .ToList();

                // Regla 3: Unico con 1 elemento vs. FechasConHoras
                if (grupo.TipoDeHorario == "Unico" && fechasDetalleConHoras.Count == 1)
                {
                    grupoVista.FechaUnica = fechasDetalleConHoras.First().Fecha;
                    // Si solo hay una fecha única, no llenamos FechasConHoras para evitar redundancia
                }
                else
                {
                    grupoVista.FechasConHoras = fechasDetalleConHoras;
                }

                // Texto descriptivo para fechas
                if (fechasDetalleConHoras.Any())
                {
                    // Obtenemos solo las fechas como strings desde la lista de FechaConHoras
                    var fechasString = fechasDetalleConHoras.Select(fch => fch.Fecha).ToList();

                    // Unimos las fechas con comas
                    grupoVista.TextoAgrupado = string.Join(", ", fechasString);
                }
            }
            else if (grupo.TipoDeHorario == "Semanal")
            {
                grupoVista.DiasConHoras = detalles
                    .Where(h => !string.IsNullOrEmpty(h.DiaSemana))
                    .GroupBy(h => h.DiaSemana!) // Agrupa por el número de día
                    .OrderBy(g => g.Key) // Ordena por el número de día
                    .Select(g => new DiaConHoras
                    {
                        DiaSemana = GetNombreDiaSemana(g.Key)!, // Convierte el número a nombre del día
                        Horas = g.Select(h => $"{h.HoraInicio:hh\\:mm} a {h.HoraFin:hh\\:mm}").OrderBy(s => s).ToList() // Horas para ese día
                    })
                    .ToList();

                // Texto descriptivo para días
                var nombresDiasAgrupados = grupoVista.DiasConHoras.Select(d => d.DiaSemana).ToList();
                if (nombresDiasAgrupados.Any())
                {
                    grupoVista.TextoAgrupado = ObtenerTextoGrupo(nombresDiasAgrupados);
                }
            }

            return grupoVista;
        }

        // Funciones auxiliares (permanecen iguales)
        private string? GetNombreDiaSemana(string? diaNumero)
        {
            if (string.IsNullOrEmpty(diaNumero)) return null;
            return diaNumero switch
            {
                "1" => "Lunes",
                "2" => "Martes",
                "3" => "Miércoles",
                "4" => "Jueves",
                "5" => "Viernes",
                "6" => "Sábado",
                "7" => "Domingo",
                _ => null
            };
        }

        private string ObtenerTextoGrupo(List<string> diasema)
        {
            if (diasema == null || !diasema.Any()) return string.Empty;
            if (diasema.Count == 1) return $"Todos los {diasema[0]}";
            var resultado = string.Join(", ", diasema.Take(diasema.Count - 1));
            resultado += $" y {diasema.Last()}";
            return $"Todos los {resultado}";
        }
    }
}
