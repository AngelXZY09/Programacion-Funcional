namespace ApiCrud.Entitys
{
    public class GrupoHorarioViews
    {
        public int GrupoHorarioId { get; set; }
        public string? TipoDeHorario { get; set; }
        public List<string> Fechas { get; set; } = new();
        public List<string> Horas { get; set; } = new();
        public string? TextoAgrupado { get; set; }
        public List<HorarioDetalleInfo> Detalles { get; set; } = new();

        public string? DiaSemana { get; set; }
    }
}
