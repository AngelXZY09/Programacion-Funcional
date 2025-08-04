using System;
using System.Collections.Generic;

namespace ApiCrud.Entitys;

public partial class EstudianteXactividade
{
    public int Id { get; set; }

    public string IdEstudiante { get; set; }


    public DateOnly FechaInscripcion { get; set; }

    public bool? Aprobado { get; set; }


    public int IdGrupoHorario { get; set; }
    public GrupoHorario idGrupoHorarioNavigation { get; set; }

    public virtual User IdEstudianteNavigation { get; set; } = null!;

    public int IdHorarioDetalle { get; set; }
    public HorarioDetalle idHorarioDetalleNavigation { get; set; } = null!;

    public int ActividadId { get; set; }

    public Actividad idActividadNavigation { get; set; }

}
