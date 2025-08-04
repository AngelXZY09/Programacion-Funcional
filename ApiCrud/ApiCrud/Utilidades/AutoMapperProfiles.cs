using ApiCrud.DTOs;
using ApiCrud.Entitys;
using AutoMapper;

namespace ApiCrud.Utilidades
{
    public class AutoMapperProfiles : Profile
    {
        public AutoMapperProfiles() 
        {
            CreateMap<Inscripcion,EstudianteXactividade>();
        }
    }
}
