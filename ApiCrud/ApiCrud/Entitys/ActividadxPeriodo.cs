namespace ApiCrud.Entitys
{
    public class ActividadxPeriodo
    {
        public int Id { get; set; }

        public int ActividadId { get; set; }
        public Actividad Actividad { get; set; }

        public int PeriodoId { get; set; }
        public Periodo Periodo { get; set; }

   
    }
}
