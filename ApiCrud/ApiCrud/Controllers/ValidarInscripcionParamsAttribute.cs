using ApiCrud;
using ApiCrud.Entitys;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;

public class ValidarInscripcionParamsAttribute : ActionFilterAttribute
{
    //private readonly CreditosComplementariosContext _context;

    //public ValidarInscripcionParamsAttribute(CreditosComplementariosContext context)
    //{
    //    _context = context;
    //}

    //public override async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    //{
    //    bool HasInvalidParam(string key) =>
    //        !context.ActionArguments.ContainsKey(key) ||
    //        !(context.ActionArguments[key] is int value) || value <= 0;

    //    if (HasInvalidParam("idestudiante"))
    //    {
    //        context.Result = new BadRequestObjectResult("El ID del estudiante debe ser un número positivo.");
    //        return;
    //    }
    //    if (HasInvalidParam("idActividad"))
    //    {
    //        context.Result = new BadRequestObjectResult("El ID de la actividad debe ser un número positivo.");
    //        return;
    //    }
    //    if (HasInvalidParam("idHorario"))
    //    {
    //        context.Result = new BadRequestObjectResult("El ID del horario debe ser un número positivo.");
    //        return;
    //    }

    //    int idEst = (int)context.ActionArguments["idestudiante"];
    //    int idAct = (int)context.ActionArguments["idActividad"];

    //    if (!await _context.Usuarios.AnyAsync(e => e.Id == idEst))
    //    {
    //        context.Result = new NotFoundObjectResult($"No se encontró ningún estudiante con ID {idEst}.");
    //        return;
    //    }

    //    if (!await _context.Actividad.AnyAsync(a => a.Id == idAct))
    //    {
    //        context.Result = new NotFoundObjectResult($"No se encontró ninguna actividad con ID {idAct}.");
    //        return;
    //    }

    //    await next();
    //}
}
