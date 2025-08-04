namespace ApiCrud.Entitys
{
    public class Inscrito
    {

        public int? InscripcionId { get; set; }

        public int? IdHorario { get; set; }

        public string? fechaDeInscripcion { get; set; } // Fecha de inscripción (si corresponde)

        public bool? aprobado { get; set; }


        public int? idHorarioDetalle { get; set; }
    }
}
