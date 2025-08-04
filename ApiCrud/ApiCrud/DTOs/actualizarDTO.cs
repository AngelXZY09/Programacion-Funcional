using System.ComponentModel.DataAnnotations;

namespace ApiCrud.DTOs
{
    public class actualizarDTO
    {
        [Required]
        public int IdActividad { get; set; }
        [Required]
        public int IdGrupoHorario { get; set; }
        [Required]
        public int IdHorarioDetalle { get; set; }

        public bool Aprobado { get; set; }


    }
}
