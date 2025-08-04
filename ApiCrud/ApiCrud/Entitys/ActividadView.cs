namespace ApiCrud.Entitys
{
    public class ActividadView
    {
        public int IdActividad { get; set; }
        public string? NombreActividad { get; set; }
        public string? NombreCategoria { get; set; }
        public string? NombreEncargado { get; set; }
        public string? Instalacion { get; set; }
        public string? Estado { get; set; }
        public int? Creditos { get; set; }
        public DateOnly FechaInicio { get; set; }
        public DateOnly FechaFinal { get; set; }
        public string? DatosExtra { get; set; }
        public string? Descripcion { get; set; }
        public string? Imagen { get; set; }

        public Inscrito? Datos { get; set; }

        // Ahora toda la información de horarios se centraliza aquí
        public List<GrupoHorarioView> GruposHorarioVista { get; set; } = new();
    }

    // Clase para la vista de cada grupo de horario
    public class GrupoHorarioView
    {
        public int GrupoHorarioId { get; set; }
        public string TipoDeHorario { get; set; } = null!;
        public int CupoMaximo { get; set; }

        // Para Tipo "Unico" con un solo elemento
        public string? FechaUnica { get; set; }

        // **NUEVOS CAMPOS para la agrupación**
        public List<FechaConHoras>? FechasConHoras { get; set; } // Para "PorFecha" y "Unico" (más de 1)
        public List<DiaConHoras>? DiasConHoras { get; set; }    // Para "Semanal"

        // Eliminamos las propiedades 'Fechas', 'Dias' y 'Horas' planas si ya no las necesitas directamente.
        // Las propiedades 'Horas' aún podrían ser útiles para un resumen general, pero si la idea es
        // ver horas por fecha/día, las nuevas estructuras son más adecuadas.
        // Por ahora, las mantendremos si necesitas la lista de horas *distintas* para el resumen,
        // pero ten en cuenta que la información detallada vendrá de FechasConHoras/DiasConHoras.
        // public List<string> Fechas { get; set; } = new(); // Se reemplazaría por FechasConHoras
        // public List<string> Dias { get; set; } = new();   // Se reemplazaría por DiasConHoras
        // public List<string> Horas { get; set; } = new();   // Puede quedarse para un resumen de todas las horas

        public List<string> HorasResumen { get; set; } = new(); // Nombre más claro si la mantienes para resumen

        public string? TextoAgrupado { get; set; }

        public List<HorarioDetalleInfo> Detalles { get; set; } = new();
    }

    // **NUEVAS CLASES para agrupar fechas/días con sus horas**
    public class FechaConHoras
    {
        public string Fecha { get; set; } = null!; // Ej. "2024-10-05"
        public List<string> Horas { get; set; } = new(); // Ej. ["09:00 a 14:00", "10:00 a 15:00"]
    }

    public class DiaConHoras
    {
        public string DiaSemana { get; set; } = null!; // Ej. "Lunes"
        public List<string> Horas { get; set; } = new(); // Ej. ["10:00 a 14:00", "12:00 a 16:00"]
    }

    // ... (HorarioDetalleInfo y Inscrito permanecen iguales) ...

// Clase para almacenar la información detallada de HorarioDetalle
public class HorarioDetalleInfo
    {
        public int Id { get; set; }
        public int GrupoHorarioId { get; set; }
        public string HoraInicio { get; set; }
        public string HoraFin { get; set; }
        public string? Fecha { get; set; } // Ahora como string y puede ser null
        public string? DiaSemanaNombre { get; set; } // Agregado: Nombre del día para semanales
    }
}
