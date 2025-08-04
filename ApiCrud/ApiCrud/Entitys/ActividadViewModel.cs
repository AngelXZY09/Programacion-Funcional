namespace ApiCrud.Entitys
{
    public class ActividadViewModel
    {
        public int Id { get; set; }
        public string? Nombre { get; set; }
        public string? Descripcion { get; set; }
        public string? Encargado { get; set; }
        public string? Categoria { get; set; }
        public string? estado { get; set; }

        public int? Creditos { get; set; }

        public Boolean estaInscrito { get; set; } // Para saber si el estudiante está inscrito en la actividad

        public string urlImg { get; set; }
    }
}
