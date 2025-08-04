using System;
using System.Collections.Generic;

namespace ApiCrud.Entitys;

public partial class Categoria
{
    public int Id { get; set; }

    public string NombreCategoria { get; set; } = null!;

    public int? LimiteCreditos { get; set; }

    public bool PermiteOtroPerido { get; set; } // <--- Aquí

    public virtual ICollection<Actividad> Actividads { get; set; } = new List<Actividad>();
}
