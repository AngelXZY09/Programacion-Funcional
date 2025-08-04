using System.ComponentModel.DataAnnotations;

namespace ApiCrud.Entitys
{
    public class HorarioDetalle
    {
        public int Id { get; set; }

        public int GrupoHorarioId { get; set; }
        public GrupoHorario GrupoHorario { get; set; }

        // Puede ser por fecha única o recurrente
        public DateTime? Fecha { get; set; }

        [MaxLength(20)]
        public string DiaSemana { get; set; } // Ej: "Lunes", "Martes"

        [Required]
        public TimeSpan HoraInicio { get; set; }

        [Required]
        public TimeSpan HoraFin { get; set; }

        public ICollection<EstudianteXactividade> EstudianteXactividades { get; set; }
    }
}
