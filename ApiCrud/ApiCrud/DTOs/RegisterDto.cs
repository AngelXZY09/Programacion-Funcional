using System.ComponentModel.DataAnnotations;

namespace ApiCrud.DTOs
{
    public class RegisterDto
    {
        
        public string Email { get; set; }
        public string Password { get; set; }

        [Required]
        public string role { get; set; }

        [MaxLength(14)]
        public string? Matricula { get; set; }
        [MaxLength(100)]
        public string? Nombre { get; set; }
    }
}
