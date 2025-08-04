using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace ApiCrud.Entitys
{
    public class User : IdentityUser
    {
        [Required]
        [MaxLength(14)]
        public string MatriculaRfc { get; set; } = null!;
        [MaxLength(100)]
        public string Nombre { get; set; } = null!;
    }
}
