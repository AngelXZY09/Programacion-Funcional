using System.ComponentModel.DataAnnotations;

namespace ApiCrud.Entitys
{
    public class Periodo
    {
        public int Id { get; set; }
        [Required]
        [MaxLength(70)]
        public string EtiquetaPeriodo { get; set; }

        public ICollection<ActividadxPeriodo> ActividadXPeriodos { get; set; }

        public DateOnly FechaHoraInicio { get; set; }
        public DateOnly FechaHoraFin { get; set; }
    }
}
