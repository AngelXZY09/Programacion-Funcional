using System.Text.Json.Serialization;

namespace ApiCrud.Entitys
{
    public class MessageManagerError
    {
       
        public bool succes { get; set; } // Cambiado a PascalCase por convención
        public string? message { get; set; }
        public int codeError { get; set; }
    }
}
