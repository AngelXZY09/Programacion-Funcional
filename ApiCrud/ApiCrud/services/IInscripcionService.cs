namespace ApiCrud.services
{
    public interface IInscripcionService
    {
        Task<int> InscribirEstudiante(string idEstudiante, int idActividad, int idGrupoHorario, int idHorarioDetalle);
    }
    
}
