namespace ApiCrud.Entitys
{
    public class GrupoHorario
    {
        public int Id { get; set; }

        public int ActividadId { get; set; }
        public Actividad Actividad { get; set; }

        public int CupoMaximo { get; set; } // Cupo por grupo


        public string TipoDeHorario { get; set; } = null!; // Descripción del grupo horario
        public ICollection<HorarioDetalle> HorariosDetalle { get; set; }
        public ICollection<EstudianteXactividade> EstudianteXactividades { get; set; }
    }
}
