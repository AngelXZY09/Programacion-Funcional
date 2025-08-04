using System.ComponentModel.DataAnnotations;

namespace ApiCrud.DTOs
{
    public class Inscripcion
    {
        [Required]
        public int IdActividad { get; set; }
        [Required]
        public int IdGrupoHorario { get; set; }
        [Required]
        public int IdHorarioDetalle { get; set; }

        public bool aprobado { get;set; }
    }
}
