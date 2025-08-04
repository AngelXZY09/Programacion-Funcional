using System;
using System.Collections.Generic;

namespace ApiCrud.Entitys;

public partial class ConfiguracionGlobal
{
    public int Id { get; set; }

    public string Clave { get; set; } = null!;

    public string Valor { get; set; } = null!;

    public string? Descripcion { get; set; }
}
