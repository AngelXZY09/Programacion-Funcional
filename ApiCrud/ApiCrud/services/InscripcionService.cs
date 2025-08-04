namespace ApiCrud.services
{
    public class InscripcionService : IInscripcionService
    {
        private readonly AppDbContext _context;

        public InscripcionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<int> InscribirEstudiante(string idEstudiante, int idActividad, int idGrupoHorario, int idHorarioDetalle)
        {
            return await _context.InscribirEstudianteSp(idEstudiante, idActividad, idGrupoHorario, idHorarioDetalle);
        }
    }
}
