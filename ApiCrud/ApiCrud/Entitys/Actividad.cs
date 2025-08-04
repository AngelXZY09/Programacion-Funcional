using System;
using System.Collections.Generic;

namespace ApiCrud.Entitys;

public partial class Actividad
{
    public int Id { get; set; }

    public string NombreActividad { get; set; } = null!;

    public int IdCategoria { get; set; }

    public string IdEncargado { get; set; }
    public string? Instalacion { get; set; }

    public int Creditos { get; set; }


    public DateOnly FechaHoraInicio { get; set; }

    public DateOnly FechaHoraFin { get; set; }

    public string Estado { get; set; } = null!;

    public string? ImagenUrl { get; set; }

    public string? Descripcion { get; set; }

    public string? DatosExtra { get; set; }

    public virtual ICollection<EstudianteXactividade> EstudianteXactividades { get; set; } = new List<EstudianteXactividade>();

    public virtual Categoria IdCategoriaNavigation { get; set; } = null!;


    public ICollection<ActividadxPeriodo> ActividadXPeriodos { get; set; }



    public ICollection<GrupoHorario> GruposHorario { get; set; }

    public User IdEncargadoNavigation { get; set; } = null!;
}

