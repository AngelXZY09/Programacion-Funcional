using System;
using System.Collections.Generic;

namespace ApiCrud.Entitys;

public partial class VistaCreditoEstudiante
{
    public int EstudianteId { get; set; }

    public string Nombre { get; set; } = null!;

    public string NombreCategoria { get; set; } = null!;

    public int? CreditosAcumulados { get; set; }

    public int? LimitePorCategoria { get; set; }

    public string EstadoCredito { get; set; } = null!;
}
